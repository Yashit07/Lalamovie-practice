//
//  HomeView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 05/11/25.
//

import SwiftUI

struct HomeView: View {
    var heroTestTitle = Constants.testTitleURL3
  
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVStack(spacing: 16) {
                    AsyncImage(url: URL(string: heroTestTitle)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .overlay {
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: .clear, location: 0.8),
                                        Gradient.Stop(color: .gradient, location: 1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                            .contentShape(Rectangle())
                    } placeholder: {
                        ProgressView()
                            .frame(width: geo.size.width, height: geo.size.height * 0.85)
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

                    HorizontolListView(header: Constants.trendingMovieString)
                    HorizontolListView(header: Constants.trendingTvString)
                    HorizontolListView(header: Constants.topRatedMovieString)
                    HorizontolListView(header: Constants.topRatedTvString)
                }
            }
            .ignoresSafeArea(.container, edges: .top)
        }
    }
}

// A subtle pressed feedback style that scales down slightly when pressed
struct PressedScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

#Preview {
    HomeView()
}
