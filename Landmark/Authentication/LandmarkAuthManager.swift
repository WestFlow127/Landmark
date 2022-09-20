//
//  LandmarkAuthManager.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/19/22.
//

import Foundation
import FirebaseAuth

final class LandmarkAuthManager {
    
    static let shared = LandmarkAuthManager()
    
    private init() {}
    
    let auth = Auth.auth()

    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    
}
