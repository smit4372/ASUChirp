//
//  ChirpDetailView.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//

import SwiftUI

struct ChirpDetailView: View {
    let chirp: Chirp
    @StateObject private var commentViewModel: CommentViewModel
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(chirp: Chirp) {
        self.chirp = chirp
        self._commentViewModel = StateObject(wrappedValue: CommentViewModel(chirpId: chirp.id))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Original Chirp
                        VStack(alignment: .leading, spacing: 12) {
                            // User Info
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                
                                Text(chirp.username)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text(formatDate(chirp.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            // Chirp Content
                            Text(chirp.text)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            // Location if available
                            if let location = chirp.location {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.red)
                                    Text(location.name)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            // Engagement Stats
                            HStack(spacing: 20) {
                                HStack {
                                    Image(systemName: "heart")
                                        .foregroundColor(.red)
                                    Text("\(chirp.likeCount)")
                                        .foregroundColor(.gray)
                                }
                                .frame(minWidth: 40)
                                
                                HStack {
                                    Image(systemName: "bubble.left")
                                        .foregroundColor(.blue)
                                    Text("\(chirp.commentCount)")
                                        .foregroundColor(.gray)
                                }
                                .frame(minWidth: 40)
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        // Divider with "Comments" label
                        HStack {
                            VStack {
                                Divider()
                            }
                            
                            Text("Comments")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            VStack {
                                Divider()
                            }
                        }
                        .padding(.horizontal)
                        
                        // Comments
                        if commentViewModel.isLoading {
                            ProgressView()
                        } else if commentViewModel.comments.isEmpty {
                            Text("No comments yet. Be the first to comment!")
                                .foregroundColor(.gray)
                                .italic()
                                .padding()
                        } else {
                            LazyVStack(alignment: .leading, spacing: 15) {
                                ForEach(commentViewModel.comments) { comment in
                                    CommentRowView(comment: comment)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                
                // Comment Input
                VStack {
                    Divider()
                    
                    HStack {
                        TextField("Add a comment...", text: $commentViewModel.commentText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            guard let user = sessionViewModel.currentUser else { return }
                            
                            commentViewModel.postComment(
                                userId: user.id,
                                username: user.displayName ?? user.email
                            ) { _ in }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(commentViewModel.commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || commentViewModel.isLoading)
                    }
                    .padding()
                }
            }
            .navigationTitle("Chirp Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                commentViewModel.fetchComments()
            }
        }
    }
    
    // Helper function to format date
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
