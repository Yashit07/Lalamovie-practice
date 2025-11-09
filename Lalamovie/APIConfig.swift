//
//  APIConfig.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 05/11/25.
//

import Foundation

struct APIConfig: Decodable {
    let tmdbBaseURL: String
    let tmdbAPIKey: String
    let youtubeBaseURL: String
    
    static let shared: APIConfig? = {
        do {
            let config = try loadConfig()
            print("Loaded APIConfig OK: baseURL=\(config.tmdbBaseURL), apiKeyPresent=\(!config.tmdbAPIKey.isEmpty)")
            return config
        } catch {
            print("failed to load API Config \(error.localizedDescription)")
            return nil
        }
    }()
    
    private static func loadConfig() throws -> APIConfig {
        guard let url = Bundle.main.url(forResource: "APIConfig", withExtension: "json") else {
            throw APIConfigError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder() .decode(APIConfig.self, from: data)
        } catch let error as DecodingError {
            throw APIConfigError.decodingFailed(underlyingError: error)
        } catch{
            throw APIConfigError.dataLoadingFailed(underlyingError: error)
        }
    }
}

