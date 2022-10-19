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

struct LandmarkMainView: View {
    @StateObject private var viewModel = LandmarkMainViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    var body: some View {
        VStack {
            mapLayer
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Landmark")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .shiny()
            }
            
            ToolbarItem (placement: .navigationBarTrailing){
                menu
            }
        }
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LoginViewModel()
        
        NavigationStack {
            LandmarkMainView()
                .environmentObject(viewModel)
        }
    }
}

extension LandmarkMainView {
    private var mapLayer: some View {
        ViewThatFits {
            Map(coordinateRegion: $viewModel.region,
                showsUserLocation: true,
                annotationItems: viewModel.landmarks) { landmark in
                
                MapAnnotation(coordinate: landmark._2DCoord) {
                    LandmarkAnnotationView(name: landmark.name)
                        .onTapGesture {
                            viewModel.selectedLandmark = landmark
                        }
                }
            }
            .onAppear{
                viewModel.checkIfLocationServicesIsEnabled()
            }
        }
        .sheet(item: $viewModel.selectedLandmark) { landmark in
            SelectedLandmarkView(selectedLandmark: landmark)
                .environmentObject(viewModel)
        }
    }
    
    private var menu: some View {
        Menu {
            Button("Logout", action: {
                viewModel.landmarkProvider.cancelListeners()
                loginViewModel.logout()
            })
        } label: {
            Image(systemName: "plus")
                .padding(.trailing, 7)
                .shiny()
        }
        .frame(width: 36, height: 36, alignment: .center)
        .background(Color.white)
        .cornerRadius(36/2)
    }
}
