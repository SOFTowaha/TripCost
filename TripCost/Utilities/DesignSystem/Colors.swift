//
//  Colors.swift
//  TripCost
//
//  Central color tokens for the app UI. Replace placeholder values after extracting from design screenshots.
//

import SwiftUI

public extension Color {
    // Brand
    static let tcPrimary = Color("tcPrimary") // TODO: set in Assets or replace with fixed Color
    static let tcSecondary = Color("tcSecondary") // TODO

    // Backgrounds
    static let tcBackground = Color("tcBackground") // window background
    static let tcSurface = Color("tcSurface") // cards, panels
    static let tcSurfaceAlt = Color("tcSurfaceAlt")

    // Content
    static let tcTextPrimary = Color("tcTextPrimary")
    static let tcTextSecondary = Color("tcTextSecondary")
    static let tcDivider = Color("tcDivider")

    // States
    static let tcSuccess = Color("tcSuccess")
    static let tcWarning = Color("tcWarning")
    static let tcError = Color("tcError")
}

// Fallbacks for previews and when asset colors are not yet defined
public struct TCColorFallbacks {
    public static let primary = Color.accentColor
    public static let secondary = Color.blue
    public static let background = Color(NSColor.windowBackgroundColor)
    public static let surface = Color(NSColor.underPageBackgroundColor)
    public static let surfaceAlt = Color(NSColor.controlBackgroundColor)
    public static let textPrimary = Color.primary
    public static let textSecondary = Color.secondary
    public static let divider = Color.gray.opacity(0.2)
    public static let success = Color.green
    public static let warning = Color.orange
    public static let error = Color.red
}

// Runtime switch to control whether to use asset colors (when available) or safe fallbacks.
public enum TCAppearance {
    // Set to true once asset colors are defined and verified.
    public static var useAssetColors: Bool = false
}

@inline(__always)
private func tokenColor(_ name: String, fallback: Color) -> Color {
    if TCAppearance.useAssetColors {
        return Color(name)
    } else {
        return fallback
    }
}

public enum TCColor {
    public static var primary: Color { tokenColor("tcPrimary", fallback: TCColorFallbacks.primary) }
    public static var secondary: Color { tokenColor("tcSecondary", fallback: TCColorFallbacks.secondary) }
    public static var background: Color { tokenColor("tcBackground", fallback: TCColorFallbacks.background) }
    public static var surface: Color { tokenColor("tcSurface", fallback: TCColorFallbacks.surface) }
    public static var surfaceAlt: Color { tokenColor("tcSurfaceAlt", fallback: TCColorFallbacks.surfaceAlt) }
    public static var textPrimary: Color { tokenColor("tcTextPrimary", fallback: TCColorFallbacks.textPrimary) }
    public static var textSecondary: Color { tokenColor("tcTextSecondary", fallback: TCColorFallbacks.textSecondary) }
    public static var divider: Color { tokenColor("tcDivider", fallback: TCColorFallbacks.divider) }
    public static var success: Color { tokenColor("tcSuccess", fallback: TCColorFallbacks.success) }
    public static var warning: Color { tokenColor("tcWarning", fallback: TCColorFallbacks.warning) }
    public static var error: Color { tokenColor("tcError", fallback: TCColorFallbacks.error) }
}
