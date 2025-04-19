//
//  SessionViewModel.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

class SessionViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    init() {
        listenToAuthChanges()
    }
    
    private func listenToAuthChanges() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, firebaseUser) in
            guard let self = self else { return }
            
            if let firebaseUser = firebaseUser {
                // Convert Firebase User to our User model
                let user = User(
                    id: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    displayName: firebaseUser.displayName ?? firebaseUser.email?.components(separatedBy: "@").first ?? "",
                    bio: nil,
                    joinDate: Date()
                )
                self.currentUser = user
                
                // Check if user document exists, if not create it
                self.ensureUserDocumentExists(userId: user.id, email: user.email, displayName: user.displayName ?? "")
            } else {
                self.currentUser = nil
            }
        }
    }
    
    // Ensure user document exists in Firestore
    private func ensureUserDocumentExists(userId: String, email: String, displayName: String) {
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Error fetching user: \(error.localizedDescription)"
                return
            }
            
            // If document doesn't exist, create it
            if document == nil || !document!.exists {
                let userData: [String: Any] = [
                    "email": email,
                    "displayName": displayName,
                    "bio": "",
                    "joinDate": FieldValue.serverTimestamp()
                ]
                
                userRef.setData(userData) { error in
                    if let error = error {
                        self.errorMessage = "Error creating user profile: \(error.localizedDescription)"
                    }
                }
            } else if let document = document, document.exists {
                // Update our currentUser with Firestore data
                if let data = document.data() {
                    self.currentUser?.displayName = data["displayName"] as? String
                    self.currentUser?.bio = data["bio"] as? String
                }
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard validateEmail(email) else {
            errorMessage = "Please use your ASU email."
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func signUp(email: String, password: String, passwordConfirm: String, username: String, completion: @escaping (Bool) -> Void) {
        // Add password confirmation check
        guard password == passwordConfirm else {
            errorMessage = "Passwords do not match."
            completion(false)
            return
        }
        
        guard validateEmail(email) else {
            errorMessage = "Please use your ASU email."
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
            } else if let user = result?.user {
                // Create user profile in Firestore with specified username
                self.createUserProfile(user: user, username: username) { success in
                    completion(success)
                }
            }
        }
    }
    
    private func createUserProfile(user: FirebaseAuth.User, username: String, completion: @escaping (Bool) -> Void) {
        let userData: [String: Any] = [
            "email": user.email ?? "",
            "displayName": username,
            "bio": "",
            "joinDate": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(user.uid).setData(userData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Error creating profile: \(error.localizedDescription)"
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updateProfile(displayName: String, bio: String, completion: @escaping (Bool) -> Void) {
        guard let userId = currentUser?.id else {
            errorMessage = "Not logged in"
            completion(false)
            return
        }
        
        let profileData: [String: Any] = [
            "displayName": displayName,
            "bio": bio
        ]
        
        // Check if document exists first
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Error checking profile: \(error.localizedDescription)"
                completion(false)
                return
            }
            
            // If document doesn't exist, create it
            if document == nil || !document!.exists {
                let fullData: [String: Any] = [
                    "email": self.currentUser?.email ?? "",
                    "displayName": displayName,
                    "bio": bio,
                    "joinDate": FieldValue.serverTimestamp()
                ]
                
                userRef.setData(fullData) { error in
                    if let error = error {
                        self.errorMessage = "Error creating profile: \(error.localizedDescription)"
                        completion(false)
                    } else {
                        // Update local user object
                        self.currentUser?.displayName = displayName
                        self.currentUser?.bio = bio
                        completion(true)
                    }
                }
            } else {
                // Document exists, update it
                userRef.updateData(profileData) { error in
                    if let error = error {
                        self.errorMessage = "Error updating profile: \(error.localizedDescription)"
                        completion(false)
                    } else {
                        // Update local user object
                        self.currentUser?.displayName = displayName
                        self.currentUser?.bio = bio
                        completion(true)
                    }
                }
            }
        }
    }
    
    private func validateEmail(_ email: String) -> Bool {
        return email.lowercased().hasSuffix("@asu.edu")
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = "Error signing out: \(error.localizedDescription)"
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
