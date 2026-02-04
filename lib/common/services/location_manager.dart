import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:track_me/common/mapper/location_models_mapper.dart';
import 'package:track_me/common/models/location_events.dart';
import 'package:track_me/common/models/location_service_status.dart';
import 'package:track_me/common/models/tracking_events.dart';
import '../models/location_config.dart';

abstract class ILocationPlugin {
  Future<bool> initialize(LocationManagerConfig config);
  Future<void> start();
  Future<void> stop();
  Future<LocationTrackingEvent> getCurrentPosition();
  void onLocation(
    void Function(LocationTrackingEvent) s, [
    void Function(dynamic)? f,
  ]);
  void onGeofence(void Function(String identifier, String action) callback);
  void onEnabledChange(void Function(bool) callback);
  void onMotionChange(void Function(LocationTrackingEvent, bool) callback);
  void onLocationServiceStatusChange(
    void Function(LocationServiceStatus) callback,
  );
  void removeListeners();
  Future<void> setConfig(Map<String, dynamic> extras);
  Future<void> addGeofence(String id, double lat, double lng, double radius);
  Future<void> removeGeofence(String id);
}

class BackgroundGeolocationPlugin implements ILocationPlugin {
  @override
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
      http: bg.HttpConfig(
        url: config.sync.uploadUrl,
        autoSync: config.sync.autoSync,
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

  @override
  Future<void> setConfig(Map<String, dynamic> extras) async {
    await bg.BackgroundGeolocation.setConfig(bg.Config(extras: extras));
  }

  @override
  Future<void> start() => bg.BackgroundGeolocation.start();
  @override
  Future<void> stop() => bg.BackgroundGeolocation.stop();

  @override
  Future<LocationTrackingEvent> getCurrentPosition() async {
    final location = await bg.BackgroundGeolocation.getCurrentPosition(
      persist: false,
      samples: 1,
    );
    return LocationTrackingEvent(
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      speed: location.coords.speed,
      odometer: location.odometer,
      timestamp: DateTime.parse(location.timestamp),
    );
  }

  @override
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

  @override
  void onLocation(
    void Function(LocationTrackingEvent) s, [
    void Function(dynamic)? f,
  ]) => bg.BackgroundGeolocation.onLocation(
    (l) => s(
      LocationTrackingEvent(
        latitude: l.coords.latitude,
        longitude: l.coords.longitude,
        speed: l.coords.speed,
        odometer: l.odometer,
        timestamp: DateTime.parse(l.timestamp),
      ),
    ),
    f,
  );

  @override
  void onGeofence(void Function(String identifier, String action) callback) {
    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) {
      callback(event.identifier, event.action);
    });
  }

  @override
  void onEnabledChange(void Function(bool) c) =>
      bg.BackgroundGeolocation.onEnabledChange(c);
  @override
  void onMotionChange(void Function(LocationTrackingEvent, bool) c) =>
      bg.BackgroundGeolocation.onMotionChange(
        (location) => c(
          LocationTrackingEvent(
            latitude: location.coords.latitude,
            longitude: location.coords.longitude,
            speed: location.coords.speed,
            odometer: location.odometer,
            timestamp: DateTime.parse(location.timestamp),
          ),
          location.isMoving,
        ),
      );

  @override
  void onLocationServiceStatusChange(
    void Function(LocationServiceStatus) callback,
  ) {
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      callback(LocationServiceStatus.map(event));
    });
  }

  @override
  void removeListeners() => bg.BackgroundGeolocation.removeListeners();
}
