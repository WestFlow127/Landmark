//
//  ContentView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/3/22.
//

import SwiftUI
import CoreLocation
import MapKit
import Shiny

struct LandmarkMainView: View
{
    @StateObject private var viewModel = LandmarkMainViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    @State private var selectedPlace: LandmarkEntity?
    
    var body: some View
    {
        VStack
        {
            ViewThatFits
            {
                Map(coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    annotationItems: viewModel.landmarks)
                { landmark in
                    
                    MapAnnotation(coordinate: landmark._2DCoord)
                    {
                        VStack
                        {
                            Image(systemName: "star.circle")
                                .resizable()
                                .foregroundColor(.red)
                                .frame(width: 25, height: 25)
                                .background(.white)
                                .clipShape(Circle())
                            
                            Text(landmark.name)
                                .font(Font.caption)
                                .lineLimit(2)
                        }
                        .onTapGesture {
                            selectedPlace = landmark
                        }
                    }
                }
                .onAppear {
                    viewModel.setupLocationServices()
                }
            }
            .sheet(item: $selectedPlace) { landmark in
                let viewModel = SelectedLandmarkViewModel(landmark: landmark)

                SelectedLandmarkView(viewModel: viewModel)
            }
            .alert(isPresented: $viewModel.locationServicesOff) {
                Alert(
                    title: Text(viewModel.locationServicesOffReason),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .default(Text("Open Settings")) {
                        openAppSettings()
                    }
                )
            }
        }
        .toolbar {
            mainViewToolbar
        }
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var mainViewToolbar: some ToolbarContent
    {
        Group
        {
            ToolbarItem(placement: .principal)
            {
                Text("Landmark")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .shiny()
            }
            
            ToolbarItem(placement: .navigationBarTrailing)
            {
                Menu
                {
                    Button("Logout", action: {
                        viewModel.landmarkProvider.cancelListeners()
                        loginViewModel.logout()
                    })
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 36, height: 36)
                        .shiny()
                }
                .frame(width: 36, height: 36, alignment: .trailing)
                .background(.white.opacity(0.85))
                .cornerRadius(18)
                .shadow(radius: 1, y: 1)
            }
        }
    }
}

extension LandmarkMainView
{
    // Function to open the app's settings
    private func openAppSettings()
    {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString)
        else {
            return
        }
        
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        let viewModel = LoginViewModel()
        
        NavigationStack {
            LandmarkMainView()
                .environmentObject(viewModel)
        }
    }
}
