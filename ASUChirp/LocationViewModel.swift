import Foundation
import MapKit
import Combine

class LocationViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion
    @Published var selectedName: String = ""
    @Published var searchResults: [MKMapItem] = []
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // starting from tempe campus
    init(coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 33.4242399, longitude: -111.9280527)) {
        self.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    func search(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Search error: \(error.localizedDescription)"
                return
            }
            
            if let response = response {
                self.searchResults = response.mapItems
            }
        }
    }
    
    func selectLocation(mapItem: MKMapItem) {
        region = MKCoordinateRegion(
            center: mapItem.placemark.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        selectedName = mapItem.name ?? "Selected Location"
    }
    
    func getLocationName(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Geocoding error: \(error.localizedDescription)"
                self.selectedName = "Unknown Location"
                return
            }
            
            if let placemark = placemarks?.first {
                let name = [
                    placemark.name,
                    placemark.thoroughfare,
                    placemark.locality
                ].compactMap { $0 }.first ?? "Selected Location"
                
                self.selectedName = name
            } else {
                self.selectedName = "Selected Location"
            }
        }
    }
}
