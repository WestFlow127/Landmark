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
    let authManager = LandmarkAuthManager.shared
    
    @Published var signedIn = false
    @Published var loginError: Error? {
        didSet {
            hasLoginError = loginError != nil
        }
    }
    @Published var hasLoginError: Bool = false

    func rememberEmail(email: String) {
        authManager.rememberedEmail = email
    }
    
    func signIn(email: String, password: String)
    {
        let auth = authManager.auth
        
        auth.signIn(withEmail: email, password: password)
        {
            [weak self] result, error in
        
            guard result != nil, error == nil else {
                self?.loginError = error
                return
            }
            
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
    
    func signUp(email: String, password: String)
    {
        let auth = authManager.auth

        auth.createUser(withEmail: email, password: password)
        {
            [weak self] result, error in
            
            guard result != nil, error == nil else {
                self?.loginError = error
                return
            }
            
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
    
    func logout()
    {
        do {
            try authManager.auth.signOut()
            
            debugPrint("Sign out success!")
        } catch {
            debugPrint("Sign Out Error: \(error)")
        }
        
        signedIn = false
    }
}
