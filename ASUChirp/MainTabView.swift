import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeFeedView()
                .tabItem {
                    Label("Feed", systemImage: "list.bullet")
                }
                .tag(0)
            
            MapExplorerView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(1)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
        }
    }
}
