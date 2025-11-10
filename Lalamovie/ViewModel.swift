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
    private(set) var videoIDStatus: FetchStatus = .notStarted
    private(set) var upcomingStatus: FetchStatus = .notStarted
    private let dataFetcher = DataFetcher()
    var trendingMovies : [Title] = []
    var trendingTV : [Title] = []
    var topRatedMovies : [Title] = []
    var topRatedTV : [Title] = []
    var upcomingMovies: [Title] = []
    var heroTitle = Title.preiviewTtiles[0]
    var videoID = ""
    
    // Preview-friendly initializer to avoid mutating private(set) status from views
    convenience init(preview: Bool) {
        self.init()
        if preview {
            self.trendingMovies = Title.preiviewTtiles
            self.trendingTV = Title.preiviewTtiles
            self.topRatedMovies = Title.preiviewTtiles
            self.topRatedTV = Title.preiviewTtiles
            self.heroTitle = Title.preiviewTtiles[0]
            self.homeStatus = .success
        }
    }
    
    func getTitles() async {
        homeStatus = .fetching
        
        if trendingMovies.isEmpty {
            
            print("ViewModel.getTitles() started")
            do {
                async let tMovies = dataFetcher.fetchTitles(for: "movie", by: "trending")
                async let tTv = dataFetcher.fetchTitles(for: "tv", by: "trending")
                async let tRMovies = dataFetcher.fetchTitles(for: "movie", by: "top_rated")
                async let tRTv = dataFetcher.fetchTitles(for: "tv", by: "top_rated")
                
                trendingMovies = try await tMovies
                trendingTV = try await tTv
                topRatedMovies = try await tRMovies
                topRatedTV = try await tRTv
                
                if let title = trendingMovies.randomElement() {
                    heroTitle = title
                }
                print("ViewModel.getTitles() success, titles count:", trendingMovies.count)
                homeStatus = .success
            } catch {
                print("fetch error:", error.localizedDescription)
                print("fetch error type:", type(of: error))
                homeStatus = .failed(underlyingError: error)
            }
        } else {
            homeStatus = .success
        }
    }
    
    func getVideoID(for Title: String) async {
        videoIDStatus = .fetching
        
        do {
            videoID = try await dataFetcher.fetchVideoID(for: Title)
            videoIDStatus = .success
        } catch{
            print(error)
            videoIDStatus = .failed(underlyingError: error)
        }
    }
    
    func getUpcomingMovies() async {
        upcomingStatus = .fetching
        
        do {
            upcomingMovies = try await dataFetcher.fetchTitles(for: "movie", by: "upcoming")
            upcomingStatus = .success
        } catch {
            print(error)
            upcomingStatus = .failed(underlyingError: error)
        }
    }
}

