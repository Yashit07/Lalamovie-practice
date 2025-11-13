//
//  DownloadView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 12/11/25.
//

import SwiftUI
import SwiftData

struct DownloadView: View {
    @Query var savedTitles: [Title]
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            if savedTitles.isEmpty {
                Text("No Downloads")
                    .padding()
                    .font(.title3)
                    .bold()
            } else {
                VerticalListView(titles: savedTitles, canDelete: true) { title in
                    navigationPath.append(title)
                }
            }
        }
        .navigationDestination(for: Title.self) { title in
            TitleDetailView(title: title)
        }
    }
}

#Preview {
    DownloadView()
}

