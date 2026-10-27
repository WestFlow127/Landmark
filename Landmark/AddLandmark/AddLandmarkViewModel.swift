//
//  AddLandmarkViewModel.swift
//  Landmark
//

import CoreLocation
import FirebaseFirestore
import UIKit

@MainActor
final class AddLandmarkViewModel: ObservableObject {
    static let unknownAddress = "Unknown"

    let croppedImage: UIImage

    @Published var title = ""
    @Published var landmarkDescription = ""
    @Published private(set) var coordinate: CLLocationCoordinate2D?
    @Published private(set) var address: String?
    @Published private(set) var isLoadingLocation = true
    @Published private(set) var isUploading = false
    @Published private(set) var didUpload = false
    @Published var uploadErrorMessage: String?

    private let locationFetcher: any LocationProviding
    private let landmarkProvider: any LandmarkProviding

    var addressText: String {
        self.address ?? Self.unknownAddress
    }

    var canUpload: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !self.landmarkDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && self.coordinate != nil
    }

    private let metadataCoordinate: CLLocationCoordinate2D?

    /// Location capture starts immediately so it reflects where the photo was taken.
    init(
        capturedPhoto: CapturedPhoto,
        landmarkProvider: any LandmarkProviding = LandmarkFirestoreProvider(),
        locationFetcher: any LocationProviding = LocationFetcher()
    ) {
        self.landmarkProvider = landmarkProvider
        self.locationFetcher = locationFetcher
        self.croppedImage = capturedPhoto.image.croppedToSquare()
        self.metadataCoordinate = capturedPhoto.metadataCoordinate

        Task { await self.loadLocation() }
    }

    /// Prefers the device's current location, falls back to the photo's metadata, and otherwise
    /// leaves `coordinate` nil so the view can show an error.
    private func loadLocation() async {
        defer { self.isLoadingLocation = false }

        if let location = await self.locationFetcher.currentLocation() {
            self.coordinate = location.coordinate
            self.address = await self.locationFetcher.address(for: location)
        } else if let metadataCoordinate {
            self.coordinate = metadataCoordinate
            self.address = await self.locationFetcher.address(
                for: CLLocation(latitude: metadataCoordinate.latitude, longitude: metadataCoordinate.longitude)
            )
        }
    }

    /// Uploads the photo, then records its path on a new landmark document.
    func uploadLandmark() async {
        guard self.canUpload, !self.isUploading, let coordinate = self.coordinate else { return }

        self.isUploading = true
        defer { self.isUploading = false }

        let landmarkId = UUID().uuidString
        let name = self.title.trimmingCharacters(in: .whitespacesAndNewlines)
        var uploadedPath: String?

        do {
            guard let data = self.croppedImage.resizedForUpload().jpegData(compressionQuality: 0.8) else {
                throw DataResponseError.imageEncodingFailed
            }

            let path = try await self.landmarkProvider.uploadLandmarkPhoto(
                data,
                landmarkId: landmarkId,
                title: name
            )
            uploadedPath = path

            let landmark = Landmark(
                name: name,
                id: landmarkId,
                location: self.address,
                description: self.landmarkDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                imageUrlPaths: [path],
                geoLocation: GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            )
            try await self.landmarkProvider.addLandmark(landmark: landmark)

            self.didUpload = true
        } catch {
            debugPrint("uploadLandmark() failed: \(error)")

            // Don't leave an orphaned photo behind if the Firestore write failed.
            if let uploadedPath {
                await self.landmarkProvider.deleteLandmarkPhoto(atPath: uploadedPath)
            }
            self.uploadErrorMessage = "Your landmark couldn't be posted. Please try again."
        }
    }
}
