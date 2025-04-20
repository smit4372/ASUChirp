import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = LocationViewModel()
    @State private var searchText = ""
    
    var onLocationSelected: (CLLocationCoordinate2D, String) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                // searching
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search for a location", text: $searchText)
                        .onChange(of: searchText) { newValue in
                            if !newValue.isEmpty {
                                viewModel.search(query: newValue)
                            }
                        }
                        .autocapitalization(.words)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            viewModel.searchResults = []
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
                
                // Searching result map
                if !viewModel.searchResults.isEmpty {
                    List {
                        ForEach(viewModel.searchResults, id: \.self) { item in
                            Button(action: {
                                viewModel.selectLocation(mapItem: item)
                                searchText = ""
                                viewModel.searchResults = []
                            }) {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "Unnamed Location")
                                        .font(.headline)
                                    
                                    if let address = item.placemark.formattedAddress {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else {
                    // map view
                    ZStack {
                        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                            .edgesIgnoringSafeArea(.bottom)
                            .gesture(
                                TapGesture()
                                    .onEnded { _ in
                                        // When tapped, get location name for the center coordinate
                                        viewModel.getLocationName(for: viewModel.region.center)
                                    }
                            )
                        
                        // center
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                        
                        // selecting the loaction
                        VStack {
                            Spacer()
                            
                            Text(viewModel.selectedName)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                                .padding()
                                .shadow(radius: 2)
                        }
                    }
                }
            }
            .navigationTitle("Pick a Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Select") {
                        onLocationSelected(viewModel.region.center, viewModel.selectedName)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
