//Smit Desai
//Saanvi Patel

// search functionalities
import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedChirp: Chirp? = nil
    @State private var showChirpDetail = false
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // searching bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search chirps or users", text: $viewModel.searchText)
                        .autocapitalization(.none) // stopping the auto capitalization
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                // result output
                if !viewModel.searchText.isEmpty {
                    HStack {
                        if viewModel.formattedSearchText.isEmpty {
                            Text("Recent Chirps")
                                .font(.headline)
                                .padding(.leading)
                        } else {
                            Text("Results for \"\(viewModel.formattedSearchText)\"")
                                .font(.headline)
                                .padding(.leading)
                        }
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.bottom, 5)
                }
                
                // resulting view
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                    Text("Searching...")
                        .foregroundColor(.gray)
                    Spacer()
                } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 64))
                            .foregroundColor(.gray.opacity(0.7))
                            .padding()
                        
                        Text("No results found")
                            .font(.headline)
                        
                        Text("Try different keywords or check for typos")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else if !viewModel.searchText.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.searchResults) { chirp in
                                ChirpRowView(chirp: chirp)
                                    .environmentObject(sessionViewModel)
                                    .onTapGesture {
                                        selectedChirp = chirp
                                        showChirpDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // suggestions for the search
                    VStack(spacing: 24) {
                        Text("Search for chirps, users, or topics")
                            .font(.headline)
                            .padding(.top, 30)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SearchSuggestionRow(icon: "person.fill", text: "Try searching for a username")
                            SearchSuggestionRow(icon: "number", text: "Try searching for a hashtag")
                            SearchSuggestionRow(icon: "magnifyingglass", text: "Try searching for keywords")
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showChirpDetail, onDismiss: {
                selectedChirp = nil
            }) {
                if let chirp = selectedChirp {
                    ChirpDetailView(chirp: chirp)
                }
            }
        }
    }
}

struct SearchSuggestionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}
