# Supercharger Bingo

A fast, cross-platform check-in app for tracking Tesla Supercharger visits. Built with Flutter for mobile, desktop (Linux/macOS/Windows), and web.

## Features

- **Interactive Map**: Browse thousands of Tesla Supercharger locations worldwide with filtering by status (open, construction, planned) and visit history
- **Quick Check-in**: Find and check in to nearby Superchargers with a single tap
- **First Visit Tracking**: See which locations are eligible for first check-ins (no previous community visits)
- **Offline Support**: Local SQLite database syncs with supercharging.life API when connected
- **Smart Location**: Automatic fallback from GPS to IP-based geolocation on desktop platforms
- **Real-time Updates**: Live location marker with heading and accuracy indicators
- **Cross-platform**: Runs on Android, iOS, Linux, macOS, Windows, and web browsers

## Getting Started

### Prerequisites
- Flutter SDK 3.10.1 or later
- For Android: USB debugging enabled on device
- For Linux: Ensure GeoClue2 is installed for location services

### Installation

```bash
flutter pub get
flutter run
```

### Running on Devices

**Android/iOS via USB:**
```bash
flutter devices              # List connected devices
flutter run -d <device-id>   # Run on specific device
```

**Linux Desktop:**
```bash
flutter run -d linux
```

**Web:**
```bash
flutter run -d chrome
```

For release hosting, browser checks and the live authentication release gate, see
[Web deployment](docs/web-deployment.md).

## Architecture

- **Frontend**: Flutter with Material Design 3
- **Database**: Drift (SQLite) with automatic migrations
- **Mapping**: flutter_map with OpenStreetMap tiles and location marker plugin
- **Location**: Geolocator with IP-based fallback (ip-api.com) for desktop platforms
- **API**: supercharge.info for site data, supercharging.life for check-ins
- **State**: Provider pattern for authentication and settings

## Development

**Hot reload during development:**
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

**Run tests:**
```bash
flutter test
```

**Generate database code:**
```bash
flutter pub run build_runner build
```

## License

See LICENSE file for details.
