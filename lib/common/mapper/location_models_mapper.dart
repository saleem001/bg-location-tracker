import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import '../models/location_events.dart';
import 'data_mapper.dart';

class LocationMapper implements DataMapper<LocationEntity> {
  @override
  LocationEntity map(dynamic data) {
    final location = data as bg.Location;
    return LocationEntity(
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      speed: location.coords.speed,
      odometer: location.odometer,
      timestamp: DateTime.parse(location.timestamp),
    );
  }
}

class GeofenceEventMapper implements DataMapper<GeofenceEvent> {
  @override
  GeofenceEvent map(dynamic data) {
    final event = data as bg.GeofenceEvent;
    return GeofenceEvent(identifier: event.identifier, action: event.action);
  }
}

class ActivityChangeEventMapper implements DataMapper<ActivityChangeEvent> {
  @override
  ActivityChangeEvent map(dynamic data) {
    final event = data as bg.ActivityChangeEvent;
    return ActivityChangeEvent(
      activity: event.activity,
      confidence: event.confidence,
    );
  }
}

class ProviderChangeEventMapper implements DataMapper<ProviderChangeEvent> {
  @override
  ProviderChangeEvent map(dynamic data) {
    final event = data as bg.ProviderChangeEvent;
    return ProviderChangeEvent(
      enabled: event.enabled,
      status: event.status,
      network: event.network,
      gps: event.gps,
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

// Top-level mapping functions for Config policies
bg.DesiredAccuracy mapAccuracy(int l) => l >= 5
    ? bg.DesiredAccuracy.navigation
    : (l >= 4 ? bg.DesiredAccuracy.high : bg.DesiredAccuracy.medium);

bg.PersistMode mapPersistMode(int m) => m == 0
    ? bg.PersistMode.none
    : (m == 1 ? bg.PersistMode.location : bg.PersistMode.all);

int mapLogLevel(int l) => l >= 2
    ? 5 // Verbose
    : (l >= 1 ? 4 : 0); // Debug or Off

bg.NotificationPriority mapPriority(int p) {
  if (p >= 2) return bg.NotificationPriority.max;
  if (p >= 1) return bg.NotificationPriority.high;
  if (p <= -2) return bg.NotificationPriority.min;
  if (p <= -1) return bg.NotificationPriority.low;
  return bg.NotificationPriority.defaultPriority;
}
