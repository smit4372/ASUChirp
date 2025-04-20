//Smit Desai
//Saanvi Patel

import Foundation
import FirebaseFirestore

struct Comment: Identifiable {
    var id: String
    var chirpId: String
    var userId: String
    var username: String
    var text: String
    var timestamp: Date
    
    //firestore document
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
    
    // Converting to firestore document
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
