//
//  LandmarkApp.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/3/22.
//

import SwiftUI
import Firebase

@main
struct LandmarkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            let viewModel = LoginViewModel()
            
            LoginMainView()
                .environmentObject(viewModel)
                .onAppear{
                    viewModel.signedIn = viewModel.authManager.isSignedIn
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
}
