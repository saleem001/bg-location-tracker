import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import '../models/location_models.dart';
import '../models/location_config.dart';

abstract class ILocationPlugin {
  Future<bool> initialize(LocationManagerConfig config);
  Future<void> start();
  Future<void> stop();
  Future<LocationEntity> getCurrentPosition();
  Future<int> requestPermission();
  Future<int> getAuthorizationStatus();
  Future<void> addGeofence(
    String id,
    double lat,
    double lng,
    double radius, {
    bool notifyOnEntry = true,
    bool notifyOnExit = false,
  });
  Future<void> removeGeofences();
  void onLocation(void Function(LocationEntity) s, [void Function(dynamic)? f]);
  void onGeofence(void Function(GeofenceEvent) c);
  void onActivityChange(void Function(ActivityChangeEvent) c);
  void onProviderChange(void Function(ProviderChangeEvent) c);
  void onEnabledChange(void Function(bool) c);
  void onMotionChange(void Function(LocationEntity, bool) c);
  void removeListeners();
  Future<void> changePace(bool isMoving);
  Future<bool> restoreState();
  Future<void> setConfig(Map<String, dynamic> extras);
  Future<String> getLogs();
  Future<void> clearLogs();
}

class BackgroundGeolocationPlugin implements ILocationPlugin {
  @override
  Future<bool> initialize(LocationManagerConfig config) async {
    final bgConfig = bg.Config(
      reset: config.reset,
      debug: config.logging.debug,
      logLevel: _mapLogLevel(config.logging.logLevel),
      geolocation: bg.GeoConfig(
        desiredAccuracy: _mapAccuracy(config.tracking.accuracy),
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
        persistMode: _mapPersistMode(config.persistence.persistMode),
      ),
      app: bg.AppConfig(
        stopOnTerminate: config.lifecycle.stopOnTerminate,
        startOnBoot: config.lifecycle.startOnBoot,
        enableHeadless: true,
        notification: bg.Notification(
          title: config.notification.title,
          text: config.notification.message,
          priority: _mapPriority(config.notification.priority),
        ),
        backgroundPermissionRationale:
            config.notification.permissionTitle != null
            ? bg.PermissionRationale(
                title: config.notification.permissionTitle!,
                message: config.notification.permissionMessage ?? "",
                positiveAction: config.notification.positiveAction,
                negativeAction: config.notification.negativeAction,
              )
            : null,
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

  bg.DesiredAccuracy _mapAccuracy(int l) => l >= 5
      ? bg.DesiredAccuracy.navigation
      : (l >= 4 ? bg.DesiredAccuracy.high : bg.DesiredAccuracy.medium);
  bg.PersistMode _mapPersistMode(int m) => m == 0
      ? bg.PersistMode.none
      : (m == 1 ? bg.PersistMode.location : bg.PersistMode.all);
  int _mapLogLevel(int l) => l >= 2
      ? 5 // Verbose
      : (l >= 1 ? 4 : 0); // Debug or Off
  bg.NotificationPriority _mapPriority(int p) {
    if (p >= 2) return bg.NotificationPriority.max;
    if (p >= 1) return bg.NotificationPriority.high;
    if (p <= -2) return bg.NotificationPriority.min;
    if (p <= -1) return bg.NotificationPriority.low;
    return bg.NotificationPriority.defaultPriority;
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
    return LocationEntity(
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      speed: location.coords.speed,
      odometer: location.odometer,
      timestamp: DateTime.parse(location.timestamp),
    );
  }

  @override
  Future<int> requestPermission() =>
      bg.BackgroundGeolocation.requestPermission();

  @override
  Future<int> getAuthorizationStatus() async {
    final state = await bg.BackgroundGeolocation.state;
    return state.map['authorizationStatus'] ?? 0;
  }

  @override
  Future<void> removeGeofences() => bg.BackgroundGeolocation.removeGeofences();
  @override
  Future<void> addGeofence(
    String id,
    double lat,
    double lng,
    double rad, {
    bool notifyOnEntry = true,
    bool notifyOnExit = false,
  }) => bg.BackgroundGeolocation.addGeofence(
    bg.Geofence(
      identifier: id,
      latitude: lat,
      longitude: lng,
      radius: rad,
      notifyOnEntry: notifyOnEntry,
      notifyOnExit: notifyOnExit,
    ),
  );

  @override
  void onLocation(
    void Function(LocationEntity) s, [
    void Function(dynamic)? f,
  ]) => bg.BackgroundGeolocation.onLocation(
    (l) => s(
      LocationEntity(
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
  void onGeofence(void Function(GeofenceEvent) c) =>
      bg.BackgroundGeolocation.onGeofence(
        (e) => c(GeofenceEvent(identifier: e.identifier, action: e.action)),
      );
  @override
  void onActivityChange(void Function(ActivityChangeEvent) c) =>
      bg.BackgroundGeolocation.onActivityChange(
        (e) => c(
          ActivityChangeEvent(activity: e.activity, confidence: e.confidence),
        ),
      );
  @override
  void onProviderChange(void Function(ProviderChangeEvent) c) =>
      bg.BackgroundGeolocation.onProviderChange(
        (e) => c(
          ProviderChangeEvent(
            enabled: e.enabled,
            status: e.status,
            network: e.network,
            gps: e.gps,
          ),
        ),
      );
  @override
  void onEnabledChange(void Function(bool) c) =>
      bg.BackgroundGeolocation.onEnabledChange(c);
  @override
  void onMotionChange(void Function(LocationEntity, bool) c) =>
      bg.BackgroundGeolocation.onMotionChange(
        (location) => c(
          LocationEntity(
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
  void removeListeners() => bg.BackgroundGeolocation.removeListeners();

  @override
  Future<void> changePace(bool isMoving) =>
      bg.BackgroundGeolocation.changePace(isMoving);

  @override
  Future<String> getLogs() => bg.Logger.getLog();

  @override
  Future<void> clearLogs() => bg.Logger.destroyLog();
}
