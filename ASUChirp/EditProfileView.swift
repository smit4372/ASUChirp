//
//  EditProfileView.swift
//  ASUChirp
//
//  Created by Smit Desai on 3/29/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var displayName: String = ""
    @State private var bio: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display Name")) {
                    TextField("Enter your name", text: $displayName)
                }
                
                Section(header: Text("Bio")) {
                    TextField("Enter a short bio", text: $bio)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save the updated profile info to Firestore or local settings.
                        // For now, we dismiss.
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

