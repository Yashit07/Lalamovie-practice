//
//  ViewModel.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 07/11/25.
//

import Foundation
import Observation
@MainActor

@Observable
class ViewModel {
    enum FetchStatus {
        case notStarted
        case fetching
        case success
        case failed(underlyingError: Error)
    }
    private(set) var homeStatus: FetchStatus = .notStarted
    private let dataFetcher = DataFetcher()
    var trendingMovies : [Title] = []
    
    func getTitles() async {
        homeStatus = .fetching
        print("ViewModel.getTitles() started")
        do {
            trendingMovies = try await dataFetcher.fetchTitles(for: "movie")
            print("ViewModel.getTitles() success, titles count:", trendingMovies.count)
            homeStatus = .success
        } catch {
            print("fetch error:", error.localizedDescription)
            print("fetch error type:", type(of: error))
            homeStatus = .failed(underlyingError: error)
        }
    }
}
