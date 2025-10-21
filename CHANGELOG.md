# Changelog

All notable changes to TripCost will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.1.0]: https://github.com/SOFTowaha/TripCost/compare/v1.0.4...v1.1.0
[1.0.4]: https://github.com/SOFTowaha/TripCost/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/SOFTowaha/TripCost/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/SOFTowaha/TripCost/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/SOFTowaha/TripCost/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/SOFTowaha/TripCost/releases/tag/v1.0.0
