//
//  SessionStore.swift
//  ASUChirp
//
//  Created by Smit Desai on 3/29/25.
//

import Foundation
import FirebaseAuth

class SessionStore: ObservableObject {
    @Published var currentUser: User?
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        listen()
    }
    
//    func listen() {
//        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
//            self.currentUser = user
//        }
//    }
    
    func listen() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, firebaseUser in
            if let firebaseUser = firebaseUser {
                // Convert Firebase User to your custom User model
                let user = User(
                    id: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    displayName: firebaseUser.displayName,
                    bio: nil,
                    joinDate: Date()
                )
                self.currentUser = user
            } else {
                self.currentUser = nil
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
