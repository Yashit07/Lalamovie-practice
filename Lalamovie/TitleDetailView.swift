//
//  TitleDetailView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 09/11/25.
//

import SwiftUI
import SwiftData

struct TitleDetailView: View {
    let title: Title
    var titleName : String {
        return (title.name ?? title.title) ?? ""
    }
    let viewModel = ViewModel()
    @Environment(\.modelContext) var modelContext
    
    private let bottomButtonHeight: CGFloat = 48
    private let bottomButtonHorizontalPadding: CGFloat = 16
    
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
                    VStack(spacing: 24) {
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
                        .padding(.top, 12)
                        
                        // Player with button overlay
                        ZStack(alignment: .bottom) {
                            SimpleYoutubeView(videoId: viewModel.videoID)
                                .aspectRatio(1.3, contentMode: .fit)
                            
                            // Download button overlaid on player
                            HStack {
                                Spacer()
                                Button {
                                    let saveTitle = title
                                    saveTitle.title = titleName
                                    modelContext.insert(saveTitle)
                                    try? modelContext.save()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.down.circle")
                                            .font(.headline.weight(.semibold))
                                        Text(Constants.downloadString)
                                            .font(.headline.weight(.semibold))
                                    }
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: bottomButtonHeight)
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
                                Spacer()
                            }
                            .padding(.horizontal, bottomButtonHorizontalPadding)
                            .padding(.bottom, 16)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 12)
                        
                        // Bottom padding for scroll
                        Color.clear
                            .frame(height: 24)
                    }
                }
            case .failed(let underlyingError):
                Text(underlyingError.localizedDescription)
            }
        }
        .task {
            await viewModel.getVideoID(for: titleName)
        }
    }
}

#Preview {
    TitleDetailView(title: Title.preiviewTtiles[0])
}
