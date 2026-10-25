//
//  CameraPicker.swift
//  Landmark
//

import SwiftUI
import UIKit

/// Wraps `UIImagePickerController` in camera mode and reports the captured photo.
struct CameraPicker: UIViewControllerRepresentable {
    static var isCameraAvailable: Bool {
        // Recent simulators report a camera as available but only show a blank viewfinder.
        #if targetEnvironment(simulator)
            return false
        #else
            return UIImagePickerController.isSourceTypeAvailable(.camera)
        #endif
    }

    let onCapture: (CapturedPhoto) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: self.onCapture, onCancel: self.onCancel)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (CapturedPhoto) -> Void
        let onCancel: () -> Void

        init(onCapture: @escaping (CapturedPhoto) -> Void, onCancel: @escaping () -> Void) {
            self.onCapture = onCapture
            self.onCancel = onCancel
        }

        func imagePickerController(_: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
        {
            if let image = info[.originalImage] as? UIImage {
                self.onCapture(CapturedPhoto(image: image, metadata: info[.mediaMetadata] as? [AnyHashable: Any]))
            } else {
                self.onCancel()
            }
        }

        func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onCancel()
        }
    }
}
