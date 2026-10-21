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

    func getLandmarks() -> Future<[Landmark], Error> {
        Future {
            [weak self] promise in
            guard let self = self else { return }

            let landmarks = self.db.collection("landmarks").addSnapshotListener { querySnapshot, error in
                if let error = error {
                    debugPrint("Error in snapshotListener: \(error)")
                    promise(Result.failure(error))
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    promise(Result.failure(DataResponseError.emptyData))
                    return
                }

                let landmarks = documents.compactMap { queryDocumentSnapshot in
                    let result = Result { try queryDocumentSnapshot.data(as: Landmark.self) }

                    switch result {
                    case let .success(landmark):
                        return landmark

                    case let .failure(error):
                        debugPrint("Decoding Error: \(error)")

                        promise(Result.failure(error))
                        return nil
                    }
                }
                promise(Result.success(landmarks))
            }
            self.listeners?.append(landmarks)
        }
    }

    func addLandmark(landmark _: Landmark) {
        //        do {
        //            _ = try db.collection()
        //        }
    }

    func cancelListeners() {
        guard let listeners else { return }

        for listener in listeners {
            listener.remove()
        }
    }
}
