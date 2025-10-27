//
//  Typography.swift
//  TripCost
//
//  Central typography tokens. Adjust sizes/weights after reviewing design.
//

import SwiftUI

public enum TCTypography {
    // Titles
    public static var largeTitle: Font { .system(size: 28, weight: .bold, design: .rounded) }
    public static var title: Font { .system(size: 22, weight: .semibold, design: .rounded) }
    public static var title2: Font { .system(size: 20, weight: .semibold, design: .rounded) }

    // Body
    public static var body: Font { .system(size: 14, weight: .regular, design: .default) }
    public static var callout: Font { .system(size: 13, weight: .regular, design: .default) }
    public static var caption: Font { .system(size: 12, weight: .regular, design: .default) }
    public static var footnote: Font { .system(size: 11, weight: .regular, design: .default) }

    // Labels
    public static var headline: Font { .system(size: 15, weight: .semibold, design: .default) }
    public static var subheadline: Font { .system(size: 13, weight: .medium, design: .default) }
}

public extension Text {
    func tcPrimaryStyle() -> some View { self.font(TCTypography.body).foregroundStyle(Color.tcTextPrimary) }
    func tcSecondaryStyle() -> some View { self.font(TCTypography.callout).foregroundStyle(Color.tcTextSecondary) }
}
