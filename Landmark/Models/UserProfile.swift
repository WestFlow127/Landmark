//
//  UserProfile.swift
//  Landmark
//

import FirebaseFirestore
import Foundation

/// Schema for documents in the Firestore `users` collection.
/// The document ID is the Firebase Auth uid, so each user has at most one profile document.
/// Every field is optional: a user who hasn't filled anything in has no document (or an empty one).
///
///     users/{uid}
///         name: String?
///         bio: String?
///         city: String?
///         state: String?
///         country: String?
///         profileImagePath: String?   // Storage path, e.g. "/users/{uid}/profile.jpeg"
struct UserProfile: Identifiable, Equatable, Codable {
    static let collectionName = "users"

    @DocumentID var id: String?

    var name: String?
    var bio: String?
    var city: String?
    var state: String?
    var country: String?
    var profileImagePath: String?

    init(id: String? = nil,
         name: String? = nil,
         bio: String? = nil,
         city: String? = nil,
         state: String? = nil,
         country: String? = nil,
         profileImagePath: String? = nil)
    {
        self.id = id
        self.name = name
        self.bio = bio
        self.city = city
        self.state = state
        self.country = country
        self.profileImagePath = profileImagePath
    }
}
