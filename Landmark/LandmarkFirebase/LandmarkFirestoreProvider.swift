//
//  LandmarkFirestoreProvider.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/20/22.
//
import Combine
import FirebaseFirestore
import FirebaseStorage
import Foundation

class LandmarkFirestoreProvider: ObservableObject {
    let auth = LandmarkAuthManager.shared
    let db = Firestore.firestore()
    let storage = Storage.storage()

    var listeners: [ListenerRegistration]?

    init() {
        if self.auth.isSignedIn {
            self.listeners = [ListenerRegistration]()
        }
    }

    func getLandmarkPhoto(forPath: String) -> Future<UIImage, Error> {
        let ref = self.storage.reference(withPath: forPath)

        return Future {
            promise in
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    promise(Result.failure(error))
                } else {
                    if let image = UIImage(data: data!) {
                        promise(Result.success(image))
                    } else {
                        promise(Result.failure(DataResponseError.emptyData))
                    }
                }
            }
        }
    }

    /// Emits the full list of landmarks now and again every time the collection changes,
    /// e.g. after a new landmark is added. Removes its Firestore listener when the stream ends.
    func landmarksStream() -> AsyncThrowingStream<[Landmark], Error> {
        AsyncThrowingStream { continuation in
            let listener = self.db.collection("landmarks").addSnapshotListener { querySnapshot, error in
                if let error = error {
                    debugPrint("Error in snapshotListener: \(error)")
                    continuation.finish(throwing: error)
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    continuation.finish(throwing: DataResponseError.emptyData)
                    return
                }

                // A document that fails to decode is skipped so one bad record doesn't hide the rest.
                let landmarks = documents.compactMap { queryDocumentSnapshot -> Landmark? in
                    do {
                        return try queryDocumentSnapshot.data(as: Landmark.self)
                    } catch {
                        debugPrint("Decoding Error for \(queryDocumentSnapshot.documentID): \(error)")
                        return nil
                    }
                }
                continuation.yield(landmarks)
            }

            self.listeners?.append(listener)
            continuation.onTermination = { _ in listener.remove() }
        }
    }

    /// Makes the title safe to use as a Storage file name.
    private static func fileName(from title: String) -> String {
        let cleaned = title
            .components(separatedBy: CharacterSet(charactersIn: "/\\?%*|\"<>:#[]"))
            .joined(separator: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned.isEmpty ? "photo" : cleaned
    }

    /// Uploads a landmark photo to Storage, named after the landmark's title, and returns its path,
    /// e.g. "/landmarks/<landmarkId>/<title>.jpeg".
    func uploadLandmarkPhoto(_ data: Data, landmarkId: String, title: String) async throws -> String {
        let path = "/landmarks/\(landmarkId)/\(Self.fileName(from: title)).jpeg"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await self.storage.reference(withPath: path).putDataAsync(data, metadata: metadata)

        return path
    }

    /// Writes the landmark to Firestore using its `id` as the document ID.
    func addLandmark(landmark: Landmark) async throws {
        guard let id = landmark.id else { throw DataResponseError.missingId }

        try self.db.collection("landmarks").document(id).setData(from: landmark)
    }

    func deleteLandmarkPhoto(atPath path: String) async {
        try? await self.storage.reference(withPath: path).delete()
    }

    // MARK: - User profile

    private func currentUserId() throws -> String {
        guard let uid = self.auth.auth.currentUser?.uid else { throw DataResponseError.notSignedIn }

        return uid
    }

    /// Returns the signed-in user's profile, or an empty one if they haven't saved anything yet.
    func fetchUserProfile() async throws -> UserProfile {
        let uid = try self.currentUserId()
        let snapshot = try await self.db.collection(UserProfile.collectionName).document(uid).getDocument()

        guard snapshot.exists else { return UserProfile(id: uid) }

        return try snapshot.data(as: UserProfile.self)
    }

    /// Writes the signed-in user's profile to `users/{uid}`, replacing the existing document.
    func saveUserProfile(_ profile: UserProfile) async throws {
        let uid = try self.currentUserId()

        try await self.db.collection(UserProfile.collectionName).document(uid).setData(from: profile)
    }

    /// The Storage folder that holds everything owned by the signed-in user, e.g. "/users/<uid>".
    /// Build per-user paths (profile picture, future private landmarks) from this.
    private func userStoragePath() throws -> String {
        "/users/\(try self.currentUserId())"
    }

    /// Uploads the signed-in user's profile picture and returns its Storage path.
    func uploadProfilePhoto(_ data: Data) async throws -> String {
        let path = "\(try self.userStoragePath())/profile.jpeg"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await self.storage.reference(withPath: path).putDataAsync(data, metadata: metadata)

        return path
    }

    func downloadImage(atPath path: String) async throws -> UIImage {
        let data = try await self.storage.reference(withPath: path).data(maxSize: 5 * 1024 * 1024)

        guard let image = UIImage(data: data) else { throw DataResponseError.emptyData }

        return image
    }

    func cancelListeners() {
        guard let listeners else { return }

        for listener in listeners {
            listener.remove()
        }
    }
}
