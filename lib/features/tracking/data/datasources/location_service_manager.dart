import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'i_tracking_transport.dart';
import 'location_service_config.dart';

class BackgroundLocationServiceManager {
  // Configuration
  LocationServiceConfig _config;

  BackgroundLocationServiceManager(ITrackingTransport transport) : _config = LocationServiceConfig();

  Future<void> initialize() async {
    await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 1,
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
      debug: false,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      locationAuthorizationRequest: 'Always',
      backgroundPermissionRationale: bg.PermissionRationale(
        title: "Allow access to this device's location in the background?",
        message: "Your location is used to track your trips and ensure safety.",
        positiveAction: "Allow",
        negativeAction: "Cancel"
      ),
      // Fast transition settings
      stationaryRadius: 25,
      activityRecognitionInterval: 1000,
      stopTimeout: 1,
      heartbeatInterval: 60,
      
      // High frequency updates
      locationUpdateInterval: 1000,
      fastestLocationUpdateInterval: 1000,
      
      // Optimization and reliability
      elasticityMultiplier: 1.0,
      pausesLocationUpdatesAutomatically: false,
      preventSuspend: true,
      
      notification: bg.Notification(
        title: "Tracking Active",
        text: "Ensuring accurate trip monitoring",
        color: "#2196F3",
      )
    ));
  }

  void updateCaptainInfo({
    String? captainId,
    String? rideId,
    String? tripStatus,
  }) {
    _config = _config.copyWith(
      captainId: captainId,
      rideId: rideId,
      tripStatus: tripStatus,
    );
  }

  Future<void> setStationGeofences(List<Map<String, dynamic>> stations) async {
    await bg.BackgroundGeolocation.removeGeofences();
    
    for (var station in stations) {
      await bg.BackgroundGeolocation.addGeofence(bg.Geofence(
        identifier: station['id'],
        radius: (station['radius'] ?? 200).toDouble(),
        latitude: station['lat'],
        longitude: station['lng'],
        notifyOnEntry: true,
        notifyOnExit: false,
      ));
    }
  }

  Future<void> start() async {
    await bg.BackgroundGeolocation.start();
    // Force the plugin into the 'moving' state to ensure immediate location updates
    await bg.BackgroundGeolocation.changePace(true);
  }

  Future<void> stop() async {
    await bg.BackgroundGeolocation.changePace(false);
    await bg.BackgroundGeolocation.stop();
  }
}
