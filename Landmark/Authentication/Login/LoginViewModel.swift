//
//  LoginViewModel.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/19/22.
//

import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject
{
    var authManager: AuthService = LandmarkAuthManager.shared
    
    var isSignedIn: Bool {
        authManager.isSignedIn
    }
    
    @Published var signedIn = false
    @Published var loginError: Error? {
        didSet {
            hasLoginError = loginError != nil
        }
    }
    @Published var hasLoginError: Bool = false

    func rememberEmail(email: String?) {
        authManager.rememberedEmail = email
    }
    
    func signIn(email: String, password: String)
    {
        authManager.signIn(withEmail: email, password: password)
        {
            [weak self] result, error in
        
            self?.handleSignInUpCallback(result, error)
        }
    }
    
    func signUp(email: String, password: String)
    {
        authManager.createUser(withEmail: email, password: password)
        {
            [weak self] result, error in
            
            self?.handleSignInUpCallback(result, error)
        }
    }
    
    func handleSignInUpCallback(_ result: Any?, _ error: Error?)
    {
        guard result != nil, error == nil else {
            self.loginError = error
            return
        }
        
        DispatchQueue.main.async {
            self.signedIn = true
        }
    }
    
    func logout()
    {
        do {
            try authManager.signOut()
            
            debugPrint("Sign out success!")
        } catch {
            debugPrint("Sign Out Error: \(error)")
        }
        
        signedIn = false
    }
}
