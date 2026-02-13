import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import '../../features/tracking/data/datasources/location_plugin_configs.dart';
import 'data_mapper.dart';

// Top-level mapping functions for Config policies

bg.Config mapToBgConfig(LocationManagerConfig config){
  return bg.Config(
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
}

bg.DesiredAccuracy mapAccuracy(int l) => l >= 5
    ? bg.DesiredAccuracy.navigation
    : (l >= 4 ? bg.DesiredAccuracy.high : bg.DesiredAccuracy.medium);

bg.PersistMode mapPersistMode(int m) => m == 0
    ? bg.PersistMode.none
    : (m == 1 ? bg.PersistMode.location : bg.PersistMode.all);

int mapLogLevel(int l) => l >= 2
    ? 5 // Verbose
    : (l >= 1 ? 4 : 0); // Debug or Off

bg.NotificationPriority mapPriority(int p) {
  if (p >= 2) return bg.NotificationPriority.max;
  if (p >= 1) return bg.NotificationPriority.high;
  if (p <= -2) return bg.NotificationPriority.min;
  if (p <= -1) return bg.NotificationPriority.low;
  return bg.NotificationPriority.defaultPriority;
}
