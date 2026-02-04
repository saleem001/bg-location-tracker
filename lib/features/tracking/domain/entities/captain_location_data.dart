class CaptainLocationData {
  final String batchNumber;
  final String captainId;
  final LocationPayloadData data;

  CaptainLocationData({
    required this.batchNumber,
    required this.captainId,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
    "batch_number": batchNumber,
    "captain": captainId,
    "data": data.toJson(),
  };
}

class LocationPayloadData {
  final BatteryData? battery;
  final DeviceData? device;
  final int failedAttemptsCount;
  final GpsData? gps;
  final InternetData? internet;
  final LocationData location;
  final int locationFrequencyInMilliseconds;
  final String rideId;
  final String timestamp;
  final String tripStatus;

  LocationPayloadData({
    this.battery,
    this.device,
    required this.failedAttemptsCount,
    this.gps,
    this.internet,
    required this.location,
    required this.locationFrequencyInMilliseconds,
    required this.rideId,
    required this.timestamp,
    required this.tripStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      if (battery != null) "battery": battery!.toJson(),
      if (device != null) "device": device!.toJson(),
      "failed_attempts_count": failedAttemptsCount,
      if (gps != null) "gps": gps!.toJson(),
      if (internet != null) "internet": internet!.toJson(),
      "location": location.toJson(),
      "location_frequency_in_milliseconds": locationFrequencyInMilliseconds,
      "ride_id": rideId,
      "timestamp": timestamp,
      "trip_status": tripStatus,
    };
  }
}

class BatteryData {
  final bool isCharging;
  final int level;

  BatteryData({required this.isCharging, required this.level});

  Map<String, dynamic> toJson() => {"is_charging": isCharging, "level": level};
}

class DeviceData {
  final int androidVersion;

  DeviceData({required this.androidVersion});

  Map<String, dynamic> toJson() => {"android_version": androidVersion};
}

class GpsData {
  final int confirmedRealLocationCount;
  final bool isEnabled;
  final int locationCallbackFiredCount;
  final int mockLocationCount;
  final String permission;
  final String realLocationSentCount;

  GpsData({
    required this.confirmedRealLocationCount,
    required this.isEnabled,
    required this.locationCallbackFiredCount,
    required this.mockLocationCount,
    required this.permission,
    required this.realLocationSentCount,
  });

  Map<String, dynamic> toJson() => {
    "confirmed_real_location_count": confirmedRealLocationCount,
    "is_enabled": isEnabled,
    "location_callback_fired_count": locationCallbackFiredCount,
    "mock_location_count": mockLocationCount,
    "permission": permission,
    "real_location_sent_count": realLocationSentCount,
  };
}

class InternetData {
  final String connectionType;
  final bool isConnected;

  InternetData({required this.connectionType, required this.isConnected});

  Map<String, dynamic> toJson() => {
    "connection_type": connectionType,
    "is_connected": isConnected,
  };
}

class LocationData {
  final String accuracy;
  final String altitude;
  final String androidId;
  final String bearing;
  // Make bearing accuracy optional just in case
  final String bearingAccuracyDegrees;
  final String elapsedRealtimeNanos;
  final String lat;
  final String lng;
  final String runCounter;
  final String sequence;
  final String speed;
  final String speedAccuracyMetersPerSecond;
  final String timeUtc;
  final String verticalAccuracyMeters;

  LocationData({
    required this.accuracy,
    required this.altitude,
    required this.androidId,
    required this.bearing,
    required this.bearingAccuracyDegrees,
    required this.elapsedRealtimeNanos,
    required this.lat,
    required this.lng,
    required this.runCounter,
    required this.sequence,
    required this.speed,
    required this.speedAccuracyMetersPerSecond,
    required this.timeUtc,
    required this.verticalAccuracyMeters,
  });

  Map<String, dynamic> toJson() => {
    "accuracy": accuracy,
    "altitude": altitude,
    "android_id": androidId,
    "bearing": bearing,
    "bearing_accuracy_degrees": bearingAccuracyDegrees,
    "elapsed_realtime_nanos": elapsedRealtimeNanos,
    "lat": lat,
    "lng": lng,
    "run_counter": runCounter,
    "sequence": sequence,
    "speed": speed,
    "speed_accuracy_meters_per_second": speedAccuracyMetersPerSecond,
    "time_utc": timeUtc,
    "vertical_accuracy_meters": verticalAccuracyMeters,
  };
}
