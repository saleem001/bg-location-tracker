import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:track_me/common/mapper/data_mapper.dart';

class LocationTrackingEvent {
  final double latitude;
  final double longitude;
  final double speed; // received in m/s
  final double odometer; // received in meters
  final DateTime timestamp;
  LocationTrackingEvent({
    required this.latitude,
    required this.longitude,
    required this.speed,
    this.odometer = 0.0,
    required this.timestamp,
  });
}

class MotionChangeEvent {
  final LocationTrackingEvent location;
  final bool isMoving;
  MotionChangeEvent({required this.location, required this.isMoving});
}

class LocationMapper implements DataMapper<LocationTrackingEvent> {
  @override
  LocationTrackingEvent map(dynamic data) {
    final location = data as bg.Location;
    return LocationTrackingEvent(
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      speed: location.coords.speed,
      odometer: location.odometer,
      timestamp: DateTime.parse(location.timestamp),
    );
  }
}

class MotionChangeEventMapper implements DataMapper<MotionChangeEvent> {
  @override
  MotionChangeEvent map(dynamic data) {
    final location = data as bg.Location;
    return MotionChangeEvent(
      location: LocationMapper().map(location),
      isMoving: location.isMoving,
    );
  }
}
