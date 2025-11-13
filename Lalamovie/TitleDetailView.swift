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
                content(geo: geo)
            case .failed(let underlyingError):
                VStack(spacing: 16) {
                    // Keep the content card visible even if trailer fails
                    contentCard
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                    
                    // Friendly error message
                    Text(underlyingError.localizedDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    HStack(spacing: 12) {
                        Button {
                            Task { await viewModel.getVideoID(for: titleName) }
                        } label: {
                            Text("Retry")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(width: 120, height: 44)
                                .background(Color("primaryc"))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button {
                            // Allow user to search trailer directly in YouTube if API fails
                            let q = "\(titleName) trailer".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? titleName
                            if let url = URL(string: "https://www.youtube.com/results?search_query=\(q)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text("Open in YouTube")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .frame(height: 44)
                                .padding(.horizontal, 16)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await viewModel.getVideoID(for: titleName)
        }
    }
    
    @ViewBuilder
    private func content(geo: GeometryProxy) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                contentCard
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
    }
    
    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(titleName)
                .font(.title2.bold())
                .padding(.top, 8)
            
            if let overview = title.overview, !overview.isEmpty {
                Text(overview)
                    .font(.custom(
                        "Snell Roundhand",
                        size: UIFont.preferredFont(forTextStyle: .body).pointSize
                    ))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.gray).opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    TitleDetailView(title: Title.preiviewTtiles[0])
}

