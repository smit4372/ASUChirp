import SwiftUI
import MapKit

struct ComposeChirpView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = ComposeChirpViewModel()
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @State private var showLocationPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                // char counting and message
                HStack {
                    Spacer()
                    Text("\(viewModel.characterCount)/280")
                        .font(.caption)
                        .foregroundColor(viewModel.characterCount > 270 ? .red : .gray)
                        .padding(.trailing)
                }
                
                // input area
                ZStack(alignment: .topLeading) {
                    if viewModel.chirpText.isEmpty {
                        Text("What's happening on campus?")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.top, 8)
                    }
                    
                    TextEditor(text: $viewModel.chirpText)
                        .padding(4)
                        .onChange(of: viewModel.chirpText) { newValue in
                            // max of 280 chars
                            if newValue.count > 280 {
                                viewModel.chirpText = String(newValue.prefix(280))
                            }
                        }
                }
                .frame(height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // tagging the location
                if let location = viewModel.selectedLocation {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.red)
                        Text(location.name)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.clearLocation()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                // button
                Button(action: {
                    showLocationPicker = true
                }) {
                    HStack {
                        Image(systemName: "mappin")
                        Text(viewModel.selectedLocation == nil ? "Tag Location" : "Change Location")
                    }
                    .padding()
                    .foregroundColor(.blue)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Compose Chirp")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        guard let user = sessionViewModel.currentUser else { return }
                        
                        viewModel.postChirp(
                            userId: user.id,
                            username: user.displayName ?? user.email.components(separatedBy: "@").first ?? "ASU Student",
                            userEmail: user.email
                        ) { success in
                            if success {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isValidChirp || viewModel.isLoading)
                }
            }
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerView(onLocationSelected: { coordinate, name in
                    viewModel.setLocation(coordinate: coordinate, name: name)
                })
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        Color.black.opacity(0.2)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                }
            )
        }
    }
}
