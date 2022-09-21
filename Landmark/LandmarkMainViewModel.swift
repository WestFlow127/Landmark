//
//  LandmarkMainViewModel.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/4/22.
//

import MapKit
import Combine

struct MapDetails {
    static let defaultLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
}

final class LandmarkMainViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region = MKCoordinateRegion(center: MapDetails.defaultLocation, span: MapDetails.defaultSpan)
    @Published var landmarkProvider = LandmarkFirestoreProvider()
    @Published var landmarks: [LandmarkEntity] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    var locationManager: CLLocationManager?

    override init() {
        super.init()
        
        landmarkProvider.$landmarks
            .assign(to: \.landmarks, on: self)
            .store(in: &cancellables)
    }
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.activityType = .other
            locationManager?.delegate = self
        } else {
            // TODO: show alert to enabled locations services
            print("You need to turn on Location Services for this app in iOS Settings.")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // TODO: show alert
            print("Your location is restricted likely due to parental controls.")
        case .denied:
            // TODO: show alert to enabled locations services
            print("You need to turn on Location Services for this app in iOS Settings.")
        case .authorizedAlways, .authorizedWhenInUse:
            debugPrint("Location Services Authorized")
            if let location = locationManager.location {
                debugPrint("RegionSet!")
                region = MKCoordinateRegion(center: location.coordinate, span: MapDetails.defaultSpan)
            }
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}


//            var geoLoader = CLGeocoder()
//            geoLoader.geocodeAddressString("Ocean Front Walk, Venice, CA 90291") { placemark, error in
//
//                debugPrint("GeoLoader.Error: \(error?.localizedDescription)")
//                if let coord = placemark?.first?.location?.coordinate {
//                    debugPrint("Coord \(coord)")
//                }
//            }
