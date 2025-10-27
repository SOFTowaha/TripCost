//
//  Effects.swift
//  TripCost
//
//  Shadows and materials.
//

import SwiftUI

public enum TCShadow {
    public static let subtle = ShadowStyle(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    public static let elevated = ShadowStyle(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
}

public struct ShadowStyle {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
}

public extension View {
    func tcShadow(_ style: ShadowStyle) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

// MARK: - Glass Effects (iOS 15+/macOS 12+)
public struct TCGlassConfig {
    public var cornerRadius: CGFloat = TCRadius.lg
    public var strokeOpacity: CGFloat = 0.22
    public var highlightOpacity: CGFloat = 0.35
    public var shadowOpacity: CGFloat = 0.12
    public var shadowRadius: CGFloat = 12
    public var shadowY: CGFloat = 6

    public init(cornerRadius: CGFloat = TCRadius.lg) {
        self.cornerRadius = cornerRadius
    }
}

public struct GlassBackgroundShape<S: InsettableShape>: View {
    let shape: S
    let config: TCGlassConfig
    let tint: Color

    public init(shape: S, config: TCGlassConfig = .init(), tint: Color = TCColor.primary) {
        self.shape = shape
        self.config = config
        self.tint = tint
    }

    public var body: some View {
        shape
            .fill(.ultraThinMaterial)
            .overlay(
                // Soft tint sheen
                shape
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.12), .white.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.softLight)
            )
            .overlay(
                // Subtle inner highlight stroke
                shape
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(config.highlightOpacity), Color.white.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        ), lineWidth: 1
                    )
                    .opacity(0.9)
            )
            .overlay(
                // Outer stroke to define edge
                shape
                    .strokeBorder(Color.white.opacity(config.strokeOpacity), lineWidth: 0.75)
            )
            .shadow(color: .black.opacity(config.shadowOpacity), radius: config.shadowRadius, x: 0, y: config.shadowY)
    }
}

public struct GlassCardModifier: ViewModifier {
    let config: TCGlassConfig
    let tint: Color

    public init(config: TCGlassConfig = .init(), tint: Color = TCColor.primary) {
        self.config = config
        self.tint = tint
    }

    public func body(content: Content) -> some View {
        content
            .padding(TCSpacing.lg)
            .background(
                GlassBackgroundShape(
                    shape: RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous),
                    config: config,
                    tint: tint
                )
            )
    }
}

public struct GlassBarModifier: ViewModifier {
    let config: TCGlassConfig
    let tint: Color

    public init(config: TCGlassConfig = .init(cornerRadius: TCRadius.md), tint: Color = TCColor.primary) {
        self.config = config
        self.tint = tint
    }

    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, TCSpacing.md)
            .padding(.vertical, TCSpacing.sm)
            .background(
                GlassBackgroundShape(
                    shape: Capsule(style: .continuous),
                    config: config,
                    tint: tint
                )
            )
    }
}

public extension View {
    func tcGlassCard(cornerRadius: CGFloat = TCRadius.lg, tint: Color = TCColor.primary) -> some View {
        modifier(GlassCardModifier(config: .init(cornerRadius: cornerRadius), tint: tint))
    }

    func tcGlassBar(tint: Color = TCColor.primary) -> some View {
        modifier(GlassBarModifier(tint: tint))
    }

    func tcGlassBackground() -> some View {
        background(
            LinearGradient(
                colors: [TCColor.background.opacity(0.65), TCColor.background.opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(.thinMaterial)
    }
}
