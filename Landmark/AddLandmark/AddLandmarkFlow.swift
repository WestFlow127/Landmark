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
    case editing(CapturedPhoto)

    var isCamera: Bool {
        if case .camera = self {
            return true
        } else {
            return false
        }
    }

    var capturedPhoto: CapturedPhoto? {
        if case let .editing(photo) = self {
            return photo
        } else {
            return nil
        }
    }

    var isEditing: Bool {
        self.capturedPhoto != nil
    }
}
