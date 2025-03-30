//
//  ComposeChirpView.swift
//  ASUChirp
//
//  Created by Smit Desai on 3/29/25.
//

import SwiftUI
import FirebaseFirestore
import MapKit

struct ComposeChirpView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var chirpText: String = ""
    @State private var selectedLocation: String? = nil
    @State private var showLocationPicker = false
    @State private var errorMessage: String = ""
    
    // Firestore reference
    let db = Firestore.firestore()
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $chirpText)
                    .padding()
                    .frame(height: 150)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .onChange(of: chirpText) { newValue in
                        // Limit to 280 characters
                        if newValue.count > 280 {
                            chirpText = String(newValue.prefix(280))
                        }
                    }
                
                HStack {
                    Text("Characters: \(chirpText.count)/280")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    if let location = selectedLocation {
                        Text("Location: \(location)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                Button(action: {
                    showLocationPicker = true
                }) {
                    Text(selectedLocation == nil ? "Tag Location" : "Change Location")
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.vertical)
                .sheet(isPresented: $showLocationPicker) {
                    LocationPickerView(selectedLocation: $selectedLocation)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Compose Chirp")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        postChirp()
                    }
                    .disabled(chirpText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    func postChirp() {
        // Prepare chirp data
        var chirpData: [String: Any] = [
            "text": chirpText,
            "timestamp": FieldValue.serverTimestamp(),
            // You can add more fields, e.g., current user's username
        ]
        if let location = selectedLocation {
            chirpData["location"] = location
        }
        
        db.collection("chirps").addDocument(data: chirpData) { error in
            if let error = error {
                errorMessage = "Error posting chirp: \(error.localizedDescription)"
            } else {
                // On success, dismiss view
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
