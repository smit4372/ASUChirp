//
//  NinjaQuoteViewModel.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/19/25.
//

import Foundation
import FirebaseFirestore

class NinjaQuoteViewModel: ObservableObject {
    let apiKey = "83NDrqQP9MYOrku0lB/4qQ==PMJYHYhMIVRi3EZM"
    
    func postDailyQuoteIfNeeded() {
        let lastPostDate = UserDefaults.standard.object(forKey: "lastQuotePostTime") as? Date
        let now = Date()
        
        if lastPostDate == nil || now.timeIntervalSince(lastPostDate!) > 86400 {
            fetchAndPostQuote()
            UserDefaults.standard.set(now, forKey: "lastQuotePostTime")
        }
    }
    private func fetchAndPostQuote() {
        let url = URL(string: "https://api.api-ninjas.com/v1/quotes")!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let decoded = try JSONDecoder().decode([NinjaQuote].self, from: data)
                if let quote = decoded.first {
                    self.saveQuoteAsChirp(quote)
                }
            } catch {
                    print("Quote decoding failed: \(error)")
                }
        }.resume()
    }
    
    private func saveQuoteAsChirp(_ quote: NinjaQuote) {
        let db = Firestore.firestore()
        let quoteText = "💬 \(quote.quote)\n— \(quote.author)"
        let chirpData: [String: Any] = [
            "text": quoteText,
            "timestamp": Timestamp(date: Date()),
            "username": "ChirpTeam",
            "userId": "chirp-team",
            "likeCount": 0,
            "commentCount": 0,
            "likedBy": []
        ]
        db.collection("chirps").addDocument(data: chirpData)
    }
}
