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
    let youtubeSearcURL = APIConfig.shared?.youtubeSearchURL
    let youtubeAPIKey = APIConfig.shared?.youtubeAPIKey
    
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
        var titles = try await fetchAndDecode(url: fetchTitlesURL, type: TMDBAPIObject.self).results
        
        // Use custom session instead of shared
        
        Constants.addPosterPath(to: &titles)
        return titles
    }
    
    
    
    func fetchVideoID(for title: String) async throws -> String {
        // ✅ FIXED LINE BELOW — use `throw` not `throws`
        guard let baseSearchURL = youtubeSearcURL else {
            throw NetworkError.missingConfig
        }
        
        guard let searchAPIKey = youtubeAPIKey else {
            throw NetworkError.missingConfig
        }
        
        let trailerSearch = title + youtubeURLStrings.space.rawValue + youtubeURLStrings.trailer.rawValue
        
        guard let fetchVideoURL = URL(string: baseSearchURL)?.appending(queryItems: [
            URLQueryItem(name: youtubeURLStrings.queryShorten.rawValue, value: trailerSearch),
            URLQueryItem(name: youtubeURLStrings.key.rawValue, value: searchAPIKey),
        ]) else {
            throw NetworkError.urlBuildFailed
        }
        
        print(fetchVideoURL)
        return try await fetchAndDecode(url: fetchVideoURL, type: YoutubeSearchResponse.self).items?.first?.id?.videoId ?? ""
        
        // You can later decode or return a String from here
//        return fetchVideoURL.absoluteString
    }
    
    func fetchAndDecode<T: Decodable>(url:URL, type: T.Type) async throws -> T {
        let (data, urlResponse) = try await Self.customSession.data(from: url)
        
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
        return try decoder.decode(type, from: data)
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
