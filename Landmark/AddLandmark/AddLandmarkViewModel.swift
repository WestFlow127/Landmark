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

    private let locationFetcher = LocationFetcher()
    private let landmarkProvider: LandmarkFirestoreProvider

    var addressText: String {
        self.address ?? Self.unknownAddress
    }

    var canUpload: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !self.landmarkDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && self.coordinate != nil
    }

    /// Location capture starts immediately so it reflects where the photo was taken.
    init(capturedImage: UIImage, landmarkProvider: LandmarkFirestoreProvider = LandmarkFirestoreProvider()) {
        self.landmarkProvider = landmarkProvider
        self.croppedImage = capturedImage.croppedToSquare()

        Task { await self.loadLocation() }
    }

    private func loadLocation() async {
        defer { self.isLoadingLocation = false }

        guard let location = await self.locationFetcher.currentLocation() else { return }

        self.coordinate = location.coordinate
        self.address = await self.locationFetcher.address(for: location)
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
