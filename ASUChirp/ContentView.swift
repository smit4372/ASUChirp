//Smit Desai
//Saanvi Patel

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        Group {
            if sessionViewModel.currentUser != nil {
                MainTabView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            } else {
                LoginView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
            }
        }
    }
}

//
//#Preview {
//    ContentView()
//}
