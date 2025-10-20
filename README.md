# TripCost

A modern macOS trip cost calculator with beautiful glass UI design.

[![Build and Test](https://github.com/SOFTowaha/TripCost/actions/workflows/build.yml/badge.svg)](https://github.com/SOFTowaha/TripCost/actions/workflows/build.yml)
[![Release](https://github.com/SOFTowaha/TripCost/actions/workflows/release.yml/badge.svg)](https://github.com/SOFTowaha/TripCost/actions/workflows/release.yml)

## Features

✨ **Modern Glass UI** - Beautiful frosted glass design inspired by macOS Big Sur and later  
🗺️ **Interactive Map** - Plan your trips with Apple Maps integration  
⛽ **Fuel Cost Calculation** - Calculate trip costs based on vehicle fuel efficiency  
🚗 **Vehicle Management** - Save and manage multiple vehicles  
💰 **Cost Splitting** - Split costs among multiple travelers  
💱 **Multi-Currency** - Support for multiple currencies  
📊 **Detailed Breakdown** - View fuel costs and additional expenses  


## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0+ (for development)

## Installation

### Download Release

1. Download the latest release from [Releases](https://github.com/SOFTowaha/TripCost/releases)
2. Open the DMG file
3. Drag TripCost to your Applications folder
4. Launch TripCost from Applications

### Build from Source

```bash
git clone https://github.com/SOFTowaha/TripCost.git
cd TripCost
open TripCost.xcodeproj
```
## Screenshots

Screenshots of the app are available in the [`screenshots`](./screenshots) directory:

| Page                | Screenshot                                  |
|---------------------|---------------------------------------------|
| Main View           | ![Main View](screenshots/main_view.png)      |
| Add Vehicle         | ![Add Vehicle](screenshots/add_vehicle.png)  |
| Add Cost            | ![Add Cost](screenshots/add_cost.png)        |
| Cost Breakdown      | ![Cost Breakdown](screenshots/cost_breakdown.png) |
| Settings            | ![Settings](screenshots/settings.png)        |
| Map Selection       | ![Map Selection](screenshots/map_selection.png) | ✅

> To update screenshots, use the provided script in the project root.

Then build and run in Xcode (⌘R)

## Usage

1. **Select Route**: Choose your starting point and destination on the map
2. **Choose Vehicle**: Select or add a vehicle with its fuel efficiency
3. **Calculate Cost**: View detailed cost breakdown including fuel and additional expenses
4. **Split Costs**: Divide the total cost among multiple travelers
5. **Manage Settings**: Adjust currency, units, and fuel prices

## Architecture

- **SwiftUI** - Modern declarative UI framework
- **MapKit** - Apple Maps integration
- **Observation** - New Swift observation framework
- **MVVM** - Model-View-ViewModel architecture

## Development

### Project Structure

```
TripCost/
├── Models/          # Data models (Vehicle, TripRoute, Currency, etc.)
├── ViewModels/      # Business logic and state management
├── Views/           # SwiftUI views
├── Services/        # API services and data persistence
└── Utilities/       # Helper functions and constants
```

### CI/CD

This project uses GitHub Actions for continuous integration and deployment:

- **Build Workflow**: Runs on every push and PR to ensure code builds successfully
- **Release Workflow**: Creates DMG and ZIP packages when a new version tag is pushed

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

[Choose your license - MIT, Apache 2.0, etc.]

## Author

**Syed Omar Faruk Towaha**

- GitHub: [@SOFTowaha](https://github.com/SOFTowaha)

## Acknowledgments

- Apple Maps for routing and location services
- SwiftUI for the modern UI framework
- The macOS development community

---

Made with ❤️ for macOS
