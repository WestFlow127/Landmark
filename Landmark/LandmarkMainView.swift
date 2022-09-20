//
//  ContentView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/3/22.
//

import SwiftUI
import CoreLocation
import MapKit

struct LandmarkMainView: View {
    @StateObject private var viewModel = LandmarkMainViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel

    var body: some View {
        NavigationView {
    
            if loginViewModel.signedIn {
                VStack {
                    GeometryReader { proxy in
                        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                            .frame(width: proxy.size.width,
                                   height: proxy.size.height,
                                   alignment: .center)
                            .onAppear{
                                viewModel.checkIfLocationServicesIsEnabled()
                            }
                    }
                }
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Landmark")
                            .font(.largeTitle)
                            .bold()
                    }
                }
            } else {
                LoginMainView()
            }
        }
        .onAppear{
            loginViewModel.signedIn = loginViewModel.authManager.isSignedIn
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LandmarkMainView()
    }
}
