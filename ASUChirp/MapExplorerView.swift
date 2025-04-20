//Smit Desai
//Saanvi Patel

import SwiftUI
import MapKit

struct MapExplorerView: View {
    @StateObject private var viewModel = ChirpMapViewModel()
    @State private var showDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    annotationItems: viewModel.chirps.filter { $0.location != nil }) { chirp in
                    MapAnnotation(coordinate: chirp.location!.coordinate) {
                        Button(action: {
                            viewModel.selectChirp(chirp)
                            showDetail = true
                        }) {
                            VStack {
                                Image(systemName: "bubble.left.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                Text(chirp.username)
                                    .font(.caption2)
                                    .fixedSize()
                                    .foregroundColor(.primary)
                                    .padding(4)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                .colorScheme(.light)
                .overlay(
                    Color.clear
                )
                VStack {
                    Spacer()
                    
                    if let selectedChirp = viewModel.selectedChirp {
                        // chirp selected preview on bottom
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.headline)
                                
                                Text(selectedChirp.username)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Text(timeAgoSince(selectedChirp.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Text(selectedChirp.text)
                                .lineLimit(3)
                            
                            if let location = selectedChirp.location {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.red)
                                    Text(location.name)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            HStack {
                                Spacer()
                                
                                Button("View Details") {
                                    showDetail = true
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding()
                    }
                }
            }
            .navigationTitle("Campus Map")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchChirpsWithLocation()
            }
            .sheet(isPresented: $showDetail) {
                if let chirp = viewModel.selectedChirp {
                    ChirpDetailView(chirp: chirp)
                }
            }
        }
    }
    
    // formatiing time
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
            return "Justt now"
        }
    }
}
