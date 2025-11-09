//
//  Constants.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 04/11/25.
//

import Foundation
import SwiftUI


struct Constants{
    static let homeString = "Home"
    static let upcomingString = "Upcoming"
    static let searchString = "Search"
    static let downloadsString = "Downloads"
    static let playString = "Play"
    static let trendingMovieString = "Trending Movies"
    static let trendingTvString = "Trending TV"
    static let topRatedMovieString = "Top Rated Movies"
    static let topRatedTvString = "Top Rated TV"
    
    static let homeIconString = "house"
    static let UpcomingIconString = "play.circle"
    static let SearchIconString = "magnifyingglass"
    static let DownloadsIconString = "arrow.down.to.line"
    
    static let testTitleURL = "https://media-cache.cinematerial.com/p/500x/ymlgsr9n/chennai-express-indian-movie-poster.jpg?v=1456507918"
    static let testTitleURL2 = "https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg"
    static let testTitleURL3 = "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg"
    
    static let posterURLStart = "https://image.tmdb.org/t/p/w500"
    
    static func addPosterPath(to titles: inout[Title]) {
        for index in titles.indices {
            if let path = titles[index].posterPath {
                titles[index].posterPath = Constants.posterURLStart + path
            }
        }
    }
}

enum youtubeURLStrings: String {
    case trailer = "trailer"
    case queryShorten = "q"
    case space = " "
    case key = "key"
}

extension Text {
    func ghostButton() -> some View {
        self
            .frame(width: 70, height: 40)
            .foregroundStyle(.buttonText)
            .bold()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(lineWidth: 2)
            }

    }
}
