import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:track_me/common/mapper/location_data_mapper.dart';
import 'package:track_me/features/tracking/data/datasources/location_plugin_configs.dart';
import 'package:track_me/features/tracking/domain/entities/location_service_status.dart';
import 'package:track_me/features/tracking/domain/entities/tracking_event.dart';
import 'package:track_me/features/tracking/domain/entities/geofence_event.dart';
import 'package:track_me/features/tracking/domain/entities/location_service_streams.dart';

/// Manages the background location plugin and exposes mapped domain streams.
/// Uses a fluent API for configuration and an aggregator for stream access.
class BackgroundLocationServiceManager {
  // Private Controllers Container - Handles the "Input" side
  late final _ManagerControllers _internal;

  // Public Stream Aggregator - Handles the "Output" side
  late final LocationServiceStreams streams;

  // Registry to track which plugin listeners are currently native-attached.
  final Set<String> _attached = {};

  // Registry to track which features were explicitly enabled via chaining.
  // This prevents accidental attachments for unwanted features.
  final Set<String> _enabledFeatures = {};

  BackgroundLocationServiceManager() {
    _internal = _ManagerControllers(
      onLocationListen: _onLocationListen,
      onGeofenceListen: _onGeofenceListen,
      onStatusListen: _onStatusListen,
      onMotionListen: _onMotionListen,
      onAnyCancel: _detachIfUnused,
    );

    streams = LocationServiceStreams(
      geofence: _internal.geofence.stream,
      location: _internal.location.stream,
      serviceStatus: _internal.serviceStatus.stream,
      motion: _internal.motion.stream,
    );
  }

  // ---------------------------------------------------------------------------
  // Fluent Initialization & Configuration (Chaining)
  // ---------------------------------------------------------------------------

  /// Enables the Location Stream for this session.
  BackgroundLocationServiceManager initLocationStream() {
    _enabledFeatures.add('location');
    return this;
  }

  /// Enables the Station Geofence Stream for this session.
  BackgroundLocationServiceManager initStationGeofenceStream() {
    _enabledFeatures.add('geofence');
    return this;
  }

  /// Enables the Service Status Stream for this session.
  BackgroundLocationServiceManager initServiceStatusStream() {
    _enabledFeatures.add('status');
    return this;
  }

  /// Enables the Motion Change Stream for this session.
  BackgroundLocationServiceManager initMotionStream() {
    _enabledFeatures.add('motion');
    return this;
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
  // Internal Registry & Listener Logic
  // ---------------------------------------------------------------------------

  /// Ensures a plugin listener is registered exactly once, only if enabled in chain.
  void _ensureAttached(String featureKey, void Function() register) {
    if (!_enabledFeatures.contains(featureKey)) return;
    if (_attached.add(featureKey)) register();
  }

  void _onLocationListen() => _ensureAttached('location', () {
    bg.BackgroundGeolocation.onLocation(
      (loc) => _internal.location.add(LocationTrackingEventMapper().map(loc)),
      (err) => _internal.location.addError(err),
    );
  });

  void _onGeofenceListen() => _ensureAttached('geofence', () {
    bg.BackgroundGeolocation.onGeofence((event) {
      final mapped = GeofenceEventMapper().map(event);
      if (mapped.action == GeofenceAction.enter) _internal.geofence.add(mapped);
    });
  });

  void _onStatusListen() => _ensureAttached('status', () {
    bg.BackgroundGeolocation.onProviderChange(
      (event) => _internal.serviceStatus.add(LocationServiceStatus.map(event)),
    );
  });

  void _onMotionListen() => _ensureAttached('motion', () {
    bg.BackgroundGeolocation.onMotionChange(
      (loc) => _internal.motion.add(MotionChangeEventMapper().map(loc)),
    );
  });

  void _detachIfUnused() {
    if (_internal.hasListeners) return;
    bg.BackgroundGeolocation.removeListeners();
    _attached.clear();
  }

  // ---------------------------------------------------------------------------
  // Public Actions
  // ---------------------------------------------------------------------------

  Future<void> start() => bg.BackgroundGeolocation.start();
  Future<void> stop() => bg.BackgroundGeolocation.stop();

  void onServiceEnabledChange(void Function(bool) callback) =>
      bg.BackgroundGeolocation.onEnabledChange(callback);

  Future<void> setConfig(Map<String, dynamic> extras) async {
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
          notifyOnExit: false,
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

  void dispose() {
    bg.BackgroundGeolocation.removeListeners();
    _internal.dispose();
  }
}

/// Helper container to group private controllers and centralize listener checks.
class _ManagerControllers {
  final StreamController<GeofenceEvent> geofence;
  final StreamController<LocationTrackingEvent> location;
  final StreamController<LocationServiceStatus> serviceStatus;
  final StreamController<MotionChangeEvent> motion;

  _ManagerControllers({
    required void Function() onLocationListen,
    required void Function() onGeofenceListen,
    required void Function() onStatusListen,
    required void Function() onMotionListen,
    required void Function() onAnyCancel,
  }) : geofence = StreamController<GeofenceEvent>.broadcast(
         onListen: onGeofenceListen,
         onCancel: onAnyCancel,
       ),
       location = StreamController<LocationTrackingEvent>.broadcast(
         onListen: onLocationListen,
         onCancel: onAnyCancel,
       ),
       serviceStatus = StreamController<LocationServiceStatus>.broadcast(
         onListen: onStatusListen,
         onCancel: onAnyCancel,
       ),
       motion = StreamController<MotionChangeEvent>.broadcast(
         onListen: onMotionListen,
         onCancel: onAnyCancel,
       );

  bool get hasListeners =>
      location.hasListener ||
      geofence.hasListener ||
      serviceStatus.hasListener ||
      motion.hasListener;

  void dispose() {
    location.close();
    geofence.close();
    serviceStatus.close();
    motion.close();
  }
}
