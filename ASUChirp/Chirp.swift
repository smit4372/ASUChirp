//
//  Chirp.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct Chirp: Identifiable {
    var id: String
    var userId: String
    var username: String
    var userEmail: String // Added to track which user posted the chirp
    var text: String
    var timestamp: Date
    var location: ChirpLocation?
    var likeCount: Int
    var commentCount: Int
    var likedBy: [String] // Array of user IDs who liked the chirp
    
    // Create from Firestore document
    static func fromFirestore(id: String, data: [String: Any]) -> Chirp? {
        guard
            let userId = data["userId"] as? String,
            let username = data["username"] as? String,
            let text = data["text"] as? String,
            let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
        else {
            return nil
        }
        
        // Extract user email (for filtering chirps by user)
        let userEmail = data["userEmail"] as? String ?? ""
        
        // Optional location
        var location: ChirpLocation? = nil
        if let locationData = data["location"] as? [String: Any],
           let latitude = locationData["latitude"] as? Double,
           let longitude = locationData["longitude"] as? Double,
           let name = locationData["name"] as? String {
            location = ChirpLocation(latitude: latitude, longitude: longitude, name: name)
        }
        
        // Get likes
        let likeCount = data["likeCount"] as? Int ?? 0
        
        // Get liked by array
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
    
    // Convert to Firestore document
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
    
    // Check if a user has liked this chirp
    func isLikedBy(userId: String) -> Bool {
        return likedBy.contains(userId)
    }
}
