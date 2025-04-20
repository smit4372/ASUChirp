//
//  ChirpLocation.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//


// ChirpLocation.swift
import Foundation
import CoreLocation

struct ChirpLocation {
    var latitude: Double
    var longitude: Double
    var name: String
    
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Creating location
    static func from(coordinate: CLLocationCoordinate2D, name: String) -> ChirpLocation {
        return ChirpLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            name: name
        )
    }
}
