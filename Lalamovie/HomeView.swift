//
//  HomeView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 05/11/25.
//

import SwiftUI

struct HomeView: View {
    //    var heroTestTitle = Constants.testTitleURL3
    @State var viewModel = ViewModel()
    @State private var titleDetailPath = NavigationPath()
  
    var body: some View {
        NavigationStack(path: $titleDetailPath) {
            GeometryReader { geo in
                ScrollView(.vertical) {
                    switch viewModel.homeStatus {
                    case .notStarted:
                        EmptyView()
                        
                    case .fetching:
                        VStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(1.5)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: geo.size.height)
                        
                    case .success:
                        LazyVStack(spacing: 16) {
                            ZStack(alignment: .bottom) {
                                AsyncImage(url: URL(string: viewModel.heroTitle.posterPath ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .contentShape(Rectangle())
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: geo.size.width, height: geo.size.height * 0.85)
                                }
                                
                                // Floating buttons over hero image
                                HStack(spacing: 12) {
                                    Button {
                                        titleDetailPath.append(viewModel.heroTitle)
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "play.fill")
                                                .font(.headline.weight(.semibold))
                                            Text(Constants.playString)
                                                .font(.headline.weight(.semibold))
                                        }
                                        .foregroundStyle(Color.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(
                                            LinearGradient(
                                                colors: [
                                                    Color.accentColor,
                                                    Color.accentColor.opacity(0.9)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 8)
                                    }
                                    .buttonStyle(PressedScaleStyle())
                                    
                                    Button {
                                        // Download action
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "arrow.down.circle")
                                                .font(.headline.weight(.semibold))
                                            Text(Constants.downloadsString)
                                                .font(.headline.weight(.semibold))
                                        }
                                        .foregroundStyle(.primary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .strokeBorder(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.primary.opacity(0.25),
                                                            Color.primary.opacity(0.10)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                                    }
                                    .buttonStyle(PressedScaleStyle())
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 16) // lift off the bottom edge of the image
                            }
                            
                            // Sections below
                            HorizontolListView(header: Constants.trendingMovieString, titles: viewModel.trendingMovies) { Title in
                                titleDetailPath.append(Title)
                            }
                            HorizontolListView(header: "Trending TV Series", titles: viewModel.trendingTV) { Title in
                                titleDetailPath.append(Title)
                            }
                            HorizontolListView(header: Constants.topRatedMovieString, titles: viewModel.topRatedMovies) { Title in
                                titleDetailPath.append(Title)
                            }
                            HorizontolListView(header: "Top Rated TV Series", titles: viewModel.topRatedTV) { Title in
                                titleDetailPath.append(Title)
                            }
                        }
                        
                    case .failed(let error):
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            Text("Connection Failed")
                                .font(.title2.bold())
                            Text(error.localizedDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Button {
                                Task {
                                    await viewModel.getTitles()
                                }
                            } label: {
                                Text("Retry")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(width: 120, height: 44)
                                    .background(Color.accentColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.top, 8)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: geo.size.height)
                    }
                    
                }
                .ignoresSafeArea(.container, edges: .top)
                // Initial load
                .task {
                    await viewModel.getTitles()
                }
                // Single destination definition for Title
                .navigationDestination(for: Title.self) { Title in
                    TitleDetailView(title: Title)
                }
            }
        }
    }
}

// A subtle pressed feedback style that scales down slightly when pressed
struct PressedScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: configuration.isPressed)
    }
}

#Preview {
    HomeView()
}
