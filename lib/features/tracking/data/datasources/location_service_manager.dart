import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:toast/toast.dart';
import 'i_tracking_transport.dart';
import 'location_service_config.dart';
import 'location_payload_builder.dart';
import '../../../../common/utils/notification_service.dart';

class BackgroundLocationServiceManager {
  final ITrackingTransport _transport;
  final StreamController<String> _stationAlertController = StreamController<String>.broadcast();
  final StreamController<bg.Location> _locationController = StreamController<bg.Location>.broadcast();
  
  // Configuration
  LocationServiceConfig _config;

  BackgroundLocationServiceManager(this._transport) : _config = LocationServiceConfig();

  Stream<String> get stationAlertStream => _stationAlertController.stream;
  Stream<bg.Location> get locationStream => _locationController.stream;

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

    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      _locationController.add(location);
      _sendLocation(location);
    }, (bg.LocationError error) {
      print('[onLocation] ERROR: ${error} - ${error.toString()}');
      Toast.show(
        '[onLocation] ERROR: ${error} - ${error.toString()}',
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );
    });

    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      _locationController.add(location);
      print('[onMotionChange] isMoving: ${location.isMoving}');
    });

    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) async {
      if (event.action == "ENTER") {
        _stationAlertController.add(event.identifier);
        
        // Extract name from identifier (tripId:::StationName)
        String displayName = event.identifier;
        if (displayName.contains(":::")) {
          displayName = displayName.split(":::").last;
        }
        
        // Vibrate and Show Local Notification
        await NotificationService().showGeofenceAlert(displayName);
      }
    });
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

  Future<void> _sendLocation(bg.Location location) async {
    final List<ConnectivityResult> connectivity = await Connectivity().checkConnectivity();
    final deviceName = Platform.isAndroid ? "Android" : "iOS";
    
    final payload = LocationPayloadBuilder()
        .setLocation(location)
        .setCaptainInfo(
          captainId: _config.captainId ?? "UNKNOWN",
          rideId: _config.rideId ?? "IDLE",
          tripStatus: _config.tripStatus ?? "IDLE",
        )
        .setDeviceInfo(
          deviceName: deviceName,
          batteryLevel: 100.0, // Should get real battery level
        )
        .setNetworkInfo(
          isOnline: !connectivity.contains(ConnectivityResult.none),
          connectionType: connectivity.isNotEmpty ? connectivity.first.toString().split('.').last : "none",
        )
        .build();

    await _transport.sendLocation(payload);
  }
}
