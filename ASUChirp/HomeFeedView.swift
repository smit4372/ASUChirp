import SwiftUI
import FirebaseFirestore

struct HomeFeedView: View {
    @StateObject private var viewModel = ChirpListViewModel()
    @StateObject private var quoteVM = NinjaQuoteViewModel()
    @State private var showingComposeView = false
    @State private var selectedChirp: Chirp? = nil
    @State private var showChirpDetail = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: 10) {
                    
                    if viewModel.isLoading && viewModel.chirps.isEmpty {
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                    } else if viewModel.chirps.isEmpty {
                        Text("No chirps yet.")
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack {
                                ForEach(viewModel.chirps) { chirp in
                                    ChirpRowView(chirp: chirp)
                                        .onTapGesture {
                                            selectedChirp = chirp
                                            showChirpDetail = true
                                        }
                                }
                            }
                        }
                    }
                }
                
                Button(action: {
                    showingComposeView = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding()
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showingComposeView) {
                ComposeChirpView()
            }
            .sheet(isPresented: $showChirpDetail) {
                if let selected = selectedChirp {
                    ChirpDetailView(chirp: selected)
                }
            }
            .onAppear {
                viewModel.fetchChirps()
                quoteVM.postDailyQuoteIfNeeded()
            }
        }
    }
}
