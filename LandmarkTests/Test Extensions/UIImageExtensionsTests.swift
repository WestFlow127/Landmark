//
//  UIImageExtensionsTests.swift
//  LandmarkTests
//

import Testing
import UIKit

@testable import Landmark

struct UIImageExtensionsTests {
    /// Renders a solid image at scale 1 so point size equals pixel size.
    private func makeImage(width: CGFloat, height: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
    }

    @Test func resizeLeavesSmallImageUntouched() {
        let image = self.makeImage(width: 400, height: 300)

        #expect(image.resizedForUpload(maxSide: 1200) === image)
    }

    @Test func resizeScalesLandscapeImageToMaxSide() {
        let resized = self.makeImage(width: 2400, height: 1200).resizedForUpload(maxSide: 1200)

        #expect(resized.size == CGSize(width: 1200, height: 600))
    }

    @Test func resizeScalesPortraitImageToMaxSide() {
        let resized = self.makeImage(width: 1000, height: 2000).resizedForUpload(maxSide: 1000)

        #expect(resized.size == CGSize(width: 500, height: 1000))
    }

    @Test func cropMakesLandscapeImageSquare() {
        let cropped = self.makeImage(width: 400, height: 200).croppedToSquare()

        #expect(cropped.size == CGSize(width: 200, height: 200))
    }

    @Test func cropMakesPortraitImageSquare() {
        let cropped = self.makeImage(width: 200, height: 400).croppedToSquare()

        #expect(cropped.size == CGSize(width: 200, height: 200))
    }
}
