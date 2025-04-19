//
//  MapStyleExtensions.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//

import SwiftUI
import MapKit

// Custom enum to replace MapStyle for older iOS versions
enum CustomMapStyle: Int, Hashable {
    case standard
    case hybrid
    case satellite
    
    // Convert to MKMapType for actual map rendering
    var mapType: MKMapType {
        switch self {
        case .standard:
            return .standard
        case .hybrid:
            return .hybrid
        case .satellite:
            return .satellite
        }
    }
}
