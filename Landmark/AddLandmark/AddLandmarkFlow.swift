//
//  AddLandmarkFlow.swift
//  Landmark
//
//  Created by Weston Mitchell on 10/20/26.
//

import UIKit

enum AddLandmarkFlow {
    case idle
    case camera
    case editing(UIImage)

    var isCamera: Bool {
        if case .camera = self {
            return true
        } else {
            return false
        }
    }

    var capturedImage: UIImage? {
        if case let .editing(image) = self {
            return image
        } else {
            return nil
        }
    }

    var isEditing: Bool {
        self.capturedImage != nil
    }
}
