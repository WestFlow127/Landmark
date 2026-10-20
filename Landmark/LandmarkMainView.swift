//
//  ContentView.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/3/22.
//

import CoreLocation
import MapKit
import Shiny
import SwiftUI

struct LandmarkMainView: View {
    @StateObject private var viewModel = LandmarkMainViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel

    @State private var selectedPlace: Landmark?

    var body: some View {
        VStack {
            ViewThatFits {
                Map(coordinateRegion: self.$viewModel.region,
                    showsUserLocation: true,
                    annotationItems: self.viewModel.landmarks)
                { landmark in

                    MapAnnotation(coordinate: landmark._2DCoord) {
                        VStack {
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
                            self.selectedPlace = landmark
                        }
                    }
                }
                .onAppear {
                    self.viewModel.setupLocationServices()
                }
            }
            .sheet(item: self.$selectedPlace) { landmark in
                let viewModel = SelectedLandmarkViewModel(landmark: landmark)

                SelectedLandmarkView(viewModel: viewModel)
            }
            .alert(isPresented: self.$viewModel.locationServicesOff) {
                Alert(
                    title: Text(self.viewModel.locationServicesOffReason),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .default(Text("Open Settings")) {
                        openAppSettings()
                    }
                )
            }
        }
        .toolbar {
            self.mainViewToolbar
        }
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
    }

    var mainViewToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .principal) {
                Text("Landmark")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .shiny()
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Logout", action: {
                        self.viewModel.landmarkProvider.cancelListeners()
                        self.loginViewModel.logout()
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

extension LandmarkMainView {
    // Function to open the app's settings
    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString)
        else {
            return
        }

        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
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
