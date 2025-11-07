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
    
    func fetchTitles(for media: String) async throws -> [Title] {
        print("APIConfig baseURL:", tmdbBaseURL as Any, "apiKey present:", tmdbAPIKey != nil)
        
        guard let baseURL = tmdbBaseURL else {
            throw NetworkError.missingConfig
        }
        guard let apiKey = tmdbAPIKey else {
            throw NetworkError.missingConfig
        }
        
        guard let fetchTitlesURL = URL(string: baseURL)?
            .appending(path: "3/trending/\(media)/day")
            .appending(queryItems: [
                URLQueryItem(name: "api_key", value: apiKey)
            ]) else {
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
}
