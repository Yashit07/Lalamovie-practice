//
//  HorizontolListView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 05/11/25.
//

import SwiftUI

struct HorizontolListView: View {
    let header : String
    var titles : [Title]
    let onSelect : (Title) -> Void
    
    // Match TitleDetailView’s card styling
    private let cardCornerRadius: CGFloat = 20
    private let imageCornerRadius: CGFloat = 12
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(header)
                .font(.title)
                .padding(.horizontal, 12)
            
            // One unified card background for the entire horizontal list
            ZStack {
                RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                    .fill(Color(.gray).opacity(0.18))
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(titles, id: \.self) { title in
                            AsyncImage(url: URL(string: title.posterPath ?? "")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous))
                            } placeholder: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous)
                                        .fill(Color(.systemGray5))
                                    ProgressView()
                                }
                            }
                            .frame(width: 120, height: 200)
                            .onTapGesture {
                                onSelect(title)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
            }
            .frame(height: 207) // enough to fit 200pt images + vertical padding
        }
    }
}

#Preview {
    HorizontolListView(header: Constants.trendingMovieString, titles: Title.preiviewTtiles) { _ in
        
    }
}
