//
//  LandmarkFirestoreProvider.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/20/22.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class LandmarkFirestoreProvider: ObservableObject {
    let auth = LandmarkAuthManager.shared
    let db = Firestore.firestore()
    
    var listeners: [ListenerRegistration]?
    
    @Published var landmarks: [LandmarkEntity] = []
    
    init() {
        if auth.isSignedIn {
            listeners = [ListenerRegistration]()
            listeners?.append(getLandmarks())
        }
    }
    
    private func getLandmarks() -> ListenerRegistration {
         db.collection("landmarks").addSnapshotListener{ [weak self] (querySnapshot, error) in
            if let error = error {
                debugPrint("Error in snapshotListener: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                return
            }
            
            let landmarks = documents.compactMap { queryDocumentSnapshot in
                let result = Result { try queryDocumentSnapshot.data(as: LandmarkEntity.self) }
                
                switch result {
                    
                case .success(let landmark):
                    return landmark
                    
                case .failure(let error):
                    debugPrint("Decoding Error: \(error)")
                    return nil
                }
            }
            
            self?.landmarks = landmarks
        }
    }
    
    func addLandmark(landmark: LandmarkEntity) {
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
