//
//  ProfileView.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//
//
//import SwiftUI
//
//struct ProfileView: View {
//    @EnvironmentObject var sessionViewModel: SessionViewModel
//    @StateObject private var viewModel = ChirpListViewModel()
//    @State private var showEditProfile = false
//    @State private var selectedChirp: Chirp? = nil
//    @State private var showChirpDetail = false
//    
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(spacing: 20) {
//                    // Profile Header
//                    VStack(spacing: 15) {
//                        Image(systemName: "person.circle.fill")
//                            .font(.system(size: 80))
//                            .foregroundColor(.blue)
//                        
//                        Text(sessionViewModel.currentUser?.displayName ?? "ASU Student")
//                            .font(.title)
//                            .bold()
//                        
//                        if let bio = sessionViewModel.currentUser?.bio, !bio.isEmpty {
//                            Text(bio)
//                                .font(.body)
//                                .multilineTextAlignment(.center)
//                                .padding(.horizontal)
//                        }
//                        
//                        Button(action: {
//                            showEditProfile = true
//                        }) {
//                            Text("Edit Profile")
//                                .padding(.horizontal, 16)
//                                .padding(.vertical, 8)
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(20)
//                        }
//                        .padding(.top, 5)
//                    }
//                    .padding()
//                    .background(Color(UIColor.secondarySystemBackground))
//                    .cornerRadius(12)
//                    .padding(.horizontal)
//                    
//                    // My Chirps Section
//                    VStack(alignment: .leading) {
//                        Text("My Chirps")
//                            .font(.headline)
//                            .padding(.leading)
//                        
//                        if viewModel.isLoading {
//                            HStack {
//                                Spacer()
//                                ProgressView()
//                                Spacer()
//                            }
//                            .padding()
//                        } else if viewModel.chirps.isEmpty {
//                            HStack {
//                                Spacer()
//                                Text("You haven't posted any chirps yet")
//                                    .foregroundColor(.gray)
//                                    .italic()
//                                Spacer()
//                            }
//                            .padding()
//                        } else {
//                            LazyVStack(spacing: 12) {
//                                ForEach(viewModel.chirps) { chirp in
//                                    ChirpRowView(chirp: chirp)
//                                        .onTapGesture {
//                                            selectedChirp = chirp
//                                            showChirpDetail = true
//                                        }
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                    }
//                }
//                .padding(.vertical)
//            }
//            .navigationTitle("My Profile")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: SettingsView()) {
//                        Image(systemName: "gear")
//                    }
//                }
//            }
//            .sheet(isPresented: $showEditProfile) {
//                EditProfileView()
//            }
//            .sheet(isPresented: $showChirpDetail, onDismiss: {
//                selectedChirp = nil
//            }) {
//                if let chirp = selectedChirp {
//                    ChirpDetailView(chirp: chirp)
//                }
//            }
//            .onAppear {
//                // Filter chirps to only show the current user's
//                if let userId = sessionViewModel.currentUser?.id {
//                    viewModel.fetchChirps()
//                }
//            }
//        }
//    }
//}

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @StateObject private var viewModel = ChirpListViewModel()
    @State private var showEditProfile = false
    @State private var selectedChirp: Chirp? = nil
    @State private var showChirpDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text(sessionViewModel.currentUser?.displayName ?? "ASU Student")
                            .font(.title)
                            .bold()
                        
                        if let bio = sessionViewModel.currentUser?.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Button(action: {
                            showEditProfile = true
                        }) {
                            Text("Edit Profile")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        .padding(.top, 5)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // My Chirps Section
                    VStack(alignment: .leading) {
                        Text("My Chirps")
                            .font(.headline)
                            .padding(.leading)
                        
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding()
                        } else if viewModel.chirps.isEmpty {
                            HStack {
                                Spacer()
                                Text("You haven't posted any chirps yet")
                                    .foregroundColor(.gray)
                                    .italic()
                                Spacer()
                            }
                            .padding()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.chirps) { chirp in
                                    ChirpRowView(chirp: chirp)
                                        .onTapGesture {
                                            selectedChirp = chirp
                                            showChirpDetail = true
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showChirpDetail, onDismiss: {
                selectedChirp = nil
            }) {
                if let chirp = selectedChirp {
                    ChirpDetailView(chirp: chirp)
                }
            }
            .onAppear {
                // Filter chirps to only show the current user's
                if let userId = sessionViewModel.currentUser?.id {
                    // Enable filtering by user ID
                    viewModel.filterByUser = true
                    viewModel.currentUserId = userId
                    viewModel.fetchChirps()
                }
            }
        }
    }
}
