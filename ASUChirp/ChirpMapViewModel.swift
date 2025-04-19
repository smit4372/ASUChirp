//
//  ChirpMapViewModel.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//

import Foundation
import FirebaseFirestore
import MapKit
import Combine

class ChirpMapViewModel: ObservableObject {
    @Published var chirps: [Chirp] = []
    @Published var region: MKCoordinateRegion
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedChirp: Chirp?
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // Initialize with ASU Tempe campus as default
    init(coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 33.4242399, longitude: -111.9280527)) {
        self.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    func fetchChirpsWithLocation() {
        isLoading = true
        errorMessage = nil
        
        // Use NSNull() instead of nil for Firestore queries
        listener = db.collection("chirps")
            .whereField("location", isNotEqualTo: NSNull())
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
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
                }.filter { $0.location != nil }
            }
    }
    
    func selectChirp(_ chirp: Chirp) {
        selectedChirp = chirp
        
        if let location = chirp.location {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    deinit {
        listener?.remove()
    }
}
