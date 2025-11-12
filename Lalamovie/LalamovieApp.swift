//
//  LalamovieApp.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 04/11/25.
//

import SwiftUI
import SwiftData

@main
struct LalamovieApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Color("primaryc")) // Global tint color for all system blues
        }
        .modelContainer(for: Title.self)
    }
}
