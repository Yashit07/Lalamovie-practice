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
                VStack(spacing: 0) {
                    ZStack(alignment: .bottom) {
                        // Hero poster image filling the top and covering the notch
                        AsyncImage(url: URL(string: title.posterPath ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .contentShape(Rectangle())
                                .frame(maxWidth: .infinity)
                        } placeholder: {
                            ProgressView()
                                .frame(width: geo.size.width, height: geo.size.height * 0.5)
                        }
                        
                        
                    }
                    
                    // Content card that appears as a rounded sheet above the poster
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
//                    .background(Color(.systemBackground))
                    .background(Color(.gray).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                    .padding(.horizontal, 12)
                    .padding(.top,12) // add space from the top (was -3.5)
                    .padding(.bottom, 24)
                }
            }
            .ignoresSafeArea(.container, edges: .top)
        }
    }
}

#Preview {
    TitleDetailView(title: Title.preiviewTtiles[0])
}
