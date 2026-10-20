//
//  LandmarkConstants.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/21/22.
//

import Foundation

final class FirebaseConstants {
    let landmarkCollection = "landmarks"

    /// singleton instance
    static let shared = FirebaseConstants()

    private init() {}
}
