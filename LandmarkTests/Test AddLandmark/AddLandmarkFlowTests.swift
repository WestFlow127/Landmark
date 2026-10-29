//
//  AddLandmarkFlowTests.swift
//  LandmarkTests
//

import Testing
import UIKit

@testable import Landmark

struct AddLandmarkFlowTests {
    private let photo = CapturedPhoto(image: UIImage())

    @Test func idleIsNeitherCameraNorEditing() {
        let flow = AddLandmarkFlow.idle

        #expect(!flow.isCamera)
        #expect(!flow.isEditing)
        #expect(flow.capturedPhoto == nil)
    }

    @Test func cameraIsOnlyCamera() {
        let flow = AddLandmarkFlow.camera

        #expect(flow.isCamera)
        #expect(!flow.isEditing)
        #expect(flow.capturedPhoto == nil)
    }

    @Test func editingExposesCapturedPhoto() {
        let flow = AddLandmarkFlow.editing(self.photo)

        #expect(!flow.isCamera)
        #expect(flow.isEditing)
        #expect(flow.capturedPhoto?.image === self.photo.image)
    }
}
