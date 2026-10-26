//
//  ProfileViewModel.swift
//  Landmark
//

import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var name = ""
    @Published var bio = ""
    @Published var city = ""
    @Published var state = ""
    @Published var country = ""
    @Published private(set) var profileImage: UIImage?
    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false
    @Published var errorMessage: String?

    private let provider: LandmarkFirestoreProvider

    /// The last profile loaded from or saved to Firestore; edits are compared against it.
    private var savedProfile = UserProfile()
    /// A newly picked picture that hasn't been uploaded yet.
    private var pendingImage: UIImage?

    init(provider: LandmarkFirestoreProvider = LandmarkFirestoreProvider()) {
        self.provider = provider
    }

    var hasChanges: Bool {
        self.pendingImage != nil || self.draftProfile != self.normalized(self.savedProfile)
    }

    var canSave: Bool {
        self.hasChanges && !self.isSaving && !self.isLoading
    }

    /// The text fields as they'd be stored: trimmed, with blanks stored as nil.
    private var draftProfile: UserProfile {
        UserProfile(
            id: self.savedProfile.id,
            name: self.trimmedOrNil(self.name),
            bio: self.trimmedOrNil(self.bio),
            city: self.trimmedOrNil(self.city),
            state: self.trimmedOrNil(self.state),
            country: self.trimmedOrNil(self.country),
            profileImagePath: self.savedProfile.profileImagePath
        )
    }

    private func trimmedOrNil(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        return trimmed.isEmpty ? nil : trimmed
    }

    private func normalized(_ profile: UserProfile) -> UserProfile {
        UserProfile(
            id: profile.id,
            name: self.trimmedOrNil(profile.name ?? ""),
            bio: self.trimmedOrNil(profile.bio ?? ""),
            city: self.trimmedOrNil(profile.city ?? ""),
            state: self.trimmedOrNil(profile.state ?? ""),
            country: self.trimmedOrNil(profile.country ?? ""),
            profileImagePath: profile.profileImagePath
        )
    }

    func load() async {
        self.isLoading = true
        defer { self.isLoading = false }

        do {
            let profile = try await self.provider.fetchUserProfile()
            self.apply(profile)

            if let path = profile.profileImagePath {
                self.profileImage = try? await self.provider.downloadImage(atPath: path)
            }
        } catch {
            debugPrint("load() profile failed: \(error)")
            self.errorMessage = "Your profile couldn't be loaded."
        }
    }

    private func apply(_ profile: UserProfile) {
        self.savedProfile = profile
        self.name = profile.name ?? ""
        self.bio = profile.bio ?? ""
        self.city = profile.city ?? ""
        self.state = profile.state ?? ""
        self.country = profile.country ?? ""
    }

    func imagePicked(_ image: UIImage) {
        self.pendingImage = image
        self.profileImage = image
    }

    func save() async {
        guard self.canSave else { return }

        self.isSaving = true
        defer { self.isSaving = false }

        var profile = self.draftProfile

        do {
            if let pendingImage = self.pendingImage {
                guard let data = pendingImage.croppedToSquare().resizedForUpload().jpegData(compressionQuality: 0.8) else {
                    throw DataResponseError.imageEncodingFailed
                }

                profile.profileImagePath = try await self.provider.uploadProfilePhoto(data)
            }

            try await self.provider.saveUserProfile(profile)

            self.savedProfile = profile
            self.pendingImage = nil
        } catch {
            debugPrint("save() profile failed: \(error)")
            self.errorMessage = "Your profile couldn't be saved. Please try again."
        }
    }
}
