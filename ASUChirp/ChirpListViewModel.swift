//Smit Desai
//Saanvi Patel

import Foundation
import FirebaseFirestore
import Combine

class ChirpListViewModel: ObservableObject {
    @Published var chirps: [Chirp] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // filtering by user
    var currentUserId: String?
    var filterByUser: Bool = false
    
    func fetchChirps() {
        isLoading = true
        errorMessage = nil
        
        var query = db.collection("chirps")
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
        
        // for current user if needed
        if filterByUser, let userId = currentUserId {
            query = query.whereField("userId", isEqualTo: userId)
        }
        
        listener = query.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Error fetching chirps: \(error.localizedDescription)"
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self.errorMessage = "No chirps found"
                return
            }
            
            self.chirps = documents.compactMap { document -> Chirp? in
                let id = document.documentID
                let data = document.data()
                return Chirp.fromFirestore(id: id, data: data)
            }
        }
    }
    
    // liking the chirp
    func likeChirp(chirpId: String, userId: String, completion: @escaping (Bool) -> Void) {
        let chirpRef = db.collection("chirps").document(chirpId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let chirpDocument: DocumentSnapshot
            do {
                try chirpDocument = transaction.getDocument(chirpRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let data = chirpDocument.data() else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unable to retrieve chirp data"
                ])
                errorPointer?.pointee = error
                return nil
            }
            
            // getting current likes
            let oldLikeCount = data["likeCount"] as? Int ?? 0
            var likedBy = data["likedBy"] as? [String] ?? []
            
            // user can only like once
            let alreadyLiked = likedBy.contains(userId)
            
            if alreadyLiked {
                //unliking and removing user from likedBy and decrementing the count
                if let index = likedBy.firstIndex(of: userId) {
                    likedBy.remove(at: index)
                }
                transaction.updateData([
                    "likeCount": max(0, oldLikeCount - 1),
                    "likedBy": likedBy
                ], forDocument: chirpRef)
            } else {
                //liking and adding user to likedBy and increment count
                likedBy.append(userId)
                transaction.updateData([
                    "likeCount": oldLikeCount + 1,
                    "likedBy": likedBy
                ], forDocument: chirpRef)
            }
            
            return nil
        }) { [weak self] (_, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Error liking chirp: \(error.localizedDescription)"
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}
