//
//  LandmarkApp.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/3/22.
//

import Firebase
import SwiftUI

@main
struct LandmarkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            let viewModel = LoginViewModel()

            LoginMainView()
                .environmentObject(viewModel)
                .onAppear {
                    viewModel.signedIn = viewModel.authManager.isSignedIn
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
}
