//Smit Desai
//Saanvi Patel

import SwiftUI
import MapKit
// for styling map
enum CustomMapStyle: Int, Hashable {
    case standard
    case hybrid
    case satellite
    
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
