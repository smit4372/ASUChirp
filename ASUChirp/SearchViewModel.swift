//
//  SearchViewModel.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//

import Foundation
import FirebaseFirestore
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Chirp] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var formattedSearchText = ""
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchPublisher()
    }
    
    private func setupSearchPublisher() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { text in
                // Keep original capitalization for display
                self.formattedSearchText = text
                // Return lowercase for searching
                return text.lowercased()
            }
            .filter { !$0.isEmpty }
            .sink { [weak self] searchTerm in
                self?.performSearch(searchTerm: searchTerm)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(searchTerm: String) {
        isLoading = true
        errorMessage = nil
        
        // Firebase doesn't support native text search, so we'll do a simple contains query
        // In a real app, you might use Algolia or a similar search service
        
        db.collection("chirps")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error searching: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    self.errorMessage = "No chirps found"
                    return
                }
                
                // Client-side filtering for text content
                self.searchResults = documents.compactMap { document -> Chirp? in
                    let id = document.documentID
                    let data = document.data()
                    guard let chirp = Chirp.fromFirestore(id: id, data: data) else {
                        return nil
                    }
                    
                    // Check if text contains search term (case insensitive)
                    if chirp.text.lowercased().contains(searchTerm) ||
                       chirp.username.lowercased().contains(searchTerm) {
                        return chirp
                    }
                    
                    return nil
                }
            }
    }
}
