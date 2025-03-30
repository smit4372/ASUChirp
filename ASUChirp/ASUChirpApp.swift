
import SwiftUI
import Firebase

@main
struct ASUChirpApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    @StateObject var sessionStore = SessionStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
        }
    }
}

