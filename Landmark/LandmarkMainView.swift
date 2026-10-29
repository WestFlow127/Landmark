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
    @Environment(\.dependencies) private var dependencies
    @StateObject private var viewModel: LandmarkMainViewModel
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var selectedPlace: Landmark?
    @State private var isShowingProfile = false

    init(dependencies: AppDependencies) {
        _viewModel = StateObject(wrappedValue: LandmarkMainViewModel(landmarkProvider: dependencies.landmarkProvider))
    }

    var body: some View {
        VStack {
            ViewThatFits {
                ZStack(alignment: .bottomTrailing) {
                    Map(position: self.$viewModel.cameraPosition) {
                        UserAnnotation()

                        ForEach(self.viewModel.landmarks) { landmark in
                            Annotation(coordinate: landmark._2DCoord) {
                                VStack {
                                    Image(systemName: "star.circle")
                                        .resizable()
                                        .foregroundColor(.red)
                                        .frame(width: .mapAnnotationIconSize, height: .mapAnnotationIconSize)
                                        .background(.white)
                                        .clipShape(Circle())

                                    Text(landmark.name)
                                        .font(Font.caption)
                                        .lineLimit(2)
                                }
                                .onTapGesture {
                                    self.selectedPlace = landmark
                                }
                            } label: {
                                EmptyView()
                            }
                        }
                    }
                    .onAppear {
                        self.viewModel.setupLocationServices()
                    }
                    VStack(spacing: .spacingMedium) {
                        self.currentLocationButton
                        self.cameraButton
                    }
                    .padding(.trailing, .floatingButtonTrailingInset)
                    .padding(.bottom, .floatingButtonBottomInset)
                }
            }
            .sheet(item: self.$selectedPlace) { landmark in
                let viewModel = LandmarkCardViewModel(landmark: landmark)

                LandmarkCardView(viewModel: viewModel)
            }
            .alert(isPresented: self.$viewModel.locationServicesOff) {
                Alert(
                    title: Text(self.viewModel.locationServicesOffMessage),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .default(Text("Open Settings")) {
                        openAppSettings()
                    }
                )
            }
        }
        .fullScreenCover(isPresented: self.viewModel.isShowingCamera) {
            self.cameraView.ignoresSafeArea()
        }
        .navigationDestination(isPresented: self.viewModel.isEditing) {
            if let photo = self.viewModel.addLandmarkFlow.capturedPhoto {
                AddLandmarkView(
                    viewModel: AddLandmarkViewModel(
                        capturedPhoto: photo,
                        landmarkProvider: self.dependencies.landmarkProvider,
                        locationFetcher: self.dependencies.locationFetcher
                    )
                )
            }
        }
        .toolbar {
            self.mainViewToolbar
        }
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    var mainViewToolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Landmark")
                .font(.largeTitle)
                .fontWeight(.bold)
                .shiny(.hyperGlossy(UIColor.mainColor))
        }

        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                self.isShowingProfile = true
            } label: {
                Image(systemName: "person.fill")
                    .frame(width: 36, height: 36)
                    .shiny(.hyperGlossy(UIColor.mainColor))
            }
            .frame(width: 36, height: 36)
            .background(.ultraThinMaterial, in: Circle())
            .accessibilityLabel("Profile")
            .popover(isPresented: self.$isShowingProfile) {
                ProfileView()
                    .presentationCompactAdaptation(.popover)
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button("Logout", action: {
                    self.viewModel.landmarkProvider.cancelListeners()
                    self.loginViewModel.logout()
                })
            } label: {
                Image(systemName: "plus")
                    .frame(width: .toolbarButtonSize, height: .toolbarButtonSize)
                    .shiny(.hyperGlossy(UIColor.mainColor))
            }
            .frame(width: .toolbarButtonSize, height: .toolbarButtonSize)
            .background(.ultraThinMaterial, in: Circle())
        }
    }

    var cameraButton: some View {
        Button {
            self.viewModel.startAddLandmark()
        } label: {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: .floatingButtonIconSize, weight: .medium))
                .tint(.primary)
                .frame(width: .floatingButtonIconSize, height: .floatingButtonIconSize)
                .shiny(.hyperGlossy(UIColor.mainColor))
                .padding(.floatingButtonIconPadding)
        }
        .frame(width: .floatingButtonSize, height: .floatingButtonSize)
        .background(.ultraThinMaterial, in: Circle())
        .shadow(radius: .floatingButtonShadowRadius)
    }

    var currentLocationButton: some View {
        Button {
            self.viewModel.centerOnUserLocation()
        } label: {
            Image(systemName: "location.fill")
                .font(.system(size: .locationIconFontSize, weight: .medium))
                .tint(.primary)
                .frame(width: .floatingButtonIconSize, height: .floatingButtonIconSize)
                .shiny(.hyperGlossy(UIColor.mainColor))
                .padding(.floatingButtonIconPadding)
        }
        .frame(width: .floatingButtonSize, height: .floatingButtonSize)
        .background(.ultraThinMaterial, in: Circle())
        .shadow(radius: .floatingButtonShadowRadius)
    }

    @ViewBuilder
    var cameraView: some View {
        if CameraPicker.isCameraAvailable {
            CameraPicker(
                onCapture: self.viewModel.photoCaptured,
                onCancel: self.viewModel.cancelAddLandmark
            )
        } else {
            SimulatedCameraView(
                onCapture: self.viewModel.photoCaptured,
                onCancel: self.viewModel.cancelAddLandmark
            )
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
            LandmarkMainView(dependencies: AppDependencies())
                .environmentObject(viewModel)
        }
    }
}
