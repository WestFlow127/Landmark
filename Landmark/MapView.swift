//
//  MapView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/3/22.
//

import SwiftUI
import UIKit
import MapKit


// Leaving this MapView out of the code for now, doesn't seem to be necessary...
struct MapView: UIViewRepresentable {
    typealias UIViewType = UIView
    
    var map: MKMapView = MKMapView()
    @Binding var region: MKCoordinateRegion

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        map.showsUserLocation = true
        map.setRegion(region, animated: true)
        
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
        debugPrint("region: \(region.center)") // Region's center is changed
        map.setCenter(region.center, animated: true)
    }
    
}
