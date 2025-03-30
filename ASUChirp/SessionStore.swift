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
    
    func listen() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            self.currentUser = user
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
