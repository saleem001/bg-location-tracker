import 'dart:async';
import 'dart:ffi';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:bg_location_tracker/common/mapper/location_config_mapper.dart';
import 'package:bg_location_tracker/features/tracking/data/datasources/location_plugin_configs.dart';
import 'package:bg_location_tracker/features/tracking/domain/entities/location_service_status.dart';
import 'package:bg_location_tracker/features/tracking/domain/entities/tracking_event.dart';
import 'package:bg_location_tracker/features/tracking/domain/entities/geofence_event.dart';
import '../../domain/entities/location_feature.dart';
import '../../presentation/states/location_state.dart';

/// Manages the background location plugin and exposes mapped domain streams.
/// Uses a fluent API for configuration and an aggregator for stream access.
class BackgroundLocationServiceManager {
  //Controller/Granluar streams
  LocationManagerConfig _config = LocationManagerConfigBuilder().build();
  List<Station> stations = [];

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
  // Public Actions
  // ---------------------------------------------------------------------------

  Future<BackgroundLocationServiceManager> initialize(
    LocationManagerConfig config,
  ) async {
    _config = config;
    final bgConfig = mapToBgConfig(_config);

    await bg.BackgroundGeolocation.ready(bgConfig);
    //shall listen location at least if initialized is called
    addOnLocation();
    //shall start listening immediately once initialized
    await start();
    return this;
  }

  Future<void> start() async {
    await bg.BackgroundGeolocation.start();
    await bg.BackgroundGeolocation.changePace(true);
  }

  Future<void> resume() async {
    final state = await bg.BackgroundGeolocation.state;
    if (state.enabled) return;
    await bg.BackgroundGeolocation.start();
    await bg.BackgroundGeolocation.changePace(true);
  }

  Future<void> pause() async {
    await bg.BackgroundGeolocation.changePace(false);
    await bg.BackgroundGeolocation.stop();
  }

  Future<void> stop() async {
    await bg.BackgroundGeolocation.changePace(false);
    await bg.BackgroundGeolocation.stop();
    await _clearListeners();
  }

  Future<void> _clearListeners() async {
    bg.BackgroundGeolocation.removeListeners();
    await _locationController.close();
    await _motionController.close();
    await _geofenceController.close();
    await _statusController.close();
    await _enabledController.close();
  }

  Future<void> dispose() async {
    await _clearListeners();
    _enabledFeatures.clear();
  }

  // Stream listeners

  BackgroundLocationServiceManager addOnLocation() {
    if (_enabledFeatures.add(LocationFeature.location)) {
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

  BackgroundLocationServiceManager addOnMotionChange() {
    if (_enabledFeatures.add(LocationFeature.motion)) {
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

  BackgroundLocationServiceManager addOnGeofence(List<Station> stations) {
    if (_enabledFeatures.add(LocationFeature.geofence)) {
      setStationGeofences(stations);
      bg.BackgroundGeolocation.onGeofence((event) {
        _geofenceController.add(GeofenceEventMapper().map(event));
      });
    }
    return this;
  }

  Future<void> removeOnGeofence() async {
    _enabledFeatures.remove(LocationFeature.geofence);
    _geofenceController.close();
  }

  BackgroundLocationServiceManager addOnServiceStatusChange() {
    if (_enabledFeatures.add(LocationFeature.status)) {
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

  BackgroundLocationServiceManager addOnEnableChange() {
    if (_enabledFeatures.add(LocationFeature.enable)) {
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

  Future<void> updateConfigs(LocationManagerConfig config) async {
    _config = config;
    final bgConfig = mapToBgConfig(_config);
    await bg.BackgroundGeolocation.setConfig(bgConfig);
  }

  LocationManagerConfig getConfigs() {
    return _config;
  }

  Future<void> setStationGeofences(List<Station> stations) async {
    await bg.BackgroundGeolocation.removeGeofences();
    stations = stations;
    for (var station in stations) {
      await bg.BackgroundGeolocation.addGeofence(
        bg.Geofence(
          identifier: station.id,
          latitude: station.latitude,
          longitude: station.longitude,
          radius: station.radius,
          notifyOnEntry: station.notifyOnEntry,
          notifyOnExit: station.notifyOnExit,
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
}
