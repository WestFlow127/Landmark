//
//  ContentView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/3/22.
//

import SwiftUI
import CoreLocation

struct LandmarkMainView: View {
    @StateObject private var viewModel = LandmarkMainViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { proxy in
                    MapView(region: $viewModel.region)
                        .frame(width: proxy.size.width,
                               height: proxy.size.height,
                               alignment: .center)
                        .onAppear{
                            viewModel.checkIfLocationServicesIsEnabled()
                        }
                }
            }
            .navigationTitle("Landmark")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkMainView()
    }
}
