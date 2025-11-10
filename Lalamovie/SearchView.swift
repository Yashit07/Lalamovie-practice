//
//  SearchView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 11/11/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchByMovies = true
    @State private var searchText = ""
    private let searchViewModel = SearchViewModel()
    @Namespace private var toggleNamespace
    
    // Custom titles and prompts as requested
    private var navTitle: String {
        searchByMovies ? "Search for Movies" : "Search for TV Series"
    }
    private var searchPrompt: String {
        searchByMovies ? "Search any Movie" : "Search any TV Series"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Segmented toggle
                    segmentedToggle
                    
                    if let error = searchViewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(.rect(cornerRadius: 10))
                            .padding(.horizontal)
                    }
                    
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem()], spacing: 12) {
                        ForEach(searchViewModel.searchtiTles) { title in
                            AsyncImage(url: URL(string: title.posterPath ?? "")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(.rect(cornerRadius: 10))
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 120, height: 200)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                }
                .padding(.top, 12)
            }
            .navigationTitle(navTitle)
            .searchable(text: $searchText, prompt: searchPrompt)
            .task(id: searchText) {
                // Debounce typing
                try? await Task.sleep(for: .milliseconds(500))
                if Task.isCancelled { return }
                await searchViewModel.getSearchTitles(by: searchByMovies ? "movie" : "tv", for: searchText)
            }
            .task {
                // Initial load
                await searchViewModel.getSearchTitles(by: searchByMovies ? "movie" : "tv", for: searchText)
            }
        }
    }
    
    private var segmentedToggle: some View {
        HStack(spacing: 0) {
            segmentButton(
                title: "Movies",
                systemImage: Constants.movieIconString, // "movieclapper"
                isSelected: searchByMovies
            ) {
                guard !searchByMovies else { return }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9, blendDuration: 0.2)) {
                    searchByMovies = true
                }
                Haptic.selection()
                Task {
                    await searchViewModel.getSearchTitles(by: "movie", for: searchText)
                }
            }
            segmentButton(
                title: "TV Series",
                systemImage: Constants.tvIconString, // "tv"
                isSelected: !searchByMovies
            ) {
                guard searchByMovies else { return }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.9, blendDuration: 0.2)) {
                    searchByMovies = false
                }
                Haptic.selection()
                Task {
                    await searchViewModel.getSearchTitles(by: "tv", for: searchText)
                }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.primary.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }
    
    private func segmentButton(title: String, systemImage: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.accentColor.opacity(0.18))
                        .matchedGeometryEffect(id: "SEGMENT_HIGHLIGHT", in: toggleNamespace)
                }
                HStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.headline.weight(.semibold))
                    Text(title)
                        .font(.headline.weight(.semibold))
                }
                .foregroundStyle(isSelected ? Color.accentColor : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
    }
}

// Lightweight haptic helper
private enum Haptic {
    static func selection() {
        #if os(iOS)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }
}

#Preview {
    SearchView()
}
