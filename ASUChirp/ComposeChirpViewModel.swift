import Foundation
import FirebaseFirestore
import CoreLocation

class ComposeChirpViewModel: ObservableObject {
    @Published var chirpText = ""
    @Published var selectedLocation: ChirpLocation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    var characterCount: Int {
        return chirpText.count
    }
    
    var isValidChirp: Bool {
        return !chirpText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && chirpText.count <= 280
    }
    
    func postChirp(userId: String, username: String, userEmail: String, completion: @escaping (Bool) -> Void) {
        guard isValidChirp else {
            errorMessage = "Invalid chirp content"
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let chirp = Chirp(
            id: UUID().uuidString,
            userId: userId,
            username: username,
            userEmail: userEmail,
            text: chirpText,
            timestamp: Date(),
            location: selectedLocation,
            likeCount: 0,
            commentCount: 0,
            likedBy: []
        )
        
        db.collection("chirps").addDocument(data: chirp.toFirestore()) { [weak self] error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Error posting chirp: \(error.localizedDescription)"
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func setLocation(coordinate: CLLocationCoordinate2D, name: String) {
        selectedLocation = ChirpLocation.from(coordinate: coordinate, name: name)
    }
    
    func clearLocation() {
        selectedLocation = nil
    }
}
