//
//  LandmarkAuthManager.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/19/22.
//

import FirebaseAuth
import Foundation

protocol AuthService {
    func signIn(withEmail email: String, password: String, completion: ((Any?, Error?) -> Void)?)
    func createUser(withEmail email: String, password: String, completion: ((Any?, Error?) -> Void)?)
    func signOut() throws

    var rememberedEmail: String? { get set }
    var isSignedIn: Bool { get }
}

final class LandmarkAuthManager: AuthService {
    static let shared = LandmarkAuthManager()

    private init() {}

    let auth = Auth.auth()

    private let rememberedEmailKey = "rememberedEmail"

    var isSignedIn: Bool {
        self.auth.currentUser != nil
    }

    var rememberedEmail: String? {
        get { UserDefaults.standard.string(forKey: self.rememberedEmailKey) }
        set { UserDefaults.standard.set(newValue, forKey: self.rememberedEmailKey) }
    }

    func signIn(withEmail email: String, password: String, completion: ((Any?, Error?) -> Void)?) {
        self.auth.signIn(withEmail: email, password: password, completion: completion)
    }

    func createUser(withEmail email: String, password: String, completion: ((Any?, Error?) -> Void)?) {
        self.auth.createUser(withEmail: email, password: password, completion: completion)
    }

    func signOut() throws {
        try self.auth.signOut()
    }
}
