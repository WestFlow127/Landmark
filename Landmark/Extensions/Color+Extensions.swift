//
//  Color+Extensions.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/19/22.
//

import Foundation
import SwiftUI

extension Color {
    static let mainColor = Color("landmarkMainColor")

    /// Input background that stands out from a material popover: near-white in light mode,
    /// a lifted gray in dark mode.
    static let inputBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.14)
            : UIColor(white: 1, alpha: 0.9)
    })

    /// Hairline outline for inputs, tuned per appearance.
    static let inputBorder = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.18)
            : UIColor(white: 0, alpha: 0.12)
    })
}
