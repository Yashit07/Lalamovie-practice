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
                        Text("Couldn’t Load Upcoming")
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
                                .background(Color.accentColor)
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
            .navigationTitle(Constants.upcomingString)
            .task {
                await viewModel.getUpcomingMovies()
            }
        }
    }
}

#Preview {
    UpcomingView()
}

