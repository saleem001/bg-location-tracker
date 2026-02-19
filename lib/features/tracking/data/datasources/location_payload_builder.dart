import 'package:bg_location_tracker/features/tracking/domain/entities/captain_location_data.dart';
import 'package:bg_location_tracker/features/tracking/domain/entities/tracking_event.dart';

class LocationPayloadBuilder {
  LocationTrackingEvent? _location;
  String? _captainId;
  String? _rideId;
  String? _tripStatus;
  double? _batteryLevel;
  String? _deviceName;
  bool? _isOnline;
  String? _connectionType;

  LocationPayloadBuilder setLocationFromEvent(LocationTrackingEvent location) {
    _location = location;
    return this;
  }

  LocationPayloadBuilder setCaptainInfo({
    required String captainId,
    required String rideId,
    required String tripStatus,
  }) {
    _captainId = captainId;
    _rideId = rideId;
    _tripStatus = tripStatus;
    return this;
  }

  LocationPayloadBuilder setDeviceInfo({required String deviceName,
    required double batteryLevel,}) {
    _deviceName = deviceName;
    _batteryLevel = batteryLevel;
    return this;
  }

  LocationPayloadBuilder setNetworkInfo({
    required bool isOnline,
    required String connectionType,
  }) {
    _isOnline = isOnline;
    _connectionType = connectionType;
    return this;
  }

  CaptainLocationData build() {
    if (_location == null) throw Exception("Location is required");

    final locationData = LocationData(
      accuracy: _location!.accuracy.toString(),
      altitude: _location!.altitude.toString(),
      androidId: "UNKNOWN", // Should get real android ID
      bearing: _location!.heading.toString(),
      bearingAccuracyDegrees: "0.0",
      elapsedRealtimeNanos: "0",
      lat: _location!.latitude.toString(),
      lng: _location!.longitude.toString(),
      runCounter: "1",
      sequence: "1",
      speed: _location!.speed.toString(),
      speedAccuracyMetersPerSecond: _location!.speedAccuracy.toString(),
      timeUtc: _location!.timestamp.toIso8601String(),
      verticalAccuracyMeters: _location!.altitudeAccuracy.toString(),
    );

    final payloadData = LocationPayloadData(
      failedAttemptsCount: 0,
      location: locationData,
      locationFrequencyInMilliseconds: 10000,
      rideId: _rideId ?? "IDLE",
      timestamp: DateTime.now().toIso8601String(),
      tripStatus: _tripStatus ?? "IDLE",
      battery: BatteryData(
        level: (_batteryLevel ?? 0).toInt(),
        isCharging: false,
      ),
      internet: InternetData(
        isConnected: _isOnline ?? true,
        connectionType: _connectionType ?? "WIFI",
      ),
    );

    return CaptainLocationData(
      captainId: _captainId ?? "UNKNOWN",
      data: payloadData,
    );
  }
}
