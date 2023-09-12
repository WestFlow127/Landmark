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

struct LandmarkEntity: Identifiable, Equatable, Codable
{
    @DocumentID var id: String?
    
    var location: String?
    var description: String?
    var name: String
    var imageUrlPaths: [String]?
    var geoLocation: GeoPoint
    
    var _2DCoord: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: geoLocation.latitude, longitude: geoLocation.longitude)
    }
    
    init(name: String,
         id: String,
         location: String? = nil,
         description: String? = nil,
         imageUrlPaths: [String]? = nil,
         geoLocation: GeoPoint = GeoPoint(latitude: 0, longitude: 0))
    {
        self.id = id
        self.location = location
        self.description = description
        self.name = name
        self.imageUrlPaths = imageUrlPaths
        self.geoLocation = geoLocation
    }
    
    init(name: String) {
        self.name = name
        self.geoLocation = GeoPoint(latitude: 0, longitude: 0)
    }
}
