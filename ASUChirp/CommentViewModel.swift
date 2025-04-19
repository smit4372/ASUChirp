//
//  CommentViewModel.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//

import Foundation
import FirebaseFirestore
import Combine

class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var commentText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let chirpId: String
    
    init(chirpId: String) {
        self.chirpId = chirpId
    }
    
    func fetchComments() {
        isLoading = true
        errorMessage = nil
        
        listener = db.collection("comments")
            .whereField("chirpId", isEqualTo: chirpId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error fetching comments: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    self.errorMessage = "No comments found"
                    return
                }
                
                self.comments = documents.compactMap { document -> Comment? in
                    let id = document.documentID
                    let data = document.data()
                    return Comment.fromFirestore(id: id, data: data)
                }
            }
    }
    
    func postComment(userId: String, username: String, completion: @escaping (Bool) -> Void) {
        guard !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Comment cannot be empty"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let comment = Comment(
            id: UUID().uuidString, // Firestore will replace this
            chirpId: chirpId,
            userId: userId,
            username: username,
            text: commentText,
            timestamp: Date()
        )
        
        // Transaction to add comment and update comment count on the chirp
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // First, add the comment
            let commentRef = self.db.collection("comments").document()
            transaction.setData(comment.toFirestore(), forDocument: commentRef)
            
            // Then, update the chirp's comment count
            let chirpRef = self.db.collection("chirps").document(self.chirpId)
            
            let chirpDocument: DocumentSnapshot
            do {
                try chirpDocument = transaction.getDocument(chirpRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldCommentCount = chirpDocument.data()?["commentCount"] as? Int else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve comment count from chirp"
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            transaction.updateData(["commentCount": oldCommentCount + 1], forDocument: chirpRef)
            return nil
        }) { [weak self] (_, error) in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Error posting comment: \(error.localizedDescription)"
                completion(false)
            } else {
                self.commentText = ""
                completion(true)
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}
