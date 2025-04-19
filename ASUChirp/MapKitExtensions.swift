//
//  MapKitExtensions.swift
//  ASUChirp
//
//  Created by Smit Desai on 4/17/25.
//

import MapKit

extension MKPlacemark {
    var formattedAddress: String? {
        if let subThoroughfare = subThoroughfare {
            var result = subThoroughfare
            
            if let thoroughfare = thoroughfare {
                result += " " + thoroughfare
            }
            
            if let locality = locality {
                result += ", " + locality
            }
            
            if let administrativeArea = administrativeArea {
                result += ", " + administrativeArea
            }
            
            return result
        }
        
        return nil
    }
}
