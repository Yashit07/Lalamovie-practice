//
//  TitleDetailView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 09/11/25.
//

import SwiftUI

struct TitleDetailView: View {
    let title: Title
    var titleName : String {
        return (title.name ?? title.title) ?? ""
    }
    let viewModel = ViewModel()
    
    var body: some View {
        GeometryReader { geo in
            switch viewModel.videoIDStatus {
            case .notStarted:
                EmptyView()
            case .fetching:
                ProgressView()
                    .frame(width: geo.size.width, height: geo.size.height)
            case .success:
                ScrollView {
                    VStack(spacing: 24) { // increased spacing between text card and player
                        // Content card FIRST (on top), below the notch
                        VStack(alignment: .leading, spacing: 12) {
                            Text(titleName)
                                .font(.title2.bold())
                                .padding(.top, 8)
                            
                            if let overview = title.overview, !overview.isEmpty {
                                Text(overview)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.gray).opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                        .padding(.horizontal, 12)
                        .padding(.top, 12) // keeps it below the notch when combined with safe area respect
                        
                        // Player SECOND (on bottom)
                        ZStack(alignment: .bottom) {
                            SimpleYoutubeView(videoId: viewModel.videoID)
                                .aspectRatio(1.3, contentMode: .fit)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 24)
                    }
                }
            case .failed(let underlyingError):
                Text(underlyingError.localizedDescription)
            }
            // Respect safe areas so the text stays under the notch
        }
        .task {
            await viewModel.getVideoID(for: titleName)
        }
    }
}

#Preview {
    TitleDetailView(title: Title.preiviewTtiles[0])
}
