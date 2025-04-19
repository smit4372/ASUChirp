//
//  HomeFeedView.swift
//  ASUChirp
//
//  Created by Smit Desai on 3/29/25.
//

import SwiftUI
import FirebaseFirestore

struct HomeFeedView: View {
    @StateObject private var viewModel = ChirpListViewModel()
    @State private var showingComposeView = false
    @State private var selectedChirp: Chirp? = nil
    @State private var showChirpDetail = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                if viewModel.isLoading && viewModel.chirps.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.chirps.isEmpty {
                    VStack {
                        Text("No chirps yet!")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Be the first to post something!")
                            .foregroundColor(.gray)
                            .padding(.top, 5)
                        
                        Button(action: {
                            showingComposeView = true
                        }) {
                            Text("Create a Chirp")
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.top)
                    }
                } else {
                    List {
                        ForEach(viewModel.chirps) { chirp in
                            ChirpRowView(chirp: chirp)
                                .onTapGesture {
                                    selectedChirp = chirp
                                    showChirpDetail = true
                                }
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.fetchChirps()
                    }
                }
                
                // Compose Button
                Button(action: {
                    showingComposeView = true
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("ASU Chirp")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingComposeView) {
                ComposeChirpView()
            }
            .sheet(isPresented: $showChirpDetail, onDismiss: {
                selectedChirp = nil
            }) {
                if let chirp = selectedChirp {
                    ChirpDetailView(chirp: chirp)
                }
            }
            .onAppear {
                viewModel.fetchChirps()
            }
        }
    }
}
