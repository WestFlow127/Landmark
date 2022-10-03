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
            ViewThatFits {
                Map(coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    annotationItems: viewModel.landmarks) { landmark in
                    
                    MapAnnotation(coordinate: landmark._2DCoord) {
                        Rectangle().stroke(Color.blue)
                            .frame(width: 20, height: 20)
                    }
                }
                    .onAppear{
                        viewModel.checkIfLocationServicesIsEnabled()
                    }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Landmark")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .shiny()
            }
            
            ToolbarItem (placement: .navigationBarTrailing){
                Menu {
                    Button("Logout", action: {
                        viewModel.landmarkProvider.cancelListeners()
                        loginViewModel.logout
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
