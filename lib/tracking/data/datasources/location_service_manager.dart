import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:bg_location_tracker/common/mapper/location_config_mapper.dart';
import '../../domain/entities/location_feature.dart';
import '../../domain/entities/location_state.dart';
import '../location_service_manager_config.dart';
import '../location_service_manager_config_types.dart';

/// Manages the background location plugin and exposes raw plugin event streams.
/// Controllers are initialized at class level and remain stable throughout the lifecycle.
class BackgroundLocationServiceManager {
  LocationManagerConfig _config = LocationManagerConfigBuilder().build();
  List<Station> _stations = [];

  // Stable controllers - initialized once, live until dispose()
  final StreamController<bg.Location> _locationController =
      StreamController<bg.Location>.broadcast();
  final StreamController<bg.Location> _motionController =
      StreamController<bg.Location>.broadcast();
  final StreamController<bg.GeofenceEvent> _geofenceController =
      StreamController<bg.GeofenceEvent>.broadcast();
  final StreamController<bg.ProviderChangeEvent> _statusController =
      StreamController<bg.ProviderChangeEvent>.broadcast();
  final StreamController<bool> _enabledController =
      StreamController<bool>.broadcast();

  // Public streams - always available
  Stream<bg.Location> get locationStream => _locationController.stream;

  Stream<bg.Location> get motionStream => _motionController.stream;

  Stream<bg.GeofenceEvent> get geofenceStream => _geofenceController.stream;

  Stream<bg.ProviderChangeEvent> get statusStream => _statusController.stream;

  Stream<bool> get enabledStream => _enabledController.stream;

  // Track enabled features
  final Set<LocationFeature> _enabledFeatures = {};

  // Callback references for proper removal
  void Function(bg.Location)? _onLocationCallback;
  void Function(bg.Location)? _onMotionCallback;
  void Function(bg.GeofenceEvent)? _onGeofenceCallback;
  void Function(bg.ProviderChangeEvent)? _onStatusCallback;
  void Function(bool)? _onEnabledCallback;

  BackgroundLocationServiceManager();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  Future<BackgroundLocationServiceManager> initialize(
      LocationServiceManagerConfigType configType,
  ) async {
    print('[BackgroundLocationServiceManager] Initializing with config: $configType');
    _config = configType.toLocationManagerConfig();
    final bgConfig = mapToBgConfig(_config);
    await bg.BackgroundGeolocation.ready(bgConfig);
    print('[BackgroundLocationServiceManager] Ready');
    return this;
  }

  Future<void> start() async {
    // final state = await bg.BackgroundGeolocation.state;
    // if (state.enabled) return;
    print('[BackgroundLocationServiceManager] Starting service');
    try {
      await bg.BackgroundGeolocation.start();
      await bg.BackgroundGeolocation.changePace(true);
      print('[BackgroundLocationServiceManager] Service started successfully');
    } catch (e) {
      print("[BackgroundLocationServiceManager] BACKGROUND_EXP:::::11111:START::$e");
    }
  }

  Future<void> resume() async {
    print('[BackgroundLocationServiceManager] Resuming service');
    final state = await bg.BackgroundGeolocation.state;
    if (state.enabled) return;
    _reattachAllListeners();
    await bg.BackgroundGeolocation.start();
    await bg.BackgroundGeolocation.changePace(true);
    print('[BackgroundLocationServiceManager] Service resumed successfully');
  }

  Future<void> pause() async {
    print('[BackgroundLocationServiceManager] Pausing service');
    try {
      if (_enabledFeatures.contains(LocationFeature.location)) {
        await bg.BackgroundGeolocation.stop();
        print('[BackgroundLocationServiceManager] Service paused successfully');
      }
    } catch (e) {
      print("[BackgroundLocationServiceManager] BACKGROUND_EXP::::PAUSE:::11111$e");
    }
  }

  // DON'T clear features - keep them for restart
  Future<void> stop() async {
    print('[BackgroundLocationServiceManager] Stopping service');
    final state = await bg.BackgroundGeolocation.state;
    if (!state.enabled) {
      print('[BackgroundLocationServiceManager] Service already stopped');
      return;
    }
    await bg.BackgroundGeolocation.changePace(false);
    await bg.BackgroundGeolocation.stop();
    bg.BackgroundGeolocation.removeListeners();
    _onLocationCallback = null;
    _onMotionCallback = null;
    _onGeofenceCallback = null;
    _onStatusCallback = null;
    _onEnabledCallback = null;
    print('[BackgroundLocationServiceManager] Service stopped successfully');
  }

  Future<void> dispose() async {
    print('[BackgroundLocationServiceManager] Disposing manager');
    final state = await bg.BackgroundGeolocation.state;
    if (state.enabled) {
      await bg.BackgroundGeolocation.changePace(false);
      await bg.BackgroundGeolocation.stop();
    }
    bg.BackgroundGeolocation.removeListeners();
    _enabledFeatures.clear();
    await _locationController.close();
    await _motionController.close();
    await _geofenceController.close();
    await _statusController.close();
    await _enabledController.close();
    print('[BackgroundLocationServiceManager] Manager disposed');
  }

  void _reattachAllListeners() {
    if (_enabledFeatures.contains(LocationFeature.location)) {
      _listenLocation();
    }
    if (_enabledFeatures.contains(LocationFeature.motion)) {
      _listenMotion();
    }
    if (_enabledFeatures.contains(LocationFeature.geofence)) {
      _listenGeofence();
    }
    if (_enabledFeatures.contains(LocationFeature.status)) {
      _listenStatus();
    }
    if (_enabledFeatures.contains(LocationFeature.enable)) {
      _listenEnabled();
    }
  }

  // ---------------------------------------------------------------------------
  // Location Feature
  // ---------------------------------------------------------------------------

  BackgroundLocationServiceManager addOnLocation() {
    if (_enabledFeatures.add(LocationFeature.location)) {
      _listenLocation();
    }
    return this;
  }

  void _listenLocation() {
    _onLocationCallback = (loc) {
      if (!_locationController.isClosed) {
        _locationController.add(loc);
      }
    };
    bg.BackgroundGeolocation.onLocation(_onLocationCallback!);
  }

  void removeOnLocation() {
    if (_enabledFeatures.remove(LocationFeature.location)) {
      if (_onLocationCallback != null) {
        bg.BackgroundGeolocation.removeListener(_onLocationCallback!);
        _onLocationCallback = null;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Motion Feature
  // ---------------------------------------------------------------------------

  BackgroundLocationServiceManager addOnMotionChange() {
    if (_enabledFeatures.add(LocationFeature.motion)) {
      _listenMotion();
    }
    return this;
  }

  void _listenMotion() {
    _onMotionCallback = (loc) {
      if (!_motionController.isClosed) {
        print('[BackgroundLocationServiceManager] lcoation added:$loc');
        _motionController.add(loc);
      }
    };
    bg.BackgroundGeolocation.onMotionChange(_onMotionCallback!);
  }

  void removeOnMotionChange() {
    if (_enabledFeatures.remove(LocationFeature.motion)) {
      if (_onMotionCallback != null) {
        bg.BackgroundGeolocation.removeListener(_onMotionCallback!);
        _onMotionCallback = null;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Geofence Feature
  // ---------------------------------------------------------------------------

  BackgroundLocationServiceManager addOnGeofence(List<Station> stations) {
    if (_enabledFeatures.add(LocationFeature.geofence)) {
      _stations = stations;
      _setStationGeofences(_stations);
      _listenGeofence();
    }
    return this;
  }

  void _listenGeofence() {
    _onGeofenceCallback = (geofence) {
      if (!_geofenceController.isClosed) {
        _geofenceController.add(geofence);
      }
    };
    bg.BackgroundGeolocation.onGeofence(_onGeofenceCallback!);
  }

  void removeOnGeofence() {
    if (_enabledFeatures.remove(LocationFeature.geofence)) {
      if (_onGeofenceCallback != null) {
        bg.BackgroundGeolocation.removeListener(_onGeofenceCallback!);
        _onGeofenceCallback = null;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Service Status Feature
  // ---------------------------------------------------------------------------

  BackgroundLocationServiceManager addOnServiceStatusChange() {
    if (_enabledFeatures.add(LocationFeature.status)) {
      _listenStatus();
    }
    return this;
  }

  void _listenStatus() {
    _onStatusCallback = (status) {
      if (!_statusController.isClosed) {
        _statusController.add(status);
      }
    };
    bg.BackgroundGeolocation.onProviderChange(_onStatusCallback!);
  }

  void removeOnServiceStatusChange() {
    if (_enabledFeatures.remove(LocationFeature.status)) {
      if (_onStatusCallback != null) {
        bg.BackgroundGeolocation.removeListener(_onStatusCallback!);
        _onStatusCallback = null;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Enabled Change Feature
  // ---------------------------------------------------------------------------

  BackgroundLocationServiceManager addOnEnableChange() {
    if (_enabledFeatures.add(LocationFeature.enable)) {
      _listenEnabled();
    }
    return this;
  }

  void _listenEnabled() {
    _onEnabledCallback = (enabled) {
      if (!_enabledController.isClosed) {
        _enabledController.add(enabled);
      }
    };
    bg.BackgroundGeolocation.onEnabledChange(_onEnabledCallback!);
  }

  void removeOnEnableChange() {
    if (_enabledFeatures.remove(LocationFeature.enable)) {
      if (_onEnabledCallback != null) {
        bg.BackgroundGeolocation.removeListener(_onEnabledCallback!);
        _onEnabledCallback = null;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Configuration & Geofence Management
  // ---------------------------------------------------------------------------

  Future<void> updateConfigs(LocationServiceManagerConfigType configType) async {
    _config = configType.toLocationManagerConfig();
    final bgConfig = mapToBgConfig(_config);
    await bg.BackgroundGeolocation.setConfig(bgConfig);
  }

  LocationManagerConfig getConfigs() => _config;

  Future<bg.Location> getCurrentPosition() async {
    return await bg.BackgroundGeolocation.getCurrentPosition(
      persist: false,
      samples: 1,
    );
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

  Future<bool> isServiceEnabled() =>
      bg.BackgroundGeolocation.state.then((state) => state.enabled);

  bool isFeatureEnabled(LocationFeature feature) =>
      _enabledFeatures.contains(feature);

  Future<void> _setStationGeofences(List<Station> stations) async {
    await bg.BackgroundGeolocation.removeGeofences();
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
}
