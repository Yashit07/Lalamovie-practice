//
//  SimpleYoutubeView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 10/11/25.
//

import SwiftUI

struct SimpleYoutubeView: View {
    let videoId: String
    
    private let cornerRadius: CGFloat = 20
    
    var body: some View {
        GeometryReader { geo in
            Button {
                openYouTube()
            } label: {
                ZStack {
                    AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(videoId)/maxresdefault.jpg")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .contentShape(Rectangle())
                            .frame(maxWidth: .infinity)
                    } placeholder: {
                        ProgressView()
                            .frame(width: geo.size.width, height: geo.size.height * 0.5)
                    }
                    
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: "play.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
            }
        }
    }
    
    private func openYouTube() {
        if let url = URL(string: "https://www.youtube.com/watch?v=\(videoId)") {
            UIApplication.shared.open(url)
        }
    }
}

