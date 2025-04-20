import Foundation
import FirebaseFirestore
import CoreLocation

struct Chirp: Identifiable {
    var id: String
    var userId: String
    var username: String
    var userEmail: String // to track user posting the chirp
    var text: String
    var timestamp: Date
    var location: ChirpLocation?
    var likeCount: Int
    var commentCount: Int
    var likedBy: [String] // likedby
    
    
    static func fromFirestore(id: String, data: [String: Any]) -> Chirp? {
        guard
            let userId = data["userId"] as? String,
            let username = data["username"] as? String,
            let text = data["text"] as? String,
            let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
        else {
            return nil
        }
        
        
        let userEmail = data["userEmail"] as? String ?? ""
        
        // keeping location optional
        var location: ChirpLocation? = nil
        if let locationData = data["location"] as? [String: Any],
           let latitude = locationData["latitude"] as? Double,
           let longitude = locationData["longitude"] as? Double,
           let name = locationData["name"] as? String {
            location = ChirpLocation(latitude: latitude, longitude: longitude, name: name)
        }
        
        // number of likes
        let likeCount = data["likeCount"] as? Int ?? 0
        
        // liked by
        let likedBy = data["likedBy"] as? [String] ?? []
        
        return Chirp(
            id: id,
            userId: userId,
            username: username,
            userEmail: userEmail,
            text: text,
            timestamp: timestamp,
            location: location,
            likeCount: likeCount,
            commentCount: data["commentCount"] as? Int ?? 0,
            likedBy: likedBy
        )
    }
    
    // converting to firestore document
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "userId": userId,
            "username": username,
            "userEmail": userEmail,
            "text": text,
            "timestamp": FieldValue.serverTimestamp(),
            "likeCount": likeCount,
            "commentCount": commentCount,
            "likedBy": likedBy
        ]
        
        if let location = location {
            data["location"] = [
                "latitude": location.latitude,
                "longitude": location.longitude,
                "name": location.name
            ]
        }
        
        return data
    }
    
    // if user has already liked a chirp
    func isLikedBy(userId: String) -> Bool {
        return likedBy.contains(userId)
    }
}
