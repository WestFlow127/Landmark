//
//  RequestErrors.swift
//  Landmark
//
//  Created by Weston Mitchell on 10/17/22.
//

import Foundation

enum DataResponseError: Error {
    case emptyData
    case missingId
    case imageEncodingFailed
    case notSignedIn

    var reason: String {
        switch self {
        case .emptyData:
            return "No data received from endpoint"
        case .missingId:
            return "The landmark has no identifier"
        case .imageEncodingFailed:
            return "The photo could not be prepared for upload"
        case .notSignedIn:
            return "No user is signed in"
        }
    }
}
