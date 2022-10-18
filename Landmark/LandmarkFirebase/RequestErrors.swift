//
//  RequestErrors.swift
//  Landmark
//
//  Created by Weston Mitchell on 10/17/22.
//

import Foundation

enum DataResponseError: Error {
    case emptyData
    
    var reason: String {
        switch self {
        case .emptyData:
            return "No data received from endpoint"
        }
    }
}
