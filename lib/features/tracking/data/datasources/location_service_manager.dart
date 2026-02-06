import 'dart:async';
import 'dart:io';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:track_me/common/mapper/location_data_mapper.dart';
import 'package:track_me/features/tracking/data/datasources/location_plugin_configs.dart';
import 'package:track_me/features/tracking/domain/entities/location_service_status.dart';
import 'package:track_me/features/tracking/domain/entities/tracking_event.dart';
import 'package:track_me/features/tracking/domain/entities/geofence_event.dart';
import 'i_tracking_transport.dart';
import 'location_service_config.dart';
import 'location_payload_builder.dart';

class BackgroundLocationServiceManager {
  final ITrackingTransport _transport;

  //streams broadcast to control app's public streams
  late StreamController<GeofenceEvent> _geofenceController =
      StreamController<GeofenceEvent>.broadcast();
  late StreamController<LocationTrackingEvent> _locationController =
      StreamController<LocationTrackingEvent>.broadcast();
  late StreamController<LocationServiceStatus> _serviceStatusController =
      StreamController<LocationServiceStatus>.broadcast();
  late StreamController<MotionChangeEvent> _motionController =
      StreamController<MotionChangeEvent>.broadcast();

  Stream<GeofenceEvent> get geofenceStream => _geofenceController.stream;

  Stream<LocationTrackingEvent> get locationStream =>
      _locationController.stream;

  Stream<LocationServiceStatus> get serviceStatusStream =>
      _serviceStatusController.stream;

  Stream<MotionChangeEvent> get motionStream => _motionController.stream;

  //stream subscriptions for background location plugin
  bool _locationAttached = false;
  bool _geofenceAttached = false;
  bool _serviceStatusAttached = false;
  bool _motionAttached = false;

  // Configuration
  LocationServiceConfig _config;

  BackgroundLocationServiceManager(this._transport)
    : _config = LocationServiceConfig() {
    //these are just stream initializers not listeners
    initLocationStream();
    initGeofenceStream();
    initServiceStatusStream();
    initMotionStream();
  }

  void initLocationStream() {
    _locationController = StreamController<LocationTrackingEvent>.broadcast(
      onListen: _attachLocationListener,
      onCancel: _detachIfUnused,
    );
  }

  void initGeofenceStream() {
    _geofenceController = StreamController<GeofenceEvent>.broadcast(
      onListen: _attachGeofenceListener,
      onCancel: _detachIfUnused,
    );
  }

  void initServiceStatusStream() {
    _serviceStatusController =
        StreamController<LocationServiceStatus>.broadcast(
          onListen: _attachServiceStatusListener,
          onCancel: _detachIfUnused,
        );
  }

  void initMotionStream() {
    _motionController = StreamController<MotionChangeEvent>.broadcast(
      onListen: _attachMotionListener,
      onCancel: _detachIfUnused,
    );
  }

  Future<bool> initialize(LocationManagerConfig config) async {
    final bgConfig = bg.Config(
      reset: config.reset,
      debug: config.logging.debug,
      logLevel: mapLogLevel(config.logging.logLevel),
      geolocation: bg.GeoConfig(
        desiredAccuracy: mapAccuracy(config.tracking.accuracy),
        distanceFilter: config.tracking.distanceFilter,
        stopTimeout: config.tracking.stopTimeout,
        stationaryRadius: config.tracking.movementThreshold.toInt(),
        locationUpdateInterval: config.tracking.locationUpdateInterval,
        fastestLocationUpdateInterval: config.tracking.locationUpdateInterval,
      ),
      persistence: bg.PersistenceConfig(
        maxDaysToPersist: config.persistence.maxDaysToPersist,
        persistMode: mapPersistMode(config.persistence.persistMode),
      ),
      app: bg.AppConfig(
        stopOnTerminate: config.lifecycle.stopOnTerminate,
        startOnBoot: config.lifecycle.startOnBoot,
        enableHeadless: true,
        notification: bg.Notification(
          title: config.notification.title,
          text: config.notification.message,
          priority: mapPriority(config.notification.priority),
        ),
      ),
    );

    final state = await bg.BackgroundGeolocation.ready(bgConfig);
    return state.enabled;
  }

  Future<void> setConfig(Map<String, dynamic> extras) async {
    await bg.BackgroundGeolocation.setConfig(bg.Config(extras: extras));
  }

  void _attachLocationListener() {
    if (_locationAttached) return;
    _locationAttached = true;

    bg.BackgroundGeolocation.onLocation(
      (bg.Location location) {
        if (!_locationController.isClosed) {
          _locationController.add(LocationTrackingEventMapper().map(location));
        }
      },
      (bg.LocationError error) {
        if (!_locationController.isClosed) {
          _locationController.addError(error);
        }
      },
    );
  }

  void _attachGeofenceListener() {
    if (_geofenceAttached) return;
    _geofenceAttached = true;

    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
      if (!_geofenceController.isClosed) {
        final mapped = GeofenceEventMapper().map(event);
        if (mapped.action == GeofenceAction.enter) {
          _geofenceController.add(mapped);
        }
      }
    });
  }

  void _attachServiceStatusListener() {
    if (_serviceStatusAttached) return;
    _serviceStatusAttached = true;

    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      if (!_serviceStatusController.isClosed) {
        _serviceStatusController.add(LocationServiceStatus.map(event));
      }
    });
  }

  void _attachMotionListener() {
    if (_motionAttached) return;
    _motionAttached = true;

    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      if (!_motionController.isClosed) {
        _motionController.add(MotionChangeEventMapper().map(location));
      }
    });
  }

  Future<void> start() => bg.BackgroundGeolocation.start();
  Future<void> stop() => bg.BackgroundGeolocation.stop();

  Future<LocationTrackingEvent> getCurrentPosition() async {
    final location = await bg.BackgroundGeolocation.getCurrentPosition(
      persist: false,
      samples: 1,
    );
    return LocationTrackingEventMapper().map(location);
  }

  Future<void> removeGeofence(String id) {
    return bg.BackgroundGeolocation.removeGeofence(id);
  }

  Future<void> addGeofence(
    String id,
    double lat,
    double lng,
    double radius, [
    bool notifyOnEntry = true,
    bool notifyOnExit = true,
  ]) {
    return bg.BackgroundGeolocation.addGeofence(
      bg.Geofence(
        identifier: id,
        radius: radius,
        latitude: lat,
        longitude: lng,
        notifyOnEntry: notifyOnEntry,
        notifyOnExit: notifyOnExit,
      ),
    );
  }

  void onEnabledChange(void Function(bool) c) =>
      bg.BackgroundGeolocation.onEnabledChange(c);

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
      await bg.BackgroundGeolocation.addGeofence(
        bg.Geofence(
          identifier: station['id'],
          radius: (station['radius'] ?? 200).toDouble(),
          latitude: station['lat'],
          longitude: station['lng'],
          notifyOnEntry: true,
          notifyOnExit: false,
        ),
      );
    }
  }

  Future<void> _sendLocation(bg.Location location) async {
    final connectivity = await Connectivity().checkConnectivity();
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
          isOnline: connectivity != ConnectivityResult.none,
          connectionType: connectivity.toString(),
        )
        .build();

    await _transport.sendLocation(payload);
  }

  void _detachIfUnused() {
    if (_locationController.hasListener ||
        _geofenceController.hasListener ||
        _serviceStatusController.hasListener) {
      return;
    }

    // Plugin only supports global removal
    bg.BackgroundGeolocation.removeListeners();

    _locationAttached = false;
    _geofenceAttached = false;
    _serviceStatusAttached = false;
  }

  //Cleanup
  @override
  void dispose() {
    bg.BackgroundGeolocation.removeListeners();
    _locationController.close();
    _geofenceController.close();
    _serviceStatusController.close();
  }
}
