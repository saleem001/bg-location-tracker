
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import '../../domain/entities/captain_location_data.dart';
import 'package:uuid/uuid.dart';

class LocationPayloadBuilder {
  bg.Location? _location;
  double? _lat;
  double? _lng;
  double? _speed;
  double? _odometer;
  DateTime? _timestamp;
  String? _captainId;
  String? _rideId;
  String? _tripStatus;
  String? _deviceName;
  double? _batteryLevel;
  bool? _isOnline;
  String? _connectionType;

  LocationPayloadBuilder setLocation(bg.Location location) {
    _location = location;
    return this;
  }

  LocationPayloadBuilder setLocationRaw({
    required double lat,
    required double lng,
    required double speed,
    required double odometer,
    required DateTime timestamp,
  }) {
    _lat = lat;
    _lng = lng;
    _speed = speed;
    _odometer = odometer;
    _timestamp = timestamp;
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

  LocationPayloadBuilder setDeviceInfo({
    required String deviceName,
    required double batteryLevel,
  }) {
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
    if (_location == null && _lat == null) throw Exception("Location is required");

    final locationData = LocationData(
      accuracy: (_location?.coords.accuracy ?? 0.0).toString(),
      altitude: (_location?.coords.altitude ?? 0.0).toString(),
      androidId: "UNKNOWN",
      bearing: (_location?.coords.heading ?? 0.0).toString(),
      bearingAccuracyDegrees: "0.0",
      elapsedRealtimeNanos: "0",
      lat: (_location?.coords.latitude ?? _lat!).toString(),
      lng: (_location?.coords.longitude ?? _lng!).toString(),
      runCounter: "1",
      sequence: "1",
      speed: (_location?.coords.speed ?? _speed!).toString(),
      speedAccuracyMetersPerSecond: (_location?.coords.speedAccuracy ?? 0.0).toString(),
      timeUtc: _location?.timestamp ?? _timestamp!.toIso8601String(),
      verticalAccuracyMeters: (_location?.coords.altitudeAccuracy ?? 0.0).toString(),
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
      batchNumber: const Uuid().v4(),
      captainId: _captainId ?? "UNKNOWN",
      data: payloadData,
    );
  }
}
