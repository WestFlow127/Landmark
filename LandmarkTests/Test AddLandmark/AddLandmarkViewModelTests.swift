//
//  AddLandmarkViewModelTests.swift
//  LandmarkTests
//

import CoreLocation
import Testing
import UIKit

@testable import Landmark

@MainActor
struct AddLandmarkViewModelTests {
    private let venice = CLLocation(latitude: 33.985, longitude: -118.47)

    private func makeViewModel(
        provider: MockLandmarkProvider = MockLandmarkProvider(),
        location: CLLocation? = nil,
        address: String? = "1 Ocean Front Walk, Venice, CA",
        metadata: [AnyHashable: Any]? = nil
    ) -> AddLandmarkViewModel {
        AddLandmarkViewModel(
            capturedPhoto: CapturedPhoto(image: TestSupport.makeImage(), metadata: metadata),
            landmarkProvider: provider,
            locationFetcher: MockLocationProvider(location: location, address: address)
        )
    }

    /// Waits for the location lookup started by `init` to finish.
    private func loaded(_ viewModel: AddLandmarkViewModel) async -> AddLandmarkViewModel {
        await TestSupport.waitUntil { !viewModel.isLoadingLocation }
        return viewModel
    }

    private func fillIn(_ viewModel: AddLandmarkViewModel) {
        viewModel.title = "  Venice Sign  "
        viewModel.landmarkDescription = "  Neon sign over the street.  "
    }

    // MARK: - Location

    @Test func usesCurrentLocationAndAddress() async {
        let viewModel = await self.loaded(self.makeViewModel(location: self.venice))

        #expect(viewModel.coordinate?.latitude == 33.985)
        #expect(viewModel.coordinate?.longitude == -118.47)
        #expect(viewModel.addressText == "1 Ocean Front Walk, Venice, CA")
    }

    @Test func fallsBackToPhotoMetadataWhenLocationUnavailable() async {
        let metadata: [AnyHashable: Any] = [
            "{GPS}": ["Latitude": 10.0, "LatitudeRef": "N", "Longitude": 20.0, "LongitudeRef": "W"],
        ]
        let viewModel = await self.loaded(self.makeViewModel(location: nil, metadata: metadata))

        #expect(viewModel.coordinate?.latitude == 10)
        #expect(viewModel.coordinate?.longitude == -20)
    }

    @Test func hasNoCoordinateWithoutLocationOrMetadata() async {
        let viewModel = await self.loaded(self.makeViewModel(location: nil, address: nil))

        #expect(viewModel.coordinate == nil)
        #expect(viewModel.addressText == AddLandmarkViewModel.unknownAddress)
    }

    // MARK: - canUpload

    @Test func cannotUploadWithoutCoordinate() async {
        let viewModel = await self.loaded(self.makeViewModel(location: nil))
        self.fillIn(viewModel)

        #expect(!viewModel.canUpload)
    }

    @Test func cannotUploadWithBlankTitleOrDescription() async {
        let viewModel = await self.loaded(self.makeViewModel(location: self.venice))

        viewModel.title = "   "
        viewModel.landmarkDescription = "Something"
        #expect(!viewModel.canUpload)

        viewModel.title = "Something"
        viewModel.landmarkDescription = "\n "
        #expect(!viewModel.canUpload)
    }

    @Test func canUploadWhenEverythingIsFilledIn() async {
        let viewModel = await self.loaded(self.makeViewModel(location: self.venice))
        self.fillIn(viewModel)

        #expect(viewModel.canUpload)
    }

    // MARK: - uploadLandmark

    @Test func uploadSendsPhotoThenWritesTrimmedLandmark() async {
        let provider = MockLandmarkProvider()
        provider.uploadResult = .success("/landmarks/abc/Venice Sign.jpeg")
        let viewModel = await self.loaded(self.makeViewModel(provider: provider, location: self.venice))
        self.fillIn(viewModel)

        await viewModel.uploadLandmark()

        #expect(viewModel.didUpload)
        #expect(!viewModel.isUploading)
        #expect(viewModel.uploadErrorMessage == nil)
        #expect(provider.deletedPaths.isEmpty)

        let upload = provider.uploadedPhotos.first
        #expect(provider.uploadedPhotos.count == 1)
        #expect(upload?.title == "Venice Sign")
        #expect(upload?.data.isEmpty == false)

        let landmark = provider.addedLandmarks.first
        #expect(provider.addedLandmarks.count == 1)
        #expect(landmark?.id == upload?.landmarkId)
        #expect(landmark?.name == "Venice Sign")
        #expect(landmark?.description == "Neon sign over the street.")
        #expect(landmark?.location == "1 Ocean Front Walk, Venice, CA")
        #expect(landmark?.imageUrlPaths == ["/landmarks/abc/Venice Sign.jpeg"])
        #expect(landmark?.geoLocation.latitude == 33.985)
        #expect(landmark?.geoLocation.longitude == -118.47)
    }

    @Test func uploadDoesNothingWhenNotReady() async {
        let provider = MockLandmarkProvider()
        let viewModel = await self.loaded(self.makeViewModel(provider: provider, location: self.venice))

        await viewModel.uploadLandmark()

        #expect(!viewModel.didUpload)
        #expect(provider.uploadedPhotos.isEmpty)
        #expect(provider.addedLandmarks.isEmpty)
    }

    @Test func photoUploadFailureReportsErrorWithoutCleanup() async {
        let provider = MockLandmarkProvider()
        provider.uploadResult = .failure(URLError(.notConnectedToInternet))
        let viewModel = await self.loaded(self.makeViewModel(provider: provider, location: self.venice))
        self.fillIn(viewModel)

        await viewModel.uploadLandmark()

        #expect(!viewModel.didUpload)
        #expect(!viewModel.isUploading)
        #expect(viewModel.uploadErrorMessage != nil)
        #expect(provider.addedLandmarks.isEmpty)
        #expect(provider.deletedPaths.isEmpty)
    }

    @Test func firestoreFailureDeletesTheOrphanedPhoto() async {
        let provider = MockLandmarkProvider()
        provider.uploadResult = .success("/landmarks/abc/photo.jpeg")
        provider.addError = DataResponseError.missingId
        let viewModel = await self.loaded(self.makeViewModel(provider: provider, location: self.venice))
        self.fillIn(viewModel)

        await viewModel.uploadLandmark()

        #expect(!viewModel.didUpload)
        #expect(!viewModel.isUploading)
        #expect(viewModel.uploadErrorMessage != nil)
        #expect(provider.deletedPaths == ["/landmarks/abc/photo.jpeg"])
    }
}
