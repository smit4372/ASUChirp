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
    @StateObject private var likeViewModel = ChirpListViewModel()
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isLiked: Bool = false
    @State private var localLikeCount: Int = 0
    @State private var isSubmittingComment = false
    @State private var refreshID = UUID()
    
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
                                Button(action: {
                                    if let userId = sessionViewModel.currentUser?.id {
                                        // Toggle local state for immediate feedback
                                        isLiked.toggle()
                                        localLikeCount = isLiked ? localLikeCount + 1 : max(0, localLikeCount - 1)
                                        
                                        // Call API to update on server
                                        likeViewModel.likeChirp(chirpId: chirp.id, userId: userId) { _ in }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: isLiked ? "heart.fill" : "heart")
                                            .foregroundColor(.red)
                                        Text("\(localLikeCount)")
                                            .foregroundColor(.gray)
                                    }
                                    .frame(minWidth: 40)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
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
                        if commentViewModel.isLoading && commentViewModel.comments.isEmpty {
                            ProgressView()
                                .padding()
                        } else if commentViewModel.comments.isEmpty {
                            Text("No comments yet. Be the first to comment!")
                                .foregroundColor(.gray)
                                .italic()
                                .padding()
                                .id(refreshID) // Attach refresh ID
                        } else {
                            LazyVStack(alignment: .leading, spacing: 15) {
                                ForEach(commentViewModel.comments) { comment in
                                    CommentRowView(comment: comment)
                                }
                            }
                            .padding(.horizontal)
                            .id(refreshID) // Attach refresh ID
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
                            
                            isSubmittingComment = true
                            
                            commentViewModel.postComment(
                                userId: user.id,
                                username: user.displayName ?? user.email
                            ) { success in
                                isSubmittingComment = false
                                
                                if success {
                                    // Force UI refresh with new UUID
                                    refreshID = UUID()
                                }
                            }
                        }) {
                            if isSubmittingComment {
                                ProgressView()
                                    .frame(width: 30, height: 30)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        .disabled(commentViewModel.commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmittingComment)
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding()
                }
                
                // Show error messages
                if let errorMessage = commentViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                
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
