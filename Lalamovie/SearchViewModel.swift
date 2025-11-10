//
//  SearchViewModel.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 11/11/25.
//

import Foundation

@Observable
class SearchViewModel {
    private(set) var errorMessage: String?
    private(set) var searchtiTles: [Title] = []
    private let dataFetcher = DataFetcher()
    
    func getSearchTitles(by media: String, for title: String) async {
        do {
            errorMessage = nil
            if title.isEmpty {
                searchtiTles = try await dataFetcher.fetchTitles(for: media, by: "trending")
            } else {
                searchtiTles = try await dataFetcher.fetchTitles(for: media, by: "search", with: title)
            }
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
}
