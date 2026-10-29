//
//  CapturedPhotoTests.swift
//  LandmarkTests
//

import Testing
import UIKit

@testable import Landmark

struct CapturedPhotoTests {
    private func photo(gps: [String: Any]?) -> CapturedPhoto {
        let metadata: [AnyHashable: Any]? = gps.map { ["{GPS}": $0] }
        return CapturedPhoto(image: UIImage(), metadata: metadata)
    }

    @Test func noMetadataGivesNoCoordinate() {
        #expect(CapturedPhoto(image: UIImage()).metadataCoordinate == nil)
    }

    @Test func metadataWithoutGPSGivesNoCoordinate() {
        let photo = CapturedPhoto(image: UIImage(), metadata: ["{TIFF}": [:]])

        #expect(photo.metadataCoordinate == nil)
    }

    @Test func northEastCoordinateStaysPositive() {
        let coordinate = self.photo(gps: [
            "Latitude": 33.99, "LatitudeRef": "N",
            "Longitude": 118.46, "LongitudeRef": "E",
        ]).metadataCoordinate

        #expect(coordinate?.latitude == 33.99)
        #expect(coordinate?.longitude == 118.46)
    }

    @Test func southWestReferencesNegateCoordinate() {
        let coordinate = self.photo(gps: [
            "Latitude": 33.99, "LatitudeRef": "S",
            "Longitude": 118.46, "LongitudeRef": "W",
        ]).metadataCoordinate

        #expect(coordinate?.latitude == -33.99)
        #expect(coordinate?.longitude == -118.46)
    }

    @Test func missingLongitudeGivesNoCoordinate() {
        #expect(self.photo(gps: ["Latitude": 33.99]).metadataCoordinate == nil)
    }

    @Test func outOfRangeCoordinateIsRejected() {
        let coordinate = self.photo(gps: [
            "Latitude": 123.0, "LatitudeRef": "N",
            "Longitude": 10.0, "LongitudeRef": "E",
        ]).metadataCoordinate

        #expect(coordinate == nil)
    }
}
