//Smit Desai
//Saanvi Patel

import Foundation
import FirebaseAuth
// session storing for user's login
class SessionStore: ObservableObject {
    @Published var currentUser: User?
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        listen()
    }

    func listen() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, firebaseUser in
            if let firebaseUser = firebaseUser {
                // Converting firebase user to custom user
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
