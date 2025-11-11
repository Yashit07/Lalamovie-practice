//
//  UpcomingView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 11/11/25.
//

import SwiftUI

struct UpcomingView: View {
    let viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                switch viewModel.upcomingStatus {
                case .notStarted:
                    Color.clear
                        .frame(width: geo.size.width, height: geo.size.height)
                case .fetching:
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.3)
                            .tint(Color("primaryc")) // Progress view color
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geo.size.height)
                    .background(Color(.systemBackground))
                case .success:
                    VerticalListView(titles: viewModel.upcomingMovies)
                        .background(Color(.systemBackground))
                case .failed(let underlyingError):
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 52))
                            .foregroundStyle(.secondary)
                        Text("Couldn't Load Upcoming")
                            .font(.title3.bold())
                        Text(underlyingError.localizedDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        Button {
                            Task { await viewModel.getUpcomingMovies() }
                        } label: {
                            Text("Retry")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 120, height: 44)
                                .background(Color("primaryc")) // Changed from Color.appPrimary
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 4)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: geo.size.height)
                    .background(Color(.systemBackground))
                }
            }
            // Styled two-line, left-aligned title, lowered a bit
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            // Top line: Title 1 bold
                            Text(Constants.upcomingString)
                                .font(.title.weight(.bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            // Bottom line: thin cursive, shifted right
                            HStack(spacing: 115) {
                                Spacer().frame(width: 1)
                                Text("Movies")
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
                        .padding(.top, 80) // drop the title block down a bit
                        Spacer()
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Upcoming Movies")
                }
            }
            .task {
                await viewModel.getUpcomingMovies()
            }
        }
    }
}

#Preview {
    UpcomingView()
}
