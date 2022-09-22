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
                    .bold()
            }
            ToolbarItem (placement: .navigationBarTrailing){
                Menu {
                    Button {
                        loginViewModel.logout()
                    } label: {
                        Text("Logout")
                    }
                } label: {
                    Label {
                        Text("Add")
                    } icon: {
                        Image(systemName: "plus")
                            .padding(.trailing, 7)
                    }
                }
                .frame(width: 35, height: 35, alignment: .center)
                .background(Color.white)
                .cornerRadius(25)
            }
        }
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LoginViewModel()
        
        LandmarkMainView()
            .environmentObject(viewModel)
    }
}
