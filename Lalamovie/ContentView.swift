//
//  ContentView.swift
//  Lalamovie
//
//  Created by Yashit Chawla on 04/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            Tab(Constants.homeString,systemImage: Constants.homeIconString){
                HomeView()
            }
            
            Tab(Constants.upcomingString,systemImage: Constants.UpcomingIconString){
                UpcomingView()
            }
            
            Tab(Constants.searchString,systemImage: Constants.SearchIconString){
                SearchView()
            }
            
            Tab(Constants.downloadsString,systemImage: Constants.DownloadsIconString){
                Text(Constants.downloadsString)
            }
        }
        
    }
}

#Preview {
    ContentView()
}
