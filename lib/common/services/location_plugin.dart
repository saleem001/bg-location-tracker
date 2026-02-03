import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import '../models/location_events.dart';
import '../models/location_config.dart';
import '../mapper/location_models_mapper.dart';

abstract class ILocationPlugin {
  Future<bool> initialize(LocationManagerConfig config);
  Future<void> start();
  Future<void> stop();
  Future<LocationEntity> getCurrentPosition();
  Future<void> removeGeofences();
  void onLocation(void Function(LocationEntity) s, [void Function(dynamic)? f]);
  void onMotionChange(void Function(LocationEntity, bool) c);
  void removeListeners();
  Future<bool> restoreState();
  Future<void> setConfig(Map<String, dynamic> extras);
  Future<double> setOdometer(double value);
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
  Future<bool> restoreState() async {
    final state = await bg.BackgroundGeolocation.state;
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
  Future<LocationEntity> getCurrentPosition() async {
    final location = await bg.BackgroundGeolocation.getCurrentPosition(
      persist: false,
      samples: 1,
    );
    return LocationMapper().map(location);
  }

  @override
  Future<void> removeGeofences() => bg.BackgroundGeolocation.removeGeofences();

  @override
  void onLocation(
    void Function(LocationEntity) s, [
    void Function(dynamic)? f,
  ]) =>
      bg.BackgroundGeolocation.onLocation((l) => s(LocationMapper().map(l)), f);

  @override
  void onGeofence(void Function(GeofenceEvent) c) =>
      bg.BackgroundGeolocation.onGeofence(
        (e) => c(GeofenceEventMapper().map(e)),
      );

  @override
  void onActivityChange(void Function(ActivityChangeEvent) c) =>
      bg.BackgroundGeolocation.onActivityChange(
        (e) => c(ActivityChangeEventMapper().map(e)),
      );

  @override
  void onEnabledChange(void Function(bool) c) =>
      bg.BackgroundGeolocation.onEnabledChange(c);

  @override
  void onMotionChange(void Function(LocationEntity, bool) c) =>
      bg.BackgroundGeolocation.onMotionChange(
        (location) => c(LocationMapper().map(location), location.isMoving),
      );

  @override
  void removeListeners() => bg.BackgroundGeolocation.removeListeners();

  @override
  Future<void> changePace(bool isMoving) =>
      bg.BackgroundGeolocation.changePace(isMoving);

  @override
  Future<int> getAuthorizationStatus() async {
    final state = await bg.BackgroundGeolocation.state;
    return state.map['authorizationStatus'] ?? 0;
  }

  @override
  Future<String> getLog() => bg.Logger.getLog();

  @override
  Future<bool> destroyLog() => bg.Logger.destroyLog();

  @override
  Future<double> setOdometer(double value) async {
    final location = await bg.BackgroundGeolocation.setOdometer(value);
    return location.odometer;
  }
}
