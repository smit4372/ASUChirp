import SwiftUI

struct CommentRowView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(comment.username)
                    .fontWeight(.medium)
                    .font(.subheadline)
                
                Spacer()
                
                Text(timeAgoSince(comment.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Text(comment.text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
    }
    
    // timeformating
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
