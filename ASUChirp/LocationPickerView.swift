//
//  LocationPickerView.swift
//  ASUChirp
//
//  Created by Smit Desai on 3/29/25.
//

import SwiftUI
import MapKit

struct CoordinateWrapper: Identifiable {
    let id = UUID()  // Generates a unique identifier
    let coordinate: CLLocationCoordinate2D
}

struct LocationPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedLocation: String?
    
    // Initial region centered on a default coordinate (e.g., ASU campus)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.4242399, longitude: -111.9280527),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // Store the tapped coordinate
    @State private var tappedCoordinate: CLLocationCoordinate2D?
    
    var body: some View {
        NavigationView {
            ZStack {

                Map(
                    coordinateRegion: $region,
                    annotationItems: tappedCoordinate.map { [ CoordinateWrapper(coordinate: $0) ] } ?? []
                ) { item in
                    MapMarker(coordinate: item.coordinate)
                }
                .ignoresSafeArea()
                .onTapGesture { location in
                    tappedCoordinate = region.center
                }
                
                VStack {
                    Spacer()
                    if let coord = tappedCoordinate {
                        Text("Selected: (\(coord.latitude.formatted()), \(coord.longitude.formatted()))")
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Pick a Location")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Select") {
                        if let coord = tappedCoordinate {
                            selectedLocation = "(\(coord.latitude.formatted()), \(coord.longitude.formatted()))"
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
