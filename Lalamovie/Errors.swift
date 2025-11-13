//
//  Errors.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 06/11/25.
//

import Foundation

enum APIConfigError: Error, LocalizedError {
    case fileNotFound
    case dataLoadingFailed(underlyingError: Error)
    case decodingFailed(underlyingError: Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "API configuration file not found."
        case .dataLoadingFailed(underlyingError: let error):
            return "Failed to load data from API configuration file: \(error.localizedDescription)."
        case .decodingFailed(underlyingError: let error):
            return "Failed to decode API configuration: \(error.localizedDescription)."
        }
    }
}

struct HTTPFailureContext: Equatable {
    let statusCode: Int
    let snippet: String?
    let url: URL?
}

enum NetworkError: Error, LocalizedError {
    case badURLResponse(context: HTTPFailureContext)
    case missingConfig
    case urlBuildFailed

    var errorDescription: String? {
        switch self {
        case .badURLResponse(let context):
            return Self.friendlyMessage(for: context)
        case .missingConfig:
            return "Missing API configuration."
        case .urlBuildFailed:
            return "Failed to build URL."
        }
    }
    
    private static func friendlyMessage(for context: HTTPFailureContext) -> String {
        // Map common statuses to clearer text; include host for context.
        let host = context.url?.host ?? "server"
        switch context.statusCode {
        case 401:
            return "Authorization failed. Please check your API key for \(host)."
        case 403:
            return "Request was rejected by \(host). This often means the API quota is exceeded or the key lacks permission."
        case 404:
            return "We couldn’t find what you were looking for on \(host)."
        case 429:
            return "You’ve hit the rate limit on \(host). Please try again in a bit."
        case 500...599:
            return "\(host.capitalized) is having trouble right now. Please try again later."
        default:
            return "Network request failed with status \(context.statusCode) from \(host). Please try again."
        }
    }
}

