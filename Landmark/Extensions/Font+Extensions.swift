//
//  Font+Extensions.swift
//  Landmark
//
//  Created by Weston Mitchell on 9/21/22.
//

import Foundation
import SwiftUI

extension Font {
    static let landmarkFont: (CGFloat) -> Font = { size in
        Font.custom("JosefinSans-Regular", size: size)
    }

    static let landmarkFontBold: (CGFloat) -> Font = { size in
        Font.custom("JosefinSans-SemiBold", size: size)
    }
}

// MARK: - Profile fonts

extension Font {
    /// Uses the bundled font when it's installed, otherwise the supplied system fallback.
    private static func bundled(_ name: String, size: CGFloat, fallback: Font) -> Font {
        UIFont(name: name, size: size) != nil ? Font.custom(name, size: size) : fallback
    }

    /// DM Sans: headings and body text.
    static func dmSans(_ size: CGFloat, semibold: Bool = false) -> Font {
        self.bundled(
            semibold ? "DMSans-SemiBold" : "DMSans-Regular",
            size: size,
            fallback: .system(size: size, weight: semibold ? .semibold : .regular, design: .rounded)
        )
    }

    /// IBM Plex Mono: small field labels.
    static func plexMono(_ size: CGFloat) -> Font {
        self.bundled(
            "IBMPlexMono-Medium",
            size: size,
            fallback: .system(size: size, weight: .medium, design: .monospaced)
        )
    }

    /// Roboto Condensed: buttons and secondary text.
    static func robotoCondensed(_ size: CGFloat, bold: Bool = false) -> Font {
        self.bundled(
            bold ? "RobotoCondensed-Bold" : "RobotoCondensed-Regular",
            size: size,
            fallback: .system(size: size, weight: bold ? .bold : .regular).width(.condensed)
        )
    }
}
