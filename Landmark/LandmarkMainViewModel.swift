//
//  LandmarkMainViewModel.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/4/22.
//

import MapKit

final class LandmarkMainViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    
    @Published var region = MKCoordinateRegion(center: MapDetails.defaultLocation, span: MapDetails.defaultSpan)

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
