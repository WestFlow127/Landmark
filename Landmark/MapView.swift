//
//  MapView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/3/22.
//

import Foundation
import SwiftUI
import UIKit
import MapKit

struct MapView: UIViewRepresentable {
    typealias UIViewType = UIView
    
    var coordinate: CLLocationCoordinate2D

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        
        let map = MKMapView()
        map.setRegion(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)),
            animated: true
        )
        
        view.addSubview(map)
        
        map.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            map.widthAnchor.constraint(equalTo: view.widthAnchor),
            map.heightAnchor.constraint(equalTo: view.heightAnchor),
            map.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            map.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        
        map.addAnnotation(pin)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
    
}
