import Foundation
import FirebaseFirestore
// WebAPI

class NinjaQuoteViewModel: ObservableObject {
    let apiKey = "83NDrqQP9MYOrku0lB/4qQ==PMJYHYhMIVRi3EZM"
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    func postDailyQuoteIfNeeded() {
        let lastPostDate = UserDefaults.standard.object(forKey: "lastQuotePostTime") as? Date
        let now = Date()
        let calendar = Calendar.current
        
        // if already posted or not
        if let lastPostDate = lastPostDate,
           calendar.isDate(lastPostDate, inSameDayAs: now) {
            return
        }
        
        // posting at morning 9 AM
        let components = calendar.dateComponents([.hour], from: now)
        if let hour = components.hour, hour >= 9 {
            fetchAndPostQuote()
            UserDefaults.standard.set(now, forKey: "lastQuotePostTime")
        }
    }
    
    
    // WebAPI calling and json parsing
    private func fetchAndPostQuote() {
        isLoading = true
        errorMessage = nil
        
        let url = URL(string: "https://api.api-ninjas.com/v1/quotes")!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to fetch quote: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received from API"
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode([NinjaQuote].self, from: data)
                    if let quote = decoded.first {
                        self.saveQuoteAsChirp(quote)
                    } else {
                        self.errorMessage = "No quotes returned from API"
                    }
                } catch {
                    self.errorMessage = "Quote decoding failed: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    // posting the recieved chirp as a chirp form official
    private func saveQuoteAsChirp(_ quote: NinjaQuote) {
        let db = Firestore.firestore()
        let quoteText = "💬 \(quote.quote)\n— \(quote.author)"
        
        // Checking if quote already there
        db.collection("chirps")
            .whereField("text", isEqualTo: quoteText)
            .whereField("userId", isEqualTo: "chirp-team")
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Error checking for duplicates: \(error.localizedDescription)"
                    return
                }
                
                // only posting if not duplicate
                if let snapshot = snapshot, snapshot.documents.isEmpty {
                    let chirpData: [String: Any] = [
                        "text": quoteText,
                        "timestamp": FieldValue.serverTimestamp(),
                        "username": "ChirpTeam",
                        "userId": "chirp-team",
                        "userEmail": "chirpteam@asu.edu",
                        "likeCount": 0,
                        "commentCount": 0,
                        "likedBy": []
                    ]
                    
                    db.collection("chirps").addDocument(data: chirpData) { error in
                        if let error = error {
                            self.errorMessage = "Error posting quote: \(error.localizedDescription)"
                        }
                    }
                }
            }
    }
}
