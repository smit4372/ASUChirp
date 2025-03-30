////
////  ASUChirpApp.swift
////  ASUChirp
////
////  Created by Smit Desai on 3/29/25.
////
//
//import SwiftUI
//
//@main
//struct ASUChirpApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}


import SwiftUI
import Firebase

@main
struct ASUChirpApp: App {
    // Initialize Firebase when the app launches.
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

