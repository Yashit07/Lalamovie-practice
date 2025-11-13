import SwiftUI

enum AppTabs {
    case home, upcoming, downloads, search
}
 
struct ContentView: View {
    @State var selectedTab: AppTabs = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(Constants.homeString, systemImage: Constants.homeIconString, value: .home) {
                HomeView()
            }
            
            Tab(Constants.upcomingString, systemImage: Constants.UpcomingIconString, value: .upcoming) {
                UpcomingView()
            }
            
            Tab(Constants.downloadsString, systemImage: Constants.DownloadsIconString, value: .downloads) {
                DownloadView()
            }
            
            //            Tab(Constants.searchString, systemImage: Constants.SearchIconString) {
            //                SearchView()
            //            }
            
            Tab(value: .search, role: .search) {
                SearchView()
            }
        }
        .tint(Color("primaryc"))
    }
}

#Preview {
    ContentView()
}
