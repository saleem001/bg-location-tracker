# Background Location Tracker

A comprehensive Flutter package for background location tracking and multiple geofence management.

## Features
- 🚀 **Background Tracking**: Keep tracking location even when the app is in background or terminated.
- 📍 **Multi-Geofencing**: Add and manage multiple geofences simultaneously with dynamic names.
- 🔔 **Intelligent Notifications**: Automatic entry/exit notifications for each geofence.
- 🕒 **Headless Task Support**: Fully functional geofence handling in headless mode.
- 📊 **Real-time Status**: Track 'Arrived' and 'Depart' statuses for every station.

## Getting Started

### 1. Installation
Add the package to your `pubspec.yaml`:
```yaml
dependencies:
  bg_location_tracker:
    git:
      url: https://github.com/saleem001/bg-location-tracker.git
```

### 2. Native Setup

#### Android
Add permissions to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

#### iOS
Add to `Info.plist`:
```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to track trips.</string>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

### 3. Usage

Initialize the package in your `main.dart`:

```dart
import 'package:bg_location_tracker/bg_location_tracker.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init notifications
  await NotificationService().init();

  // 2. Register headless task
  bg.BackgroundGeolocation.registerHeadlessTask(backgroundGeolocationHeadlessTask);

  runApp(const ProviderScope(child: MyApp()));
}
```

Start tracking stations:
```dart
final viewModel = ref.read(locationTrackerViewModelProvider.notifier);

viewModel.startTrip(
  sourceLat: lat,
  sourceLng: lng,
  stations: [
    {'name': 'Station A', 'lat': 34.1, 'lng': 72.1},
    {'name': 'Station B', 'lat': 34.2, 'lng': 72.2},
  ],
);
```

Check the `example/` folder for a complete dashboard implementation.
