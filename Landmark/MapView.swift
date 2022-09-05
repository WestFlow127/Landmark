//
//  MapView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/3/22.
//

import SwiftUI
import UIKit
import MapKit

enum MapDetails {
    static let defaultLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
}

struct MapView: UIViewRepresentable {
    typealias UIViewType = UIView
    
    var map: MKMapView = MKMapView()
    var region: Binding<MKCoordinateRegion>

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        map.showsUserLocation = true
        map.setRegion(region.wrappedValue, animated: true)
        
        view.addSubview(map)
        
        map.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            map.widthAnchor.constraint(equalTo: view.widthAnchor),
            map.heightAnchor.constraint(equalTo: view.heightAnchor),
            map.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            map.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

//        let pin = MKPointAnnotation()
//        pin.coordinate = MapDetails.defaultLocation
        
//        map.addAnnotation(pin)
        
        return view
    }
    // TODO: Find out why map doesn's update to user location
    func updateUIView(_ uiView: UIView, context: Context) {
        debugPrint("region: \(region.wrappedValue.center)") // Region's center is changed
        map.setCenter(region.wrappedValue.center, animated: true)
    }
    
}
