//
//  ChirpRowView.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//

import SwiftUI

struct ChirpRowView: View {
    let chirp: Chirp
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @StateObject private var viewModel = ChirpListViewModel()
    @State private var isLiked: Bool = false
    @State private var localLikeCount: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // User Info
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text(chirp.username)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Spacer()
                
                Text(timeAgoSince(chirp.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Chirp Content
            Text(chirp.text)
                .lineLimit(6)
                .fixedSize(horizontal: false, vertical: true)
            
            // Location if available
            if let location = chirp.location {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.red)
                    Text(location.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            // Engagement Stats - Fixed width to prevent layout issues
            HStack(spacing: 20) {
                Button(action: {
                    if let userId = sessionViewModel.currentUser?.id {
                        // Toggle local state for immediate feedback
                        isLiked.toggle()
                        localLikeCount = isLiked ? localLikeCount + 1 : max(0, localLikeCount - 1)
                        
                        // Call API to update on server
                        viewModel.likeChirp(chirpId: chirp.id, userId: userId) { _ in }
                    }
                }) {
                    HStack {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                        Text("\(localLikeCount)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(minWidth: 40)
                }
                
                HStack {
                    Image(systemName: "bubble.left")
                        .foregroundColor(.blue)
                    Text("\(chirp.commentCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(minWidth: 40)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .onAppear {
            // Initialize like state and count from the chirp data
            if let userId = sessionViewModel.currentUser?.id {
                isLiked = chirp.likedBy.contains(userId)
            }
            localLikeCount = chirp.likeCount
        }
    }
    
    // Helper function to format time
    private func timeAgoSince(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "Yesterday" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) hr ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) min ago"
        } else {
            return "Just now"
        }
    }
}
