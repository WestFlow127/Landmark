//
//  LoginViewModel.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/19/22.
//

import FirebaseAuth
import Foundation

class LoginViewModel: ObservableObject {
    var authManager: AuthService = LandmarkAuthManager.shared

    var isSignedIn: Bool {
        self.authManager.isSignedIn
    }

    @Published var signedIn = false
    @Published var loginError: Error? {
        didSet {
            self.hasLoginError = self.loginError != nil
        }
    }

    @Published var hasLoginError: Bool = false

    func rememberEmail(email: String?) {
        self.authManager.rememberedEmail = email
    }

    func signIn(email: String, password: String) {
        self.authManager.signIn(withEmail: email, password: password) {
            [weak self] result, error in

            self?.handleSignInUpCallback(result, error)
        }
    }

    func signUp(email: String, password: String) {
        self.authManager.createUser(withEmail: email, password: password) {
            [weak self] result, error in

            self?.handleSignInUpCallback(result, error)
        }
    }

    func handleSignInUpCallback(_ result: Any?, _ error: Error?) {
        guard result != nil, error == nil else {
            self.loginError = error
            return
        }

        DispatchQueue.main.async {
            self.signedIn = true
        }
    }

    func logout() {
        do {
            try self.authManager.signOut()
        } catch {
            debugPrint("Sign Out Error: \(error)")
            return
        }

        self.signedIn = false

        debugPrint("Sign out success!")
    }
}
