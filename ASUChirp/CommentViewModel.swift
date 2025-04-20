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
        
        // creating comment data
        let commentData: [String: Any] = [
            "chirpId": chirpId,
            "userId": userId,
            "username": username,
            "text": commentText,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // putting comment to firestore
        let commentRef = db.collection("comments").document()
        
        commentRef.setData(commentData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.errorMessage = "Error posting comment: \(error.localizedDescription)"
                completion(false)
                return
            }
            
            let chirpRef = self.db.collection("chirps").document(self.chirpId)
            
            chirpRef.updateData([
                "commentCount": FieldValue.increment(Int64(1))
            ]) { error in
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error updating chirp: \(error.localizedDescription)"
                    completion(false)
                } else {
                    // done and clearing text box
                    self.commentText = ""
                    
                    // refreshing comments
                    self.fetchComments()
                    
                    completion(true)
                }
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}
