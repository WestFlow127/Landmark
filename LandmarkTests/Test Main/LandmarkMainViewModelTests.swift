//
//  LandmarkMainViewModelTests.swift
//  LandmarkTests
//

import Testing
import UIKit

@testable import Landmark

@MainActor
struct LandmarkMainViewModelTests {
    private func makeViewModel(provider: MockLandmarkProvider = MockLandmarkProvider()) async -> LandmarkMainViewModel {
        let viewModel = LandmarkMainViewModel(landmarkProvider: provider)
        // The stream is consumed from a task started by `init`.
        await TestSupport.waitUntil { provider.isStreaming }
        return viewModel
    }

    // MARK: - landmarksStream

    @Test func publishesLandmarksFromTheStream() async {
        let provider = MockLandmarkProvider()
        let viewModel = await self.makeViewModel(provider: provider)
        let landmarks = [Landmark(name: "One", id: "1"), Landmark(name: "Two", id: "2")]

        provider.send(landmarks)
        await TestSupport.waitUntil { viewModel.landmarks.count == 2 }

        #expect(viewModel.landmarks == landmarks)
    }

    @Test func keepsUpdatingWhenTheCollectionChanges() async {
        let provider = MockLandmarkProvider()
        let viewModel = await self.makeViewModel(provider: provider)

        provider.send([Landmark(name: "One", id: "1")])
        await TestSupport.waitUntil { viewModel.landmarks.count == 1 }

        provider.send([Landmark(name: "One", id: "1"), Landmark(name: "New", id: "3")])
        await TestSupport.waitUntil { viewModel.landmarks.count == 2 }

        #expect(viewModel.landmarks.map(\.name) == ["One", "New"])
    }

    @Test func keepsLastLandmarksWhenTheStreamFails() async {
        let provider = MockLandmarkProvider()
        let viewModel = await self.makeViewModel(provider: provider)

        provider.send([Landmark(name: "One", id: "1")])
        await TestSupport.waitUntil { viewModel.landmarks.count == 1 }
        provider.finishStream(throwing: DataResponseError.emptyData)

        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.landmarks.count == 1)
    }

    // MARK: - Add landmark flow

    @Test func startsIdle() async {
        let viewModel = await self.makeViewModel()

        #expect(!viewModel.addLandmarkFlow.isCamera)
        #expect(!viewModel.addLandmarkFlow.isEditing)
    }

    @Test func startAddLandmarkOpensCamera() async {
        let viewModel = await self.makeViewModel()

        viewModel.startAddLandmark()

        #expect(viewModel.addLandmarkFlow.isCamera)
        #expect(viewModel.isShowingCamera.wrappedValue)
    }

    @Test func photoCapturedMovesToEditing() async {
        let viewModel = await self.makeViewModel()
        let photo = CapturedPhoto(image: TestSupport.makeImage())

        viewModel.startAddLandmark()
        viewModel.photoCaptured(photo)

        #expect(viewModel.addLandmarkFlow.isEditing)
        #expect(viewModel.addLandmarkFlow.capturedPhoto?.image === photo.image)
        #expect(viewModel.isEditing.wrappedValue)
        #expect(!viewModel.isShowingCamera.wrappedValue)
    }

    @Test func cancelReturnsToIdle() async {
        let viewModel = await self.makeViewModel()

        viewModel.photoCaptured(CapturedPhoto(image: TestSupport.makeImage()))
        viewModel.cancelAddLandmark()

        #expect(!viewModel.addLandmarkFlow.isEditing)
        #expect(!viewModel.addLandmarkFlow.isCamera)
    }

    @Test func dismissingCameraBindingReturnsToIdle() async {
        let viewModel = await self.makeViewModel()

        viewModel.startAddLandmark()
        viewModel.isShowingCamera.wrappedValue = false

        #expect(!viewModel.addLandmarkFlow.isCamera)
    }

    @Test func dismissingCameraBindingDoesNotDiscardEditing() async {
        let viewModel = await self.makeViewModel()

        viewModel.photoCaptured(CapturedPhoto(image: TestSupport.makeImage()))
        viewModel.isShowingCamera.wrappedValue = false

        #expect(viewModel.addLandmarkFlow.isEditing)
    }

    @Test func dismissingEditorBindingReturnsToIdle() async {
        let viewModel = await self.makeViewModel()

        viewModel.photoCaptured(CapturedPhoto(image: TestSupport.makeImage()))
        viewModel.isEditing.wrappedValue = false

        #expect(!viewModel.addLandmarkFlow.isEditing)
    }

    // MARK: - Provider

    @Test func cancelListenersIsForwardedToProvider() async {
        let provider = MockLandmarkProvider()
        let viewModel = await self.makeViewModel(provider: provider)

        viewModel.landmarkProvider.cancelListeners()

        #expect(provider.cancelListenersCount == 1)
    }
}
