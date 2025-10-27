//
//  Components.swift
//  TripCost
//
//  Common reusable components styled with tokens.
//

import SwiftUI

// MARK: - Buttons
public struct PrimaryButtonStyle: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TCTypography.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: TCRadius.md, style: .continuous)
                    .fill(TCColor.primary)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Glass Button
public struct GlassButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TCTypography.headline)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                GlassBackgroundShape(
                    shape: RoundedRectangle(cornerRadius: TCRadius.md, style: .continuous),
                    tint: TCColor.primary
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: TCRadius.md, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [TCColor.primary.opacity(0.5), .clear],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ), lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1)
            .animation(AnimationConstants.spring, value: configuration.isPressed)
    }
}

// MARK: - Cards
public struct CardModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .padding(TCSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: TCRadius.lg, style: .continuous)
                    .fill(TCColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: TCRadius.lg, style: .continuous)
                    .stroke(TCColor.divider, lineWidth: 1)
            )
            .tcShadow(TCShadow.subtle)
    }
}

public extension View {
    func tcCard() -> some View { modifier(CardModifier()) }
    func tcGlassCard() -> some View { modifier(GlassCardModifier()) }
}

// MARK: - Section Header
public struct SectionHeader: View {
    let title: String
    let systemImage: String?

    public init(_ title: String, systemImage: String? = nil) {
        self.title = title
        self.systemImage = systemImage
    }

    public var body: some View {
        HStack(spacing: TCSpacing.sm) {
            if let systemImage {
                Image(systemName: systemImage).foregroundStyle(TCColor.secondary)
            }
            Text(title).font(TCTypography.headline)
            Spacer()
        }
        .padding(.bottom, TCSpacing.xs)
    }
}
