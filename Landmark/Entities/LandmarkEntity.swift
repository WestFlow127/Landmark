//
//  LandmarkLocationEntity.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/20/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation

struct LandmarkEntity: Identifiable, Codable {
    @DocumentID var id: String?
    
    var location: String
    var description: String
    var name: String
    var geoLocation: GeoPoint
    var _2DCoord: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: geoLocation.latitude, longitude: geoLocation.longitude)
    }
    
}
