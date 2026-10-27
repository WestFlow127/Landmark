//
//  LandmarkProviding.swift
//  Landmark
//

import Combine
import UIKit

/// The backend operations the view models need, so tests can swap in a mock.
protocol LandmarkProviding: AnyObject {
    func getLandmarkPhoto(forPath: String) -> Future<UIImage, Error>
    func landmarksStream() -> AsyncThrowingStream<[Landmark], Error>
    func uploadLandmarkPhoto(_ data: Data, landmarkId: String, title: String) async throws -> String
    func addLandmark(landmark: Landmark) async throws
    func deleteLandmarkPhoto(atPath path: String) async
    func cancelListeners()
}

extension LandmarkFirestoreProvider: LandmarkProviding {}
