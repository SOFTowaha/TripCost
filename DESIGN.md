# TripCost Design System

This document defines the design tokens and reusable UI components for TripCost so that all new UI follows a consistent visual language. Update these values once the final design (screenshots) is confirmed.

## Tokens

- Colors (in `Utilities/DesignSystem/Colors.swift`)
  - `TCColor.primary, secondary`
  - `TCColor.background, surface, surfaceAlt`
  - `TCColor.textPrimary, textSecondary, divider`
  - `TCColor.success, warning, error`
  - Toggle `TCAppearance.useAssetColors = true` once named colors exist in the asset catalog (tcPrimary, tcSecondary, ...).

- Typography (in `Utilities/DesignSystem/Typography.swift`)
  - Sizes/weights for `largeTitle, title, title2, headline, subheadline, body, callout, caption, footnote`

- Spacing and radii (in `Utilities/DesignSystem/Spacing.swift`)
  - Spacing: `xxs, xs, sm, md, lg, xl, xxl`
  - Radii: `sm, md, lg, xl`

- Effects (in `Utilities/DesignSystem/Effects.swift`)
  - Shadows: `TCShadow.subtle, .elevated`
  - Glass: `tcGlassBackground(), tcGlassCard(), tcGlassBar()` and low-level `GlassBackgroundShape` with `TCGlassConfig`

## Components (in `Utilities/DesignSystem/Components.swift`)

- `PrimaryButtonStyle` — bold rounded primary action button
  - Usage: `Button("Save") { ... }.buttonStyle(PrimaryButtonStyle())`
- `tcCard()` — card container with surface fill, divider stroke, and subtle shadow
  - Usage: `VStack { ... }.tcCard()`
- `tcGlassCard()` — frosted glass card with tint sheen, highlight stroke, and soft shadow
  - Usage: `VStack { ... }.tcGlassCard()` or `modifier(GlassCardModifier(config: .init(cornerRadius: 20)))`
- `GlassButtonStyle` — frosted button with springy press animation
  - Usage: `Button("Action") { ... }.buttonStyle(GlassButtonStyle())`
- `SectionHeader` — standardized section title with optional SF Symbol
  - Usage: `SectionHeader("Fuel Pricing", systemImage: "fuelpump.fill")`

## Adoption Guidelines

- Prefer `TCColor.*` tokens for all colors. Avoid raw `.blue`, `.green`, etc. Use state colors for alerts/success.
- Prefer `TCTypography` sizes over raw `.font(.system(size:))`.
- Use `TCSpacing` and `TCRadius` for layout paddings and corner radii.
- Prefer frosted styles: Wrap content blocks in `.tcGlassCard()` and use `GlassButtonStyle` instead of hand-rolled `.background(.ultraThinMaterial, ...)`.
- Keep animations subtle and use system defaults unless a component defines its own.

## Assets

Create named colors in `Assets.xcassets` to match the token names below and then set `TCAppearance.useAssetColors = true`:

- tcPrimary
- tcSecondary
- tcBackground
- tcSurface
- tcSurfaceAlt
- tcTextPrimary
- tcTextSecondary
- tcDivider
- tcSuccess
- tcWarning
- tcError

Each named color should define both Light and Dark variants to support system appearance.

## Next Steps

- Extract tokens from screenshots and update the source files.
- Replace ad-hoc styles in screens with tokens and components incrementally to avoid large diffs.
- Add previews to verify appearance in light/dark modes and various dynamic type settings.
