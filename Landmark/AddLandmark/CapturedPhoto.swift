//
//  CapturedPhoto.swift
//  Landmark
//

import CoreLocation
import UIKit

/// A photo from the camera plus the location embedded in its metadata, if any.
struct CapturedPhoto {
    let image: UIImage
    let metadataCoordinate: CLLocationCoordinate2D?

    init(image: UIImage, metadata: [AnyHashable: Any]? = nil) {
        self.image = image
        self.metadataCoordinate = Self.coordinate(fromMetadata: metadata)
    }

    /// Reads the "{GPS}" dictionary of the image's metadata (the same keys used in EXIF).
    private static func coordinate(fromMetadata metadata: [AnyHashable: Any]?) -> CLLocationCoordinate2D? {
        guard let gps = metadata?["{GPS}"] as? [String: Any],
              let latitude = (gps["Latitude"] as? NSNumber)?.doubleValue,
              let longitude = (gps["Longitude"] as? NSNumber)?.doubleValue
        else { return nil }

        // Coordinates are stored unsigned, with the hemisphere in a separate reference key.
        let signedLatitude = (gps["LatitudeRef"] as? String) == "S" ? -latitude : latitude
        let signedLongitude = (gps["LongitudeRef"] as? String) == "W" ? -longitude : longitude
        let coordinate = CLLocationCoordinate2D(latitude: signedLatitude, longitude: signedLongitude)

        return CLLocationCoordinate2DIsValid(coordinate) ? coordinate : nil
    }
}
