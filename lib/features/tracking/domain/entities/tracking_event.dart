import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:track_me/common/constants/app_constants.dart';
import 'package:track_me/common/mapper/data_mapper.dart';

class LocationTrackingEvent {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double altitudeAccuracy;
  final double heading;
  final double speed; // received in m/s
  final double speedAccuracy;
  final double odometer; // received in meters
  final DateTime timestamp;
  final bool isMoving;
  final double batteryLevel;
  final bool isMock;

  LocationTrackingEvent({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.altitudeAccuracy,
    required this.heading,
    required this.speed,
    required this.speedAccuracy,
    this.odometer = 0.0,
    required this.timestamp,
    this.isMoving = false,
    this.batteryLevel = 0.0,
    this.isMock = false,
  });
}

class MotionChangeEvent {
  final LocationTrackingEvent location;
  final bool isMoving;
  MotionChangeEvent({required this.location, required this.isMoving});
}

enum UserActivity {
  still,
  walking,
  running,
  onFoot,
  onBicycle,
  inVehicle,
  unknown;

  static UserActivity fromString(String value) {
    switch (value.toLowerCase()) {
      case AppConstants.activityStill:
        return UserActivity.still;

      case AppConstants.activityWalking:
        return UserActivity.walking;

      case AppConstants.activityRunning:
        return UserActivity.running;

      case AppConstants.activityOnFoot:
        return UserActivity.onFoot;

      case AppConstants.activityOnBicycle:
        return UserActivity.onBicycle;

      case AppConstants.activityInVehicle:
        return UserActivity.inVehicle;

      case AppConstants.activityUnknown:
      default:
        return UserActivity.unknown;
    }
  }

  /// Any form of human movement (not vehicle)
  bool get isHumanMovement =>
      this == UserActivity.walking ||
      this == UserActivity.running ||
      this == UserActivity.onFoot;

  /// Vehicle-based movement
  bool get isVehicle => this == UserActivity.inVehicle;

  /// Not moving
  bool get isStill => this == UserActivity.still;

  /// Can be trusted for motion decisions
  bool get isReliable => this != UserActivity.unknown;
}

class ActivityChangeEvent {
  final UserActivity activity;
  final int confidence;

  ActivityChangeEvent({required this.activity, required this.confidence});

  bool get isConfident => confidence >= 70;
}

class LocationTrackingEventMapper implements DataMapper<LocationTrackingEvent> {
  @override
  LocationTrackingEvent map(dynamic data) {
    final location = data as bg.Location;
    return LocationTrackingEvent(
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      accuracy: location.coords.accuracy,
      altitude: location.coords.altitude,
      altitudeAccuracy: location.coords.altitudeAccuracy,
      heading: location.coords.heading,
      speed: location.coords.speed,
      speedAccuracy: location.coords.speedAccuracy,
      odometer: location.odometer,
      timestamp: DateTime.parse(location.timestamp),
      isMoving: location.isMoving,
      batteryLevel: location.battery.level,
      isMock: location.mock,
    );
  }
}

class MotionChangeEventMapper implements DataMapper<MotionChangeEvent> {
  @override
  MotionChangeEvent map(dynamic data) {
    final location = data as bg.Location;
    return MotionChangeEvent(
      location: LocationTrackingEventMapper().map(location),
      isMoving: location.isMoving,
    );
  }
}

class ActivityChangeEventMapper implements DataMapper<ActivityChangeEvent> {
  @override
  ActivityChangeEvent map(dynamic data) {
    final event = data as bg.ActivityChangeEvent;
    return ActivityChangeEvent(
      activity: UserActivity.fromString(event.activity),
      confidence: event.confidence,
    );
  }
}
