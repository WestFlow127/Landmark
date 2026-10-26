//
//  LandmarkMainViewModel.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/4/22.
//

import Combine
import MapKit
import SwiftUI

struct MapDetails {
    static let defaultLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
}

final class LandmarkMainViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var cancellables: Set<AnyCancellable> = []
    private var landmarksTask: Task<Void, Never>?
    private let locationServicesOffPrompt = "You need to turn on Location Services for this app in iOS Settings."
    private let locationServicesOffGeneric = "Please turn on Location Services in iOS Settings."

    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(center: MapDetails.defaultLocation, span: MapDetails.defaultSpan)
    )
    @Published var landmarkProvider = LandmarkFirestoreProvider()
    @Published var landmarks: [Landmark] = []
    @Published var addLandmarkFlow: AddLandmarkFlow = .idle

    @Published var locationServicesOff: Bool = false
    @Published var locationServicesOffMessage: String = "Location services is unavailable."

    var isShowingCamera: Binding<Bool> {
        return Binding(
            get: { self.addLandmarkFlow.isCamera },
            set: { val in
                if val {
                    self.addLandmarkFlow = .camera
                } else if case .camera = self.addLandmarkFlow {
                    self.addLandmarkFlow = .idle
                }
            }
        )
    }

    var isEditing: Binding<Bool> {
        return Binding {
            self.addLandmarkFlow.isEditing
        } set: { isEditing in
            if !isEditing, case .editing = self.addLandmarkFlow {
                self.addLandmarkFlow = .idle
            }
        }
    }

    var locationManager: CLLocationManager?

    /// Set when the user taps the current-location button so the next region update animates.
    private var animateNextRegionChange = false

    override init() {
        super.init()

        // The stream emits again whenever the collection changes,
        // so new landmarks show up on the map.
        self.landmarksTask = Task { [weak self] in
            guard let provider = self?.landmarkProvider else { return }

            do {
                for try await landmarks in provider.landmarksStream() {
                    await MainActor.run { self?.landmarks = landmarks }
                }
            } catch {
                debugPrint("landmarksStream() failed: \(error)")
            }
        }
    }

    deinit {
        self.landmarksTask?.cancel()
    }

    func startAddLandmark() {
        // The view decides between the real camera and the sample-photo stand-in.
        self.addLandmarkFlow = .camera
    }

    func photoCaptured(_ capturedPhoto: CapturedPhoto) {
        self.addLandmarkFlow = .editing(capturedPhoto)
    }

    func cancelAddLandmark() {
        self.addLandmarkFlow = .idle
    }

    func setupLocationServices() {
        self.locationManager = CLLocationManager()
        self.locationManager?.activityType = .other
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager?.delegate = self
    }

    /// Pulls the map to the user's current location, or prompts/alerts if access isn't granted.
    func centerOnUserLocation() {
        if self.locationManager == nil {
            self.setupLocationServices()
        }

        self.animateNextRegionChange = true
        self.locationManager?.requestLocation()
    }

    /// Moves the map to `coordinate`, animating only when the change was requested by the user.
    private func updateRegion(center coordinate: CLLocationCoordinate2D) {
        let newRegion = MKCoordinateRegion(center: coordinate, span: MapDetails.defaultSpan)

        if self.animateNextRegionChange {
            self.animateNextRegionChange = false
            withAnimation(.easeInOut(duration: 1.5)) {
                self.cameraPosition = .region(newRegion)
            }
        } else {
            self.cameraPosition = .region(newRegion)
        }
    }

    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            if !self.locationServicesOff {
                locationManager.requestWhenInUseAuthorization()
            } else {
                self.locationServicesOffMessage = self.locationServicesOffPrompt
            }

        case .restricted:
            print("Restricted likely due to parental controls.")

            self.locationServicesOff = true
            self.locationServicesOffMessage = "Your location is restricted likely due to parental controls."

        case .denied:
            print("Location Services is off.")

            self.locationServicesOff = true
            self.locationServicesOffMessage = self.locationServicesOffPrompt

        case .authorizedAlways, .authorizedWhenInUse:
            debugPrint("Location Services Authorized")
            guard !self.locationServicesOff else { return }

            if let location = locationManager.location {
                self.updateRegion(center: location.coordinate)
            } else {
                self.locationManager?.requestLocation()
            }

        @unknown default:
            break
        }
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }

        self.updateRegion(center: coordinate)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: any Error) {
        debugPrint("LocationManager failed with error: \(error)")

        if (error as? CLError)?.code == .denied {
            self.locationServicesOff = true
            self.locationServicesOffMessage = self.locationServicesOffGeneric
        }

        // Don't leave a stale request that would animate some later, unrelated update.
        self.animateNextRegionChange = false
    }

    func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        self.checkLocationAuthorization()
    }
}
