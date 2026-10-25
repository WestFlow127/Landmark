//
//  SelectedLandmarkViewModel.swift
//  Landmark
//
//  Created by Weston Mitchell on 10/15/22.
//

import Combine
import UIKit

class SelectedLandmarkViewModel: NSObject, ObservableObject {
    @Published var landmarkImages: [UIImage] = []
    @Published var landmark: Landmark

    var landmarkProvider = LandmarkFirestoreProvider()

    private var cancellables: Set<AnyCancellable> = []

    init(landmark: Landmark) {
        self.landmark = landmark

        super.init()

        self.getImages()
    }

    func getImages() {
        if let imagePath = landmark.imageUrlPaths?.first {
            self.landmarkProvider.getLandmarkPhoto(forPath: imagePath)
                .sink(receiveCompletion: { error in
                    debugPrint("getLandmarkPhoto completed : \(error)")
                }, receiveValue: self.setImage)
                .store(in: &self.cancellables)
        }
    }

    func setImage(image: UIImage) {
        self.landmarkImages = [image]
    }
}
