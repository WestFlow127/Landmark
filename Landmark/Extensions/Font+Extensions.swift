//
//  Font+Extensions.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/21/22.
//

import Foundation
import SwiftUI

extension Font
{
    static let landmarkFont: (CGFloat) -> Font = { size in
        Font.custom("JosefinSans-Regular", size: size)
    }
    
    static let landmarkFontBold: (CGFloat) -> Font = { size in
        Font.custom("JosefinSans-SemiBold", size: size)
    }
}
