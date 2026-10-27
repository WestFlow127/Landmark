//
//  MockLandmarkProvider.swift
//  LandmarkTests
//

import Combine
import CoreLocation
import UIKit

@testable import Landmark

/// Records every call and returns whatever the test configures, with no Firebase involved.
final class MockLandmarkProvider: LandmarkProviding, @unchecked Sendable {
    struct UploadedPhoto: Equatable {
        let data: Data
        let landmarkId: String
        let title: String
    }

    // Calls can arrive from background tasks, so all state goes through the lock.
    private let lock = NSLock()
    private var _uploadedPhotos: [UploadedPhoto] = []
    private var _addedLandmarks: [Landmark] = []
    private var _deletedPaths: [String] = []
    private var _requestedPhotoPaths: [String] = []
    private var _cancelListenersCount = 0
    private var _streamContinuation: AsyncThrowingStream<[Landmark], Error>.Continuation?

    private var _uploadResult: Result<String, Error> = .success("/landmarks/mock/photo.jpeg")
    private var _addError: Error?
    private var _photoResult: Result<UIImage, Error> = .failure(DataResponseError.emptyData)

    var uploadResult: Result<String, Error> {
        get { self.locked { self._uploadResult } }
        set { self.locked { self._uploadResult = newValue } }
    }

    var addError: Error? {
        get { self.locked { self._addError } }
        set { self.locked { self._addError = newValue } }
    }

    var photoResult: Result<UIImage, Error> {
        get { self.locked { self._photoResult } }
        set { self.locked { self._photoResult = newValue } }
    }

    var uploadedPhotos: [UploadedPhoto] { self.locked { self._uploadedPhotos } }
    var addedLandmarks: [Landmark] { self.locked { self._addedLandmarks } }
    var deletedPaths: [String] { self.locked { self._deletedPaths } }
    var requestedPhotoPaths: [String] { self.locked { self._requestedPhotoPaths } }
    var cancelListenersCount: Int { self.locked { self._cancelListenersCount } }
    var isStreaming: Bool { self.locked { self._streamContinuation != nil } }

    /// Pushes a snapshot to whoever is consuming `landmarksStream()`.
    func send(_ landmarks: [Landmark]) {
        _ = self.locked { self._streamContinuation }?.yield(landmarks)
    }

    func finishStream(throwing error: Error? = nil) {
        self.locked { self._streamContinuation }?.finish(throwing: error)
    }

    // MARK: - LandmarkProviding

    func getLandmarkPhoto(forPath path: String) -> Future<UIImage, Error> {
        self.locked { self._requestedPhotoPaths.append(path) }
        let result = self.photoResult

        return Future { promise in promise(result) }
    }

    func landmarksStream() -> AsyncThrowingStream<[Landmark], Error> {
        AsyncThrowingStream { continuation in
            self.locked { self._streamContinuation = continuation }
        }
    }

    func uploadLandmarkPhoto(_ data: Data, landmarkId: String, title: String) async throws -> String {
        self.locked { self._uploadedPhotos.append(UploadedPhoto(data: data, landmarkId: landmarkId, title: title)) }

        return try self.uploadResult.get()
    }

    func addLandmark(landmark: Landmark) async throws {
        self.locked { self._addedLandmarks.append(landmark) }

        if let error = self.addError { throw error }
    }

    func deleteLandmarkPhoto(atPath path: String) async {
        self.locked { self._deletedPaths.append(path) }
    }

    func cancelListeners() {
        self.locked { self._cancelListenersCount += 1 }
    }

    private func locked<T>(_ body: () -> T) -> T {
        self.lock.lock()
        defer { self.lock.unlock() }

        return body()
    }
}

/// Returns a fixed location and address instead of asking CoreLocation.
final class MockLocationProvider: LocationProviding, @unchecked Sendable {
    var location: CLLocation?
    var addressResult: String?

    init(location: CLLocation? = nil, address: String? = nil) {
        self.location = location
        self.addressResult = address
    }

    func currentLocation() async -> CLLocation? {
        self.location
    }

    func address(for _: CLLocation) async -> String? {
        self.addressResult
    }
}

enum TestSupport {
    /// A small opaque image that is safe to crop, resize and JPEG-encode.
    static func makeImage(side: CGFloat = 10) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format).image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: side, height: side))
        }
    }

    /// Polls until `condition` is true, failing the wait after `timeout` seconds.
    @discardableResult
    static func waitUntil(timeout: TimeInterval = 2, _ condition: @escaping () -> Bool) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if condition() { return true }
            try? await Task.sleep(for: .milliseconds(10))
        }

        return condition()
    }
}
