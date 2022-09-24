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
                SelectedLandmarkView(landmark: landmark)
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
        
        NavigationStack {
            LandmarkMainView()
                .environmentObject(viewModel)
        }
    }
}
