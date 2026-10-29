//
//  AppDependencies.swift
//  Landmark
//

import SwiftUI

/// The app-wide services, created once at the top of the app and shared through the SwiftUI environment.
/// The services are lazy so `FirebaseApp.configure()` has run before the Firestore provider is created.
final class AppDependencies {
    lazy var landmarkProvider: any LandmarkProviding = LandmarkFirestoreProvider()
    lazy var locationFetcher: any LocationProviding = LocationFetcher()
}

extension EnvironmentValues {
    @Entry var dependencies = AppDependencies()
}
