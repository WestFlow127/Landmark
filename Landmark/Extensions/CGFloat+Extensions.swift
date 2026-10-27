//
//  CGFloat+Extensions.swift
//  Landmark
//

import SwiftUI

extension CGFloat {
    // MARK: Spacing

    /// 8pt, e.g. between an icon and its label.
    static let spacingSmall: CGFloat = 8
    /// 12pt, e.g. between stacked floating buttons.
    static let spacingMedium: CGFloat = 12
    /// 16pt, e.g. between the sections of a form or card.
    static let spacingLarge: CGFloat = 16

    // MARK: Padding

    /// 6pt vertical padding inside a prominent button.
    static let buttonVerticalPadding: CGFloat = 6
    /// 14pt padding around the icon of a floating circular button.
    static let floatingButtonIconPadding: CGFloat = 14
    /// 20pt inset of floating buttons from the trailing edge.
    static let floatingButtonTrailingInset: CGFloat = 20
    /// 40pt inset of floating buttons from the bottom edge.
    static let floatingButtonBottomInset: CGFloat = 40

    // MARK: Corner radius

    /// 12pt corner radius for images and cards.
    static let cornerRadiusMedium: CGFloat = 12

    // MARK: Sizes

    /// 25pt map annotation icon.
    static let mapAnnotationIconSize: CGFloat = 25
    /// 36pt toolbar circle button.
    static let toolbarButtonSize: CGFloat = 36
    /// 52pt floating circle button.
    static let floatingButtonSize: CGFloat = 52
    /// 28pt icon frame inside a floating circle button.
    static let floatingButtonIconSize: CGFloat = 28
    /// 24pt font size for the current location icon.
    static let locationIconFontSize: CGFloat = 24

    // MARK: Effects

    /// 2pt shadow radius for floating buttons.
    static let floatingButtonShadowRadius: CGFloat = 2
}
