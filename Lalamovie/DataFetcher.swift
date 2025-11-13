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
    let youtubeSearchURL = APIConfig.shared?.youtubeSearchURL
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
    
    func fetchTitles(for media: String, by type:String, with title:String? = nil) async throws -> [Title] {
        print("APIConfig baseURL:", tmdbBaseURL as Any, "apiKey present:", tmdbAPIKey != nil)
        let fetchTitlesURL = try buildURL(media: media, type: type, searchPhrase: title)
        
        guard let fetchTitlesURL = fetchTitlesURL else {
            throw NetworkError.urlBuildFailed
        }
        
        print("Request URL:", fetchTitlesURL.absoluteString)
        var titles = try await fetchAndDecode(url: fetchTitlesURL, type: TMDBAPIObject.self).results
        
        Constants.addPosterPath(to: &titles)
        return titles
    }
    
    func fetchVideoID(for title: String) async throws -> String {
        guard let baseSearchURL = youtubeSearchURL else {
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
    }
    
    func fetchAndDecode<T: Decodable>(url:URL, type: T.Type) async throws -> T {
        let (data, urlResponse) = try await Self.customSession.data(from: url)
        
        if let http = urlResponse as? HTTPURLResponse {
            print("HTTP status:", http.statusCode, "for", url.absoluteString)
            if http.statusCode != 200 {
                let snippet = String(data: data.prefix(512), encoding: .utf8)
                print("Non-200 response body (first 512 bytes):", snippet ?? "<non-utf8>")
                let context = HTTPFailureContext(statusCode: http.statusCode, snippet: snippet, url: url)
                throw NetworkError.badURLResponse(context: context)
            }
        } else {
            print("URLResponse is not HTTPURLResponse:", urlResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }
    
    private func buildURL(media:String, type:String, searchPhrase:String? = nil) throws -> URL? {
        guard let baseURL = tmdbBaseURL else {
            throw NetworkError.missingConfig
        }
        guard let apiKey = tmdbAPIKey else {
            throw NetworkError.missingConfig
        }
        
        var path:String
        
        if type == "trending" {
            path = "3/\(type)/\(media)/day"
        } else if type == "top_rated" || type == "upcoming" {
            path = "3/\(media)/\(type)"
        } else if type == "search" {
            path = "3/\(type)/\(media)"
        } else {
            throw NetworkError.urlBuildFailed
        }
        
        var urlqueryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        if let searchPhrase {
            urlqueryItems.append(URLQueryItem(name:"query", value: searchPhrase))
        }
        
        guard let url = URL(string: baseURL)?
            .appending(path: path)
            .appending(queryItems: urlqueryItems) else {
            throw NetworkError.urlBuildFailed
        }
        
        return url
    }
}

