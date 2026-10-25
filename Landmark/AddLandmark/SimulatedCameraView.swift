//
//  SimulatedCameraView.swift
//  Landmark
//

import SwiftUI

/// Stand-in for the camera on devices without one (e.g. the simulator).
/// Shows a bundled sample photo that the user can accept with "Use Photo".
struct SimulatedCameraView: View {
    static let sampleImageName = "landmark-Ship"

    let onCapture: (UIImage) -> Void
    let onCancel: () -> Void

    private let sampleImage = UIImage(named: SimulatedCameraView.sampleImageName)

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if let sampleImage {
                    Image(uiImage: sampleImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("Sample photo \"\(Self.sampleImageName)\" not found.")
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack {
                Button("Cancel") {
                    self.onCancel()
                }

                Spacer()

                Button("Use Photo") {
                    if let sampleImage {
                        self.onCapture(sampleImage)
                    }
                }
                .fontWeight(.semibold)
                .disabled(self.sampleImage == nil)
            }
            .font(.title3)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
            .background(Color.black)
        }
        .background(Color.black.ignoresSafeArea())
    }
}
