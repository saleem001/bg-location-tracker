import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

enum LocationPermissionStatus {
  //iOS only
  notRequested,
  restrictedBySystem,
  //android and iOS
  denied,
  allowedAlways,
  allowedWhenInUse;

  static LocationPermissionStatus fromInt(int value) {
    switch (value) {
      case bg.ProviderChangeEvent.AUTHORIZATION_STATUS_NOT_DETERMINED:
        return LocationPermissionStatus.notRequested;
      case bg.ProviderChangeEvent.AUTHORIZATION_STATUS_RESTRICTED:
        return LocationPermissionStatus.restrictedBySystem;
      case bg.ProviderChangeEvent.AUTHORIZATION_STATUS_DENIED:
        return LocationPermissionStatus.denied;
      case bg.ProviderChangeEvent.AUTHORIZATION_STATUS_ALWAYS:
        return LocationPermissionStatus.allowedAlways;
      case bg.ProviderChangeEvent.AUTHORIZATION_STATUS_WHEN_IN_USE:
        return LocationPermissionStatus.allowedWhenInUse;
      default:
        throw ArgumentError('Unknown authorization status: $value');
    }
  }

  /// Can the app access location at all?
  bool get isAuthorized =>
      this == LocationPermissionStatus.allowedAlways ||
      this == LocationPermissionStatus.allowedWhenInUse;

  /// Can the app access location in background?
  bool get allowsBackground => this == LocationPermissionStatus.allowedAlways;
}

//FULL or REDUCED, for iOS OS 14+ only and by default full for android,
// because even with location = on and permission allowed iOS gives approximate location if precise is off
enum LocationAccuracy {
  precise,
  reduced;

  static LocationAccuracy fromInt(int value) {
    switch (value) {
      case bg.ProviderChangeEvent.ACCURACY_AUTHORIZATION_FULL:
        return LocationAccuracy.precise;
      case bg.ProviderChangeEvent.ACCURACY_AUTHORIZATION_REDUCED:
        return LocationAccuracy.reduced;
      default:
        throw ArgumentError('Unknown accuracy authorization: $value');
    }
  }

  /// Is location precise enough for navigation / geofencing?
  bool get isPrecise => this == LocationAccuracy.precise;
}

class LocationServiceStatus {
  final bool deviceLocationEnabled;
  final LocationPermissionStatus locationPermissionStatus;
  final LocationAccuracy locationAccuracy;
  final bool gpsEnabled;
  final bool networkEnabled;

  LocationServiceStatus.map(bg.ProviderChangeEvent event)
    : deviceLocationEnabled = event.enabled,
      locationPermissionStatus = LocationPermissionStatus.fromInt(event.status),
      locationAccuracy = LocationAccuracy.fromInt(event.accuracyAuthorization),
      gpsEnabled = event.gps,
      networkEnabled = event.network;
}
