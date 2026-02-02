class LocationEntity {
  final double latitude;
  final double longitude;
  final double speed; // In m/s
  final double odometer;
  final DateTime timestamp;
  LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.speed,
    this.odometer = 0.0,
    required this.timestamp,
  });
}

class GeofenceEvent {
  final String identifier;
  final String action;
  GeofenceEvent({required this.identifier, required this.action});
}

class ActivityChangeEvent {
  final String activity;
  final int confidence;
  ActivityChangeEvent({required this.activity, required this.confidence});
}

class ProviderChangeEvent {
  final bool enabled;
  final int status;
  final bool network;
  final bool gps;
  ProviderChangeEvent({
    required this.enabled,
    required this.status,
    required this.network,
    required this.gps,
  });
}

class HttpEvent {
  final bool success;
  final int status;
  final String responseText;
  HttpEvent({
    required this.success,
    required this.status,
    required this.responseText,
  });
}

class MotionChangeEvent {
  final LocationEntity location;
  final bool isMoving;
  MotionChangeEvent({required this.location, required this.isMoving});
}

class DomainTransistorToken {
  final String accessToken;
  final String refreshToken;
  final int expires;
  final String url;
  DomainTransistorToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expires,
    required this.url,
  });
}
