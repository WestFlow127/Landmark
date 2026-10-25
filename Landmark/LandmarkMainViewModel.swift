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

    @Published var region = MKCoordinateRegion(center: MapDetails.defaultLocation, span: MapDetails.defaultSpan)
    @Published var landmarkProvider = LandmarkFirestoreProvider()
    @Published var landmarks: [Landmark] = []
    @Published var addLandmarkFlow: AddLandmarkFlow = .idle

    @Published var locationServicesOff: Bool = false
    @Published var locationServicesOffReason: String = "Location services is unavailable."

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

    override init() {
        super.init()

        // The stream emits again whenever the collection changes, so new landmarks show up on the map.
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

    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .restricted:
            print("Restricted likely due to parental controls.")

            self.locationServicesOff = true
            self.locationServicesOffReason = "Your location is restricted likely due to parental controls."

        case .denied:
            print("Location Services is off.")

            self.locationServicesOff = true
            self.locationServicesOffReason = "You need to turn on Location Services for this app in iOS Settings."

        case .authorizedAlways, .authorizedWhenInUse:
            debugPrint("Location Services Authorized")
            self.locationManager?.requestLocation()

            if let location = locationManager.location {
                self.region = MKCoordinateRegion(center: location.coordinate, span: MapDetails.defaultSpan)
            }

        @unknown default:
            break
        }
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }

        self.region = MKCoordinateRegion(center: coordinate, span: MapDetails.defaultSpan)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        debugPrint("LocationManager failed with error: \(error)")
    }

    func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        self.checkLocationAuthorization()
    }
}
