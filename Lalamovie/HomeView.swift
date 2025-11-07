//
//  HomeView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 05/11/25.
//

import SwiftUI

struct HomeView: View {
    var heroTestTitle = Constants.testTitleURL3
    @State var viewModel = ViewModel()
  
    var body: some View {
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
                            AsyncImage(url: URL(string: heroTestTitle)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .contentShape(Rectangle())
                            } placeholder: {
                                ProgressView()
                                    .frame(width: geo.size.width, height: geo.size.height * 0.85)
                            }

                            // Bottom overlay that slightly overlaps the image
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(.systemBackground))
                                .frame(height: 36)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -2)
                                .offset(y: 18) // move it up into the image a bit (negative would move down)
                                .padding(.horizontal, 0)
                                .blendMode(.normal)
                        }

                        // Upgraded buttons
                        HStack(spacing: 12) {
                            Button {
                                // Play action
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

                        HorizontolListView(header: Constants.trendingMovieString, titles: viewModel.trendingMovies)
    //                    HorizontolListView(header: Constants.trendingTvString)
    //                    HorizontolListView(header: Constants.topRatedMovieString)
    //                    HorizontolListView(header: Constants.topRatedTvString)
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
            .task {
                await viewModel.getTitles()
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
