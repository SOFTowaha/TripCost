# Changelog

All notable changes to TripCost will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.3] - 2025-10-27

### 🔐 Security & Configuration
- **Keychain Storage**: Added secure API key storage via macOS Keychain with UI in Settings
- **Weather API Configuration UI**: New Settings section to manage OpenWeatherMap API key
  - Secure text field with show/hide toggle
  - Save to Keychain and Remove buttons with visual feedback
  - Persistent storage across app launches

### ✨ Enhanced
- Updated `ConfigurationManager` priority system: Keychain → Environment variable → Info.plist → .env (Debug only)
- Added app sandbox entitlements with network client access for weather API
- Debug-only logging for API key warnings to avoid console spam in Release builds

### 🔧 Technical
- Implemented `KeychainService` utility for secure credential storage with macOS Keychain
- Project now includes `TripCost.entitlements` with sandbox and network permissions
- Updated project.pbxproj to reference entitlements in build configuration

### 📝 Documentation
- Updated README with Keychain-based API key management feature
- Enhanced configuration instructions with multiple setup options

## [1.1.2] - 2025-10-27

### 🔐 Security
- Migrated OpenWeather API key handling to `.env` (git-ignored)
- Removed leaked key from repo history using git-filter-repo
- Updated `.env.example` and docs to use placeholders
- **Keychain Storage**: Added secure API key storage via macOS Keychain with UI in Settings

### ✨ Enhanced
- **Weather API Configuration UI**: New Settings section to manage OpenWeatherMap API key with show/hide, save to Keychain, and remove functionality
- Weather card in Route Preview shows a loading state and clear fallback when unavailable
- Config system via `ConfigurationManager` with multiple priority levels: Keychain → Environment variable → Info.plist → .env (Debug only)
- Added app sandbox entitlements with network client access for weather API

### 🐛 Fixed
- Resolved a merge conflict artifact and cleaned Xcode user state from version control
- Build reliability in terminal by avoiding Anaconda linker conflicts (documented clean PATH usage)
- Debug-only logging for API key warnings to avoid console spam in Release builds

### 📝 Documentation
- Added `docs/CONFIGURATION.md` and updated `docs/WEATHER_SETUP.md`
- Added `docs/ENV_MIGRATION.md` detailing the move to environment-based secrets
- Updated README with Keychain-based API key management feature

### 🔧 Technical
- Implemented `KeychainService` utility for secure credential storage
- Updated `ConfigurationManager` priority system for API key resolution
- Project now includes `TripCost.entitlements` with sandbox and network permissions

## [1.1.1] - 2025-10-27

### ✨ Enhanced
- Glass design system applied across the app (cards, buttons, backgrounds) for a cohesive frosted look
- Centered From/To fields on Trip page for better focus and usability
- Compact, native toolbar controls with labels where appropriate

### 🐛 Fixed
- Reset button sizing and label visibility on Trip page
- “Add Vehicle” toolbar icon hover outline and alignment; uses plain style with label and small control size
- Stroke rendering compile error by constraining glass shape to `InsettableShape`
- Saved page rows styled as glass cards; separators hidden and row backgrounds cleared

## [1.1.0] - 2025-10-21

### 🎉 Added
- **Saved Trips Feature**: Save and manage trip history with full route details, costs, and vehicle information
- **Editable Saved Trips**: Edit number of people splitting costs with live cost-per-person recalculation
- **Location Name Tracking**: Automatic capture of place names from map selections for better trip identification
- **Share Trips**: Share saved trip details with friends
- **Fuel Cost Display**: View fuel costs in saved trip details
- **Auto-Generated Trip Names**: Trips automatically named as "Start Location → End Location"
- **Glass-Themed UI**: Beautiful frosted glass design for saved trip detail pages

### 🐛 Fixed
- **MapKit Coordinate Access**: Fixed incorrect use of `item.location.coordinate` to proper `item.placemark.coordinate`
- **GitHub Actions Build**: Removed architecture-specific flags to support universal binary builds (both Intel and Apple Silicon)
- **Address Persistence**: Fixed async/await race conditions causing addresses to be overwritten
- **Swift 6 Warnings**: Resolved actor isolation warnings for delegate methods

### ✨ Enhanced
- **Live Cost Calculations**: Real-time cost-per-person updates when editing saved trips
- **Improved Address Flow**: Better address handling through the trip save workflow
- **Type-Checking Performance**: Optimized Swift compiler type-checking with simplified expressions

### 🔧 Technical
- Updated to modern MapKit APIs
- Improved async/await handling for location services
- Universal binary support for macOS (arm64 + x86_64)
- CI/CD improvements for automated builds

### 📝 Documentation
- Updated README with feature completion dates
- Added feature timeline (October 2025)

## [1.0.4] - 2025-10-XX

### Added
- Vehicle selector improvements
- CI/CD workflow enhancements

### Fixed
- Build configuration issues
- Vehicle selection UI improvements

## [1.0.3] - 2025-10-XX

### Added
- Screenshots to documentation
- README improvements

## [1.0.2] - 2025-10-XX

### Added
- Screenshots feature
- Documentation updates

## [1.0.1] - 2025-10-XX

### Fixed
- Migration to modern MapKit APIs for macOS 26.0
- Code cleanup and optimization

## [1.0.0] - 2025-10-XX

### 🎉 Initial Release

#### Features
- **Modern Glass UI**: Beautiful frosted glass design inspired by macOS Big Sur
- **Interactive Map**: Plan trips with Apple Maps integration
- **Fuel Cost Calculation**: Calculate costs based on vehicle fuel efficiency
- **Vehicle Management**: Save and manage multiple vehicles
- **Cost Splitting**: Split costs among multiple travelers
- **Multi-Currency Support**: Calculate costs in different currencies
- **Detailed Cost Breakdown**: View fuel costs and additional expenses
- **Additional Costs**: Add parking, tolls, and other expenses

#### Technical Stack
- SwiftUI for modern UI
- MapKit for maps and location services
- CoreLocation for GPS functionality
- MVVM architecture
- JSON-based data persistence

---

[1.1.3]: https://github.com/SOFTowaha/TripCost/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/SOFTowaha/TripCost/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/SOFTowaha/TripCost/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/SOFTowaha/TripCost/compare/v1.0.4...v1.1.0
[1.0.4]: https://github.com/SOFTowaha/TripCost/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/SOFTowaha/TripCost/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/SOFTowaha/TripCost/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/SOFTowaha/TripCost/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/SOFTowaha/TripCost/releases/tag/v1.0.0
