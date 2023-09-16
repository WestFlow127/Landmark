//
//  LandmarkMainViewModel.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/4/22.
//

import MapKit
import Combine

struct MapDetails
{
    static let defaultLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
}

final class LandmarkMainViewModel: NSObject, ObservableObject, CLLocationManagerDelegate
{
    private var cancellables: Set<AnyCancellable> = []

    @Published var region = MKCoordinateRegion(center: MapDetails.defaultLocation, span: MapDetails.defaultSpan)
    @Published var landmarkProvider = LandmarkFirestoreProvider()
    @Published var landmarks: [LandmarkEntity] = []

    @Published var locationServicesOff: Bool = false
    @Published var locationServicesOffReason: String = "Location services is unavailable."

    var locationManager: CLLocationManager?

    override init()
    {
        super.init()
        
        landmarkProvider.getLandmarks()
            .sink(receiveCompletion: {
                error in
                
                debugPrint("getLandmarks() completed: \(error)")
            }, receiveValue: {
                landmarks in
               
                self.landmarks = landmarks
            })
            .store(in: &cancellables)
    }
    
    func setupLocationServices()
    {
        locationManager = CLLocationManager()
        locationManager?.activityType = .other
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.delegate = self
    }
    
    private func checkLocationAuthorization()
    {
        guard let locationManager = locationManager else { return }

        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            print("Restricted likely due to parental controls.")
            
            locationServicesOff = true
            locationServicesOffReason = "Your location is restricted likely due to parental controls."
            
        case .denied:
            print("Location Services is off.")
            
            locationServicesOff = true
            locationServicesOffReason = "You need to turn on Location Services for this app in iOS Settings."
            
        case .authorizedAlways, .authorizedWhenInUse:
            debugPrint("Location Services Authorized")

            if let location = locationManager.location
            {
                region = MKCoordinateRegion(center: location.coordinate, span: MapDetails.defaultSpan)
            }
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)
    {
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
