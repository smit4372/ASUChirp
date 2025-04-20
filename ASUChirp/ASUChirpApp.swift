import SwiftUI
import Firebase

@main
struct ASUChirpApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    @StateObject var sessionViewModel = SessionViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionViewModel)
        }
    }
}

