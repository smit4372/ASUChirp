// view for the quote
import SwiftUI

struct QuoteBannerView: View {
    let quote: NinjaQuote
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("“\(quote.quote)”")
                .font(.subheadline)
                .italic()
            
            Text("— \(quote.author)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
