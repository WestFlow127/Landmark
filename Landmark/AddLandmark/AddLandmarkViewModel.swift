//
//  AddLandmarkViewModel.swift
//  Landmark
//

import CoreLocation
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

    private let locationFetcher = LocationFetcher()

    var addressText: String {
        self.address ?? Self.unknownAddress
    }

    var canUpload: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !self.landmarkDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && self.coordinate != nil
    }

    /// Location capture starts immediately so it reflects where the photo was taken.
    init(capturedImage: UIImage) {
        self.croppedImage = capturedImage.croppedToSquare()

        Task { await self.loadLocation() }
    }

    private func loadLocation() async {
        defer { self.isLoadingLocation = false }

        guard let location = await self.locationFetcher.currentLocation() else { return }

        self.coordinate = location.coordinate
        self.address = await self.locationFetcher.address(for: location)
    }

    func uploadLandmark() {
        // noop: backend upload to be implemented.
    }
}

extension UIImage {
    /// Center-crops the image to a square, normalizing orientation.
    func croppedToSquare() -> UIImage {
        let side = min(self.size.width, self.size.height)
        let canvas = CGSize(width: side, height: side)
        let format = UIGraphicsImageRendererFormat()
        format.scale = self.scale

        return UIGraphicsImageRenderer(size: canvas, format: format).image { _ in
            let origin = CGPoint(x: (side - self.size.width) / 2, y: (side - self.size.height) / 2)
            self.draw(at: origin)
        }
    }
}
