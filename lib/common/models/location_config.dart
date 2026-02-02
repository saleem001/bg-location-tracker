import 'location_models.dart';

class TrackingPolicy {
  final int accuracy;
  final double distanceFilter;
  final int stopTimeout;
  final double movementThreshold;
  final int locationUpdateInterval;
  const TrackingPolicy({
    this.accuracy = 4,
    this.distanceFilter = 10.0,
    this.stopTimeout = 5,
    this.movementThreshold = 25.0,
    this.locationUpdateInterval = 1000,
  });
}

class TrackingPolicyBuilder {
  int _a = 4;
  double _df = 10.0;
  int _st = 5;
  double _mt = 25.0;
  int _lui = 1000;

  TrackingPolicyBuilder setAccuracy(int v) {
    _a = v;
    return this;
  }

  TrackingPolicyBuilder setDistanceFilter(double v) {
    _df = v;
    return this;
  }

  TrackingPolicyBuilder setStopTimeout(int v) {
    _st = v;
    return this;
  }

  TrackingPolicyBuilder setMovementThreshold(double v) {
    _mt = v;
    return this;
  }

  TrackingPolicyBuilder setLocationUpdateInterval(int v) {
    _lui = v;
    return this;
  }

  TrackingPolicy build() => TrackingPolicy(
    accuracy: _a,
    distanceFilter: _df,
    stopTimeout: _st,
    movementThreshold: _mt,
    locationUpdateInterval: _lui,
  );
}

class DataSyncPolicy {
  final String? uploadUrl;
  final DomainTransistorToken? transistorToken;
  final bool autoSync;
  const DataSyncPolicy({
    this.uploadUrl,
    this.transistorToken,
    this.autoSync = true,
  });
}

class DataSyncPolicyBuilder {
  String? _u;
  DomainTransistorToken? _t;
  bool _as = true;

  DataSyncPolicyBuilder setUploadUrl(String? v) {
    _u = v;
    return this;
  }

  DataSyncPolicyBuilder setTransistorToken(DomainTransistorToken? v) {
    _t = v;
    return this;
  }

  DataSyncPolicyBuilder setAutoSync(bool v) {
    _as = v;
    return this;
  }

  DataSyncPolicy build() =>
      DataSyncPolicy(uploadUrl: _u, transistorToken: _t, autoSync: _as);
}

class PersistencePolicy {
  final int maxDaysToPersist;
  final int persistMode;
  const PersistencePolicy({this.maxDaysToPersist = -1, this.persistMode = 2});
}

class PersistencePolicyBuilder {
  int _d = -1;
  int _m = 2; // 2 = PersistMode.all

  PersistencePolicyBuilder setMaxDaysToPersist(int v) {
    _d = v;
    return this;
  }

  PersistencePolicyBuilder setPersistMode(int v) {
    _m = v;
    return this;
  }

  PersistencePolicy build() =>
      PersistencePolicy(maxDaysToPersist: _d, persistMode: _m);
}

class LifecyclePolicy {
  final bool stopOnTerminate;
  final bool startOnBoot;
  const LifecyclePolicy({
    this.stopOnTerminate = false,
    this.startOnBoot = true,
  });
}

class LifecyclePolicyBuilder {
  bool _sot = false;
  bool _sob = true;

  LifecyclePolicyBuilder setStopOnTerminate(bool v) {
    _sot = v;
    return this;
  }

  LifecyclePolicyBuilder setStartOnBoot(bool v) {
    _sob = v;
    return this;
  }

  LifecyclePolicy build() =>
      LifecyclePolicy(stopOnTerminate: _sot, startOnBoot: _sob);
}

class NotificationPolicy {
  final String title;
  final String message;
  final int priority;
  final String? permissionTitle;
  final String? permissionMessage;
  final String? positiveAction;
  final String? negativeAction;
  const NotificationPolicy({
    required this.title,
    required this.message,
    this.priority = 0,
    this.permissionTitle,
    this.permissionMessage,
    this.positiveAction,
    this.negativeAction,
  });
}

class NotificationPolicyBuilder {
  String _t = "Tracking";
  String _m = "Active";
  int _p = 0;
  String? _pt;
  String? _pm;
  String? _pa;
  String? _na;

  NotificationPolicyBuilder setTitle(String v) {
    _t = v;
    return this;
  }

  NotificationPolicyBuilder setMessage(String v) {
    _m = v;
    return this;
  }

  NotificationPolicyBuilder setPriority(int v) {
    _p = v;
    return this;
  }

  NotificationPolicyBuilder setPermissionTitle(String? v) {
    _pt = v;
    return this;
  }

  NotificationPolicyBuilder setPermissionMessage(String? v) {
    _pm = v;
    return this;
  }

  NotificationPolicyBuilder setPositiveAction(String? v) {
    _pa = v;
    return this;
  }

  NotificationPolicyBuilder setNegativeAction(String? v) {
    _na = v;
    return this;
  }

  NotificationPolicy build() => NotificationPolicy(
    title: _t,
    message: _m,
    priority: _p,
    permissionTitle: _pt,
    permissionMessage: _pm,
    positiveAction: _pa,
    negativeAction: _na,
  );
}

class LoggingPolicy {
  final int logLevel;
  final bool debug;
  const LoggingPolicy({this.logLevel = 2, this.debug = true}); // 2 = verbose
}

class LoggingPolicyBuilder {
  int _l = 2;
  bool _d = true;

  LoggingPolicyBuilder setLogLevel(int v) {
    _l = v;
    return this;
  }

  LoggingPolicyBuilder setDebug(bool v) {
    _d = v;
    return this;
  }

  LoggingPolicy build() => LoggingPolicy(logLevel: _l, debug: _d);
}

class LocationManagerConfig {
  final TrackingPolicy tracking;
  final DataSyncPolicy sync;
  final PersistencePolicy persistence;
  final LifecyclePolicy lifecycle;
  final NotificationPolicy notification;
  final LoggingPolicy logging;
  final bool reset;
  final double arrivalRadius;

  LocationManagerConfig({
    required this.tracking,
    required this.sync,
    required this.persistence,
    required this.lifecycle,
    required this.notification,
    required this.logging,
    this.reset = false,
    this.arrivalRadius = 2000.0,
  });
}

class LocationManagerConfigBuilder {
  TrackingPolicy _t = const TrackingPolicy();
  DataSyncPolicy _s = const DataSyncPolicy();
  PersistencePolicy _p = const PersistencePolicy();
  LifecyclePolicy _l = const LifecyclePolicy();
  NotificationPolicy _n = const NotificationPolicy(
    title: "Tracking",
    message: "Active",
  );
  LoggingPolicy _lg = const LoggingPolicy();
  bool _reset = false;
  double _r = 2000.0;

  LocationManagerConfigBuilder setTracking(TrackingPolicy v) {
    _t = v;
    return this;
  }

  LocationManagerConfigBuilder setSync(DataSyncPolicy v) {
    _s = v;
    return this;
  }

  LocationManagerConfigBuilder setPersistence(PersistencePolicy v) {
    _p = v;
    return this;
  }

  LocationManagerConfigBuilder setLifecycle(LifecyclePolicy v) {
    _l = v;
    return this;
  }

  LocationManagerConfigBuilder setNotification(NotificationPolicy v) {
    _n = v;
    return this;
  }

  LocationManagerConfigBuilder setLogging(LoggingPolicy v) {
    _lg = v;
    return this;
  }

  LocationManagerConfigBuilder setReset(bool v) {
    _reset = v;
    return this;
  }

  LocationManagerConfigBuilder setArrivalRadius(double v) {
    _r = v;
    return this;
  }

  LocationManagerConfig build() => LocationManagerConfig(
    tracking: _t,
    sync: _s,
    persistence: _p,
    lifecycle: _l,
    notification: _n,
    logging: _lg,
    reset: _reset,
    arrivalRadius: _r,
  );
}
