//
//  Comment.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//

// Comment.swift
import Foundation
import FirebaseFirestore

struct Comment: Identifiable {
    var id: String
    var chirpId: String
    var userId: String
    var username: String
    var text: String
    var timestamp: Date
    
    // Create from Firestore document
    static func fromFirestore(id: String, data: [String: Any]) -> Comment? {
        guard
            let chirpId = data["chirpId"] as? String,
            let userId = data["userId"] as? String,
            let username = data["username"] as? String,
            let text = data["text"] as? String,
            let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
        else {
            return nil
        }
        
        return Comment(
            id: id,
            chirpId: chirpId,
            userId: userId,
            username: username,
            text: text,
            timestamp: timestamp
        )
    }
    
    // Convert to Firestore document
    func toFirestore() -> [String: Any] {
        return [
            "chirpId": chirpId,
            "userId": userId,
            "username": username,
            "text": text,
            "timestamp": FieldValue.serverTimestamp()
        ]
    }
}
