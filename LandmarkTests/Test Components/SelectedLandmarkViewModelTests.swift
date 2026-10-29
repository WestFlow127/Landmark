//
//  SelectedLandmarkViewModelTests.swift
//  LandmarkTests
//

import Testing
import UIKit

@testable import Landmark

@MainActor
struct SelectedLandmarkViewModelTests {
    @Test func loadsFirstPhotoForTheLandmark() async {
        let provider = MockLandmarkProvider()
        let image = TestSupport.makeImage()
        provider.photoResult = .success(image)
        let landmark = Landmark(name: "Sign", id: "1", imageUrlPaths: ["/landmarks/1/a.jpeg", "/landmarks/1/b.jpeg"])

        let viewModel = SelectedLandmarkViewModel(landmark: landmark, landmarkProvider: provider)
        await TestSupport.waitUntil { !viewModel.landmarkImages.isEmpty }

        #expect(provider.requestedPhotoPaths == ["/landmarks/1/a.jpeg"])
        #expect(viewModel.landmarkImages.count == 1)
        #expect(viewModel.landmarkImages.first === image)
    }

    @Test func doesNotRequestAPhotoWhenThereIsNoPath() {
        let provider = MockLandmarkProvider()

        let viewModel = SelectedLandmarkViewModel(landmark: Landmark(name: "Sign", id: "1"), landmarkProvider: provider)

        #expect(provider.requestedPhotoPaths.isEmpty)
        #expect(viewModel.landmarkImages.isEmpty)
    }

    @Test func leavesImagesEmptyWhenPhotoFails() async {
        let provider = MockLandmarkProvider()
        provider.photoResult = .failure(DataResponseError.emptyData)
        let landmark = Landmark(name: "Sign", id: "1", imageUrlPaths: ["/landmarks/1/a.jpeg"])

        let viewModel = SelectedLandmarkViewModel(landmark: landmark, landmarkProvider: provider)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(provider.requestedPhotoPaths == ["/landmarks/1/a.jpeg"])
        #expect(viewModel.landmarkImages.isEmpty)
    }

    @Test func setImageReplacesExistingImages() {
        let viewModel = SelectedLandmarkViewModel(
            landmark: Landmark(name: "Sign", id: "1"),
            landmarkProvider: MockLandmarkProvider()
        )
        let first = TestSupport.makeImage(side: 5)
        let second = TestSupport.makeImage(side: 6)

        viewModel.setImage(image: first)
        viewModel.setImage(image: second)

        #expect(viewModel.landmarkImages.count == 1)
        #expect(viewModel.landmarkImages.first === second)
    }
}
