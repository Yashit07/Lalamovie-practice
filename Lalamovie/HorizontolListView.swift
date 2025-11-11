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
    
    // Derived header parts for styling
    private var primaryHeader: String {
        // Known patterns first
        if header.hasPrefix("Trending ") {
            return "Trending"
        } else if header.hasPrefix("Top Rated ") {
            return "Top Rated"
        }
        // Fallback: take all but the last word(s)
        let parts = header.split(separator: " ")
        if parts.count > 1 {
            return parts.dropLast().joined(separator: " ")
        } else {
            return header
        }
    }
    
    private var secondaryHeader: String {
        if header.hasPrefix("Trending ") {
            return String(header.dropFirst("Trending ".count))
        } else if header.hasPrefix("Top Rated ") {
            return String(header.dropFirst("Top Rated ".count))
        }
        // Fallback: last word(s)
        let parts = header.split(separator: " ")
        if parts.count > 1 {
            return String(parts.suffix(1).joined(separator: " "))
        } else {
            return ""
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Styled, two-line header (no vertical drop)
            VStack(alignment: .leading, spacing: 2) {
                Text(primaryHeader)
                    .font(.title2.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                
                HStack(spacing: 80) {
                    Spacer().frame(width: 1) // slight right shift for the cursive line
                    Text(secondaryHeader)
                        .font(.custom(
                            "Snell Roundhand",
                            size: UIFont.preferredFont(forTextStyle: .title3).pointSize + 2
                        ))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .bold()
                    Spacer(minLength: 0)
                }
            }
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
