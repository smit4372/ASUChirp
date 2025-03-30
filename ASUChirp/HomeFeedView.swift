//
//  HomeFeedView.swift
//  ASUChirp
//
//  Created by Smit Desai on 3/29/25.
//


import SwiftUI
import FirebaseFirestore

struct Chirp: Identifiable {
    var id: String
    var username: String
    var text: String
    var timestamp: Date
}

class ChirpViewModel: ObservableObject {
    @Published var chirps: [Chirp] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchChirps()
    }
    
    func fetchChirps() {
        db.collection("chirps")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents in chirps collection")
                    return
                }
                self.chirps = documents.compactMap { queryDocumentSnapshot -> Chirp? in
                    let data = queryDocumentSnapshot.data()
                    guard let username = data["username"] as? String,
                          let text = data["text"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        return nil
                    }
                    return Chirp(id: queryDocumentSnapshot.documentID,
                                 username: username,
                                 text: text,
                                 timestamp: timestamp.dateValue())
                }
            }
    }
}

struct HomeFeedView: View {
    @StateObject var viewModel = ChirpViewModel()
    @State private var showingCompose = false

    var body: some View {
        NavigationView {
            List(viewModel.chirps) { chirp in
                VStack(alignment: .leading) {
                    Text(chirp.username)
                        .font(.headline)
                    Text(chirp.text)
                    Text(chirp.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Chirp Feed")
//            .navigationBarItems(trailing:
//                NavigationLink(destination: SettingsView()) {
//                    Image(systemName: "gear")
//                }
//            )
            .toolbar {
                // Compose button in the top-right corner
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCompose = true
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
                // Settings button
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingCompose) {
                ComposeChirpView()
            }
        }
    }
}

