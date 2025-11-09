//
//  TitleDetailView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 09/11/25.
//

import SwiftUI

struct TitleDetailView: View {
    let title: Title
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 24) { // increased spacing between text card and player
                    // Content card FIRST (on top), below the notch
                    VStack(alignment: .leading, spacing: 12) {
                        Text((title.name ?? title.title) ?? "")
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
                        SimpleYoutubeView(videoId: "dQw4w9WgXcQ")
                            .aspectRatio(1.3, contentMode: .fit)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)
                }
            }
            // Respect safe areas so the text stays under the notch
        }
    }
}

#Preview {
    TitleDetailView(title: Title.preiviewTtiles[0])
}
