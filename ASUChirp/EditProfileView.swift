//Smit Desai
//Saanvi Patel

import SwiftUI
import FirebaseFirestore

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Display Name", text: $displayName)
                    
                    ZStack(alignment: .topLeading) {
                        if bio.isEmpty {
                            Text("Tell us about yourself...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $bio)
                            .frame(minHeight: 100)
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        updateProfile()
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                if let user = sessionViewModel.currentUser {
                    displayName = user.displayName ?? ""
                    bio = user.bio ?? ""
                }
            }
            .overlay(
                Group {
                    if isLoading {
                        Color.black.opacity(0.2)
                            .ignoresSafeArea()
                        
                        ProgressView()
                    }
                }
            )
        }
    }
    
    private func updateProfile() {
        isLoading = true
        errorMessage = nil
        
        sessionViewModel.updateProfile(displayName: displayName, bio: bio) { success in
            isLoading = false
            
            if success {
                presentationMode.wrappedValue.dismiss()
            } else {
                errorMessage = sessionViewModel.errorMessage
            }
        }
    }
}
