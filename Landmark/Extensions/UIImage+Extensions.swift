//
//  UIImage+Extensions.swift
//  Landmark
//

import UIKit

extension UIImage {
    /// Scales the image down so the JPEG stays well under the 1 MB limit used when downloading photos.
    func resizedForUpload(maxSide: CGFloat = 1200) -> UIImage {
        let longestSide = max(self.size.width, self.size.height)
        guard longestSide > maxSide else { return self }

        let ratio = maxSide / longestSide
        let newSize = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

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
