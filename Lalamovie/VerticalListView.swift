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
    let onSelect: (Title) -> Void
    @Environment(\.modelContext) var modelContext
    
    // Design tokens aligned with the rest of the app
    private let cardCornerRadius: CGFloat = 20
    private let imageCornerRadius: CGFloat = 12
    private let cardPadding: CGFloat = 12
    private let interItemSpacing: CGFloat = 12
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Header only for Downloads screen
                if canDelete {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("All Downloads")
                            .font(.title2.bold())
                            .accessibilityAddTraits(.isHeader)
                        Text("Saved to your device")
                            .font(.custom(
                                "Snell Roundhand",
                                size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize
                            ))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, cardPadding)
                    .padding(.top, 8)
                }
                
                LazyVStack(spacing: interItemSpacing) {
                    ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                        // Per-row swipe container
                        SwipeableRow(canDelete: canDelete) {
                            Button {
                                onSelect(title)
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
                                                .font(.custom(
                                                    "Snell Roundhand",
                                                    size: UIFont.preferredFont(forTextStyle: .subheadline).pointSize
                                                ))
                                                .foregroundStyle(.secondary)
                                                .lineLimit(3)
                                        }
                                        
                                        Spacer(minLength: 0)
                                    }
                                    
                                    Spacer(minLength: 0)
                                    
                                    // Trailing controls
                                    HStack(spacing: 8) {
                                        // Rounded number badge (index + 1)
                                        RoundedBadge(text: "\(index + 1)")
                                            .fixedSize()
                                        
                                        // Small, plain, right-aligned trash icon
                                        if canDelete {
                                            Button {
                                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                                    modelContext.delete(title)
                                                    do {
                                                        try modelContext.save()
                                                    } catch {
                                                        print("Save failed:", error.localizedDescription)
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "trash")
                                                    .foregroundStyle(.red)
                                                    .imageScale(.medium)
                                            }
                                            .buttonStyle(.plain)
                                            .accessibilityLabel("Delete")
                                        }
                                    }
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
                        } onDelete: {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                modelContext.delete(title)
                                do {
                                    try modelContext.save()
                                } catch {
                                    print("Save failed:", error.localizedDescription)
                                }
                            }
                        }
                        .padding(.horizontal, cardPadding)
                    }
                }
                .padding(.top, canDelete ? 4 : 8)
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

// A thin custom swipe container that reveals a trailing Delete when swiped left.
// Keeps row appearance unchanged unless dragged.
private struct SwipeableRow<Content: View>: View {
    let canDelete: Bool
    @ViewBuilder var content: Content
    let onDelete: () -> Void
    
    @State private var offsetX: CGFloat = 0      // 0 (closed) to -revealWidth (open)
    @State private var isOpen = false
    
    // Match badge look: same corner radius and height ~28pt
    private let revealWidth: CGFloat = 56   // compact width close to badge visual weight
    private let buttonHeight: CGFloat = 28  // matches badge height (footnote + 6+6 padding)
    private let openThreshold: CGFloat = 28
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Trailing delete background sized like the badge
            if canDelete {
                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            onDelete()
                            isOpen = false
                            offsetX = 0
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.footnote.weight(.semibold)) // match badge text size weight
                            .foregroundStyle(.white)
                            .frame(width: revealWidth, height: buttonHeight, alignment: .center)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)) // same as badge
                    .padding(.trailing, 4)
                }
            }
            
            // Foreground content that slides
            content
                .offset(x: canDelete ? offsetX : 0)
                .gesture(
                    canDelete ?
                    DragGesture(minimumDistance: 10, coordinateSpace: .local)
                        .onChanged { value in
                            let dx = value.translation.width
                            if isOpen {
                                offsetX = max(-revealWidth, min(0, -revealWidth + dx))
                            } else {
                                offsetX = max(-revealWidth, min(0, dx))
                            }
                        }
                        .onEnded { value in
                            let dx = value.translation.width
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                if isOpen {
                                    if dx > openThreshold {
                                        isOpen = false
                                        offsetX = 0
                                    } else {
                                        isOpen = true
                                        offsetX = -revealWidth
                                    }
                                } else {
                                    if dx < -openThreshold {
                                        isOpen = true
                                        offsetX = -revealWidth
                                    } else {
                                        isOpen = false
                                        offsetX = 0
                                    }
                                }
                            }
                        }
                    : nil
                )
                .onTapGesture {
                    if canDelete, isOpen {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                            isOpen = false
                            offsetX = 0
                        }
                    }
                }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    VerticalListView(titles: Title.preiviewTtiles, canDelete: true, onSelect: { _ in })
}

