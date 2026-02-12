import 'dart:async';
import 'dart:ffi';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:track_me/common/mapper/location_data_mapper.dart';
import 'package:track_me/features/tracking/data/datasources/location_plugin_configs.dart';
import 'package:track_me/features/tracking/domain/entities/location_service_status.dart';
import 'package:track_me/features/tracking/domain/entities/tracking_event.dart';
import 'package:track_me/features/tracking/domain/entities/geofence_event.dart';
import '../../domain/entities/location_feature.dart';

/// Manages the background location plugin and exposes mapped domain streams.
/// Uses a fluent API for configuration and an aggregator for stream access.
class BackgroundLocationServiceManager {
  //Controller/Granluar streams
  final StreamController<LocationTrackingEvent> _locationController =
      StreamController<LocationTrackingEvent>.broadcast();

  final StreamController<MotionChangeEvent> _motionController =
      StreamController<MotionChangeEvent>.broadcast();

  final StreamController<GeofenceEvent> _geofenceController =
      StreamController<GeofenceEvent>.broadcast();

  final StreamController<LocationServiceStatus> _statusController =
      StreamController<LocationServiceStatus>.broadcast();

  final StreamController<bool> _enabledController =
      StreamController<bool>.broadcast();

  //public streams for access
  Stream<LocationTrackingEvent> get locationStream =>
      _locationController.stream;

  Stream<MotionChangeEvent> get motionStream => _motionController.stream;

  Stream<GeofenceEvent> get geofenceStream => _geofenceController.stream;

  Stream<LocationServiceStatus> get statusStream => _statusController.stream;

  Stream<bool> get enabledStream => _enabledController.stream;

  // Registry to track which plugin listeners are currently native-attached.
  final Set<LocationFeature> _enabledFeatures = {};

  BackgroundLocationServiceManager();

  // ---------------------------------------------------------------------------
  // Fluent Initialization & Configuration (Chaining)
  // ---------------------------------------------------------------------------

  BackgroundLocationServiceManager onLocation() {
    if (_enabledFeatures.add(LocationFeature.location) &&
        !_locationController.isClosed) {
      bg.BackgroundGeolocation.onLocation((loc) {
        _locationController.add(LocationTrackingEventMapper().map(loc));
      });
    }
    return this;
  }

  Future<void> removeOnLocation() async {
    _enabledFeatures.remove(LocationFeature.location);
    await _locationController.close();
  }

  BackgroundLocationServiceManager onMotionChange() {
    if (_enabledFeatures.add(LocationFeature.motion) &&
        !_motionController.isClosed) {
      bg.BackgroundGeolocation.onMotionChange((event) {
        _motionController.add(MotionChangeEventMapper().map(event));
      });
    }
    return this;
  }

  Future<void> removeOnMotionChange() async {
    _enabledFeatures.remove(LocationFeature.motion);
    _motionController.close();
  }

  BackgroundLocationServiceManager onAutoArrival() {
    if (_enabledFeatures.add(LocationFeature.geofence) &&
        !_geofenceController.isClosed) {
      bg.BackgroundGeolocation.onGeofence((event) {
        _geofenceController.add(GeofenceEventMapper().map(event));
      });
    }
    return this;
  }

  Future<void> removeOnAutoArrival() async {
    _enabledFeatures.remove(LocationFeature.geofence);
    _geofenceController.close();
  }

  BackgroundLocationServiceManager onServiceStatusChange() {
    if (_enabledFeatures.add(LocationFeature.status) &&
        !_statusController.isClosed) {
      bg.BackgroundGeolocation.onProviderChange((event) {
        _statusController.add(LocationServiceStatus.map(event));
      });
    }
    return this;
  }

  Future<void> removeOnServiceStatusChange() async {
    _enabledFeatures.remove(LocationFeature.status);
    _statusController.close();
  }

  BackgroundLocationServiceManager onEnableChange() {
    if (_enabledFeatures.add(LocationFeature.enable) &&
        !_enabledController.isClosed) {
      bg.BackgroundGeolocation.onEnabledChange((enabled) {
        _enabledController.add(enabled);
      });
    }
    return this;
  }

  Future<void> removeOnEnableChange() async {
    _enabledFeatures.remove(LocationFeature.enable);
    _enabledController.close();
  }

  Future<BackgroundLocationServiceManager> initialize(
    LocationManagerConfig config,
  ) async {
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

    await bg.BackgroundGeolocation.ready(bgConfig);
    return this;
  }

  // ---------------------------------------------------------------------------
  // Public Actions
  // ---------------------------------------------------------------------------

  Future<void> start() async {
    final state = await bg.BackgroundGeolocation.state;
    if (state.enabled) {
      print('[LocationServiceManager] Plugin already enabled, skipping start()');
      return;
    }
    await bg.BackgroundGeolocation.start();
    await bg.BackgroundGeolocation.changePace(true);
  }

  Future<void> stop() async{
    await bg.BackgroundGeolocation.changePace(false);
    await bg.BackgroundGeolocation.stop();
  }

  Future<void> updateConfigs(Map<String, dynamic> extras) async {
    await bg.BackgroundGeolocation.setConfig(bg.Config(extras: extras));
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
          notifyOnExit: true,
        ),
      );
    }
  }

  Future<LocationTrackingEvent> getCurrentPosition() async {
    final location = await bg.BackgroundGeolocation.getCurrentPosition(
      persist: false,
      samples: 1,
    );
    return LocationTrackingEventMapper().map(location);
  }

  Future<void> addStationGeofence(
    String id,
    double lat,
    double lng,
    double rad, [
    bool onEntry = true,
    bool onExit = true,
  ]) {
    return bg.BackgroundGeolocation.addGeofence(
      bg.Geofence(
        identifier: id,
        radius: rad,
        latitude: lat,
        longitude: lng,
        notifyOnEntry: onEntry,
        notifyOnExit: onExit,
      ),
    );
  }

  Future<void> removeStationGeofence(String id) =>
      bg.BackgroundGeolocation.removeGeofence(id);

  bool isFeatureEnabled(LocationFeature feature) {
    return _enabledFeatures.contains(feature);
  }

  void dispose() {
    bg.BackgroundGeolocation.removeListeners();
    _enabledFeatures.clear();
    _locationController.close();
    _motionController.close();
    _geofenceController.close();
    _statusController.close();
    _enabledController.close();
  }
}
