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
    
    var body: some View {
        NavigationStack {
            if savedTitles.isEmpty {
                Text("No Downloads")
                    .padding()
                    .font(.title3)
                    .bold()
            } else {
                VerticalListView(titles: savedTitles, canDelete: true)
            }
        }
    }
}

#Preview {
    DownloadView()
}
