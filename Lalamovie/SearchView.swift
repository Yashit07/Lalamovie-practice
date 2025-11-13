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
    @State private var navigationPath = NavigationPath()
    @Namespace private var toggleNamespace
    
    // Custom titles and prompts as requested
    // Removed unused navTitle (custom toolbar is used instead)
    private var searchPrompt: String {
        searchByMovies ? "Search any Movie" : "Search any TV Series"
    }
    
    // Second line text under the main title
    private var secondaryLineText: String {
        searchByMovies ? "Movies" : "TV Series"
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                            .onTapGesture {
                                navigationPath.append(title)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                }
                .padding(.top, 12)
            }
            // Replace default title with custom two-line left-aligned title (matching UpcomingView style)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            // Top line: larger, bold
                            Text("Search for")
                                .font(.title.weight(.bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            // Bottom line: thin cursive, larger, shifted further right
                            HStack(spacing: 115) {
                                Spacer().frame(width: 1)
                                Text(secondaryLineText)
                                    .font(.custom(
                                        "Snell Roundhand",
                                        size: UIFont.preferredFont(forTextStyle: .title2).pointSize + 4
                                    ))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Spacer(minLength: 0)
                            }
                        }
                        .padding(.top, 80) // mirror the downward shift you applied in UpcomingView
                        Spacer()
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(searchByMovies ? "Search Movies" : "Search TV Series")
                }
            }
            .searchable(text: $searchText, prompt: searchPrompt)
            .tint(Color("primaryc")) // Search bar cursor and cancel button
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
            .navigationDestination(for: Title.self) { title in
                TitleDetailView(title: title)
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
                    await searchViewModel.getSearchTitles(by: "movie", for: $searchText.wrappedValue)
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
                    await searchViewModel.getSearchTitles(by: "tv", for: $searchText.wrappedValue)
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
                        .fill(Color("primaryc").opacity(0.18)) // Changed from Color.accentColor
                        .matchedGeometryEffect(id: "SEGMENT_HIGHLIGHT", in: toggleNamespace)
                }
                HStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.headline.weight(.semibold))
                    Text(title)
                        .font(.headline.weight(.semibold))
                }
                .foregroundStyle(isSelected ? Color("primaryc") : .primary) // Changed from Color.accentColor
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

