//
//  VerticalListView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 11/11/25.
//

import SwiftUI
import SwiftData

struct VerticalListView: View {
    var titles: [Title]
    let canDelete: Bool
    @Environment(\.modelContext) var modelContext
    
    // Design tokens aligned with the rest of the app
    private let cardCornerRadius: CGFloat = 20
    private let imageCornerRadius: CGFloat = 12
    private let cardPadding: CGFloat = 12
    private let interItemSpacing: CGFloat = 12
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: interItemSpacing) {
                ForEach(Array(titles.enumerated()), id: \.element) { index, title in
                    NavigationLink {
                        TitleDetailView(title: title)
                    } label: {
                        HStack(spacing: 12) {
                            // Poster
                            AsyncImage(url: URL(string: title.posterPath ?? "")) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous)
                                        .fill(Color(.systemGray5))
                                    ProgressView()
                                        .tint(Color("primaryc"))
                                }
                            }
                            .frame(width: 90, height: 130)
                            .clipShape(RoundedRectangle(cornerRadius: imageCornerRadius, style: .continuous))
                            
                            // Texts
                            VStack(alignment: .leading, spacing: 6) {
                                Text((title.name ?? title.title) ?? "")
                                    .font(.headline.weight(.semibold))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                
                                if let overview = title.overview, !overview.isEmpty {
                                    Text(overview)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                }
                                
                                Spacer(minLength: 0)
                            }
                            
                            Spacer()
                            
                            // Rounded number badge (index + 1). Replace with rating if available later.
                            RoundedBadge(text: "\(index + 1)")
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                                .fill(Color(.gray).opacity(0.12))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.primary.opacity(0.12),
                                            Color.primary.opacity(0.06)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, cardPadding)
                    .swipeActions(edge: .trailing) {
                        if canDelete {
                            Button {
                                modelContext.delete(title)
                                try? modelContext.save()
                            } label: {
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// Small reusable rounded rectangle badge that matches the app's motif
private struct RoundedBadge: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color("primaryc"))
            )
            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
    }
}

#Preview {
    VerticalListView(titles: Title.preiviewTtiles, canDelete: true)
}
