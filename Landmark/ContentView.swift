//
//  ContentView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/3/22.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { proxy in
                    MapView(coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060))
                        .frame(width: proxy.size.width,
                               height: proxy.size.height,
                               alignment: .center)
                }
            }
            .navigationTitle("Landmark")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
