//
//  User.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//

// User.swift
import Foundation
import FirebaseAuth

struct User: Identifiable {
    var id: String
    var email: String
    var displayName: String?
    var bio: String?
    var joinDate: Date
    
    // Create from Firebase Auth User
    static func fromFirebaseUser(_ user: FirebaseAuth.User) -> User {
        return User(
            id: user.uid,
            email: user.email ?? "",
            displayName: user.displayName,
            bio: nil,
            joinDate: Date()
        )
    }
}
