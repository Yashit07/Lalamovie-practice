//
//  DataFetcher.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 06/11/25.
//

import Foundation

struct DataFetcher {
    
    let tmdbBaseURL = APIConfig.shared?.tmdbBaseURL
    let tmdbAPIKey = APIConfig.shared?.tmdbAPIKey
    
    // Custom URLSession with relaxed TLS requirements
    private static let customSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()
    
    func fetchTitles(for media: String, by type:String) async throws -> [Title] {
        print("APIConfig baseURL:", tmdbBaseURL as Any, "apiKey present:", tmdbAPIKey != nil)
        let fetchTitlesURL = try buildURL(media: media, type: type)
        
        guard let fetchTitlesURL = fetchTitlesURL else {
            throw NetworkError.urlBuildFailed
        }
        
        print("Request URL:", fetchTitlesURL.absoluteString)
        
        // Use custom session instead of shared
        let (data, urlResponse) = try await Self.customSession.data(from: fetchTitlesURL)
        
        if let http = urlResponse as? HTTPURLResponse {
            print("HTTP status:", http.statusCode)
            if http.statusCode != 200 {
                let snippet = String(data: data.prefix(512), encoding: .utf8) ?? "<non-utf8>"
                print("Non-200 response body (first 512 bytes):", snippet)
                throw NetworkError.badURLResponse(underlyingError: NSError(
                    domain: "dataFetcher",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP Response"]))
            }
        } else {
            print("URLResponse is not HTTPURLResponse:", urlResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        var titles = try decoder.decode(APIObject.self, from: data).results
        Constants.addPosterPath(to: &titles)
        return titles
    }
    
    private func buildURL(media:String, type:String) throws -> URL? {
        guard let baseURL = tmdbBaseURL else {
            throw NetworkError.missingConfig
        }
        guard let apiKey = tmdbAPIKey else {
            throw NetworkError.missingConfig
        }
        
        var path:String
        
        if type == "trending" {
            path = "3/trending/\(media)/day"
        } else if type == "top_rated" {
            // FIX: use "3/" not "r/"
            path = "3/\(media)/top_rated"
        } else {
            throw NetworkError.urlBuildFailed
        }
        
        guard let url = URL(string: baseURL)?
            .appending(path: path)
            .appending(queryItems: [
                URLQueryItem(name: "api_key", value: apiKey)
            ]) else {
            throw NetworkError.urlBuildFailed
        }
        
        return url
    }
}
