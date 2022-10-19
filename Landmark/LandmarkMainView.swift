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
    
    @State private var selectedPlace: LandmarkEntity?
    
    var body: some View {
        VStack {
            ViewThatFits {
                Map(coordinateRegion: $viewModel.region,
                    showsUserLocation: true,
                    annotationItems: viewModel.landmarks) { landmark in
                    
                    MapAnnotation(coordinate: landmark._2DCoord) {
                        VStack{
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
                .onAppear{
                    viewModel.checkIfLocationServicesIsEnabled()
                }
            }
            .sheet(item: $selectedPlace) { landmark in
                let viewModel = SelectedLandmarkViewModel(landmark: landmark)

                SelectedLandmarkView(viewModel: viewModel)
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
