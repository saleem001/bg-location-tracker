import 'location_events.dart';

class TrackingPolicy {
  final int accuracy;
  final double distanceFilter;
  final int stopTimeout;
  final double movementThreshold;
  final int locationUpdateInterval;
  final bool isMoving;
  const TrackingPolicy({
    this.accuracy = 4,
    this.distanceFilter = 10.0,
    this.stopTimeout = 5,
    this.movementThreshold = 25.0,
    this.locationUpdateInterval = 1000,
    this.isMoving = false,
  });
}

class TrackingPolicyBuilder {
  int _accuracy = 4;
  double _distanceFilter = 10.0;
  int _stopTimeout = 5;
  double _movementThreshold = 25.0;
  int _locationUpdateInterval = 1000;
  bool _isMoving = false;

  TrackingPolicyBuilder setAccuracy(int v) {
    _accuracy = v;
    return this;
  }

  TrackingPolicyBuilder setDistanceFilter(double v) {
    _distanceFilter = v;
    return this;
  }

  TrackingPolicyBuilder setStopTimeout(int v) {
    _stopTimeout = v;
    return this;
  }

  TrackingPolicyBuilder setMovementThreshold(double v) {
    _movementThreshold = v;
    return this;
  }

  TrackingPolicyBuilder setLocationUpdateInterval(int v) {
    _locationUpdateInterval = v;
    return this;
  }

  TrackingPolicyBuilder setIsMoving(bool v) {
    _isMoving = v;
    return this;
  }

  TrackingPolicy build() => TrackingPolicy(
    accuracy: _accuracy,
    distanceFilter: _distanceFilter,
    stopTimeout: _stopTimeout,
    movementThreshold: _movementThreshold,
    locationUpdateInterval: _locationUpdateInterval,
    isMoving: _isMoving,
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
  String? _uploadUrl;
  DomainTransistorToken? _transistorToken;
  bool _autoSync = true;

  DataSyncPolicyBuilder setUploadUrl(String? v) {
    _uploadUrl = v;
    return this;
  }

  DataSyncPolicyBuilder setTransistorToken(DomainTransistorToken? v) {
    _transistorToken = v;
    return this;
  }

  DataSyncPolicyBuilder setAutoSync(bool v) {
    _autoSync = v;
    return this;
  }

  DataSyncPolicy build() => DataSyncPolicy(
    uploadUrl: _uploadUrl,
    transistorToken: _transistorToken,
    autoSync: _autoSync,
  );
}

class PersistencePolicy {
  final int maxDaysToPersist;
  final int persistMode;
  const PersistencePolicy({this.maxDaysToPersist = -1, this.persistMode = 2});
}

class PersistencePolicyBuilder {
  int _maxDaysToPersist = -1;
  int _persistMode = 2; // 2 = PersistMode.all

  PersistencePolicyBuilder setMaxDaysToPersist(int v) {
    _maxDaysToPersist = v;
    return this;
  }

  PersistencePolicyBuilder setPersistMode(int v) {
    _persistMode = v;
    return this;
  }

  PersistencePolicy build() => PersistencePolicy(
    maxDaysToPersist: _maxDaysToPersist,
    persistMode: _persistMode,
  );
}

class LifecyclePolicy {
  final bool stopOnTerminate;
  final bool startOnBoot;
  final int heartbeatInterval;
  const LifecyclePolicy({
    this.stopOnTerminate = false,
    this.startOnBoot = true,
    this.heartbeatInterval = 60,
  });
}

class LifecyclePolicyBuilder {
  bool _stopOnTerminate = false;
  bool _startOnBoot = true;
  int _heartbeatInterval = 60;

  LifecyclePolicyBuilder setStopOnTerminate(bool v) {
    _stopOnTerminate = v;
    return this;
  }

  LifecyclePolicyBuilder setStartOnBoot(bool v) {
    _startOnBoot = v;
    return this;
  }

  LifecyclePolicyBuilder setHeartbeatInterval(int v) {
    _heartbeatInterval = v;
    return this;
  }

  LifecyclePolicy build() => LifecyclePolicy(
    stopOnTerminate: _stopOnTerminate,
    startOnBoot: _startOnBoot,
    heartbeatInterval: _heartbeatInterval,
  );
}

class RationalePolicy {
  final String title;
  final String message;
  final String positiveAction;
  final String negativeAction;

  const RationalePolicy({
    this.title = "Allow Location Access",
    this.message = "This app collects location data to record your trips.",
    this.positiveAction = "Settings",
    this.negativeAction = "Cancel",
  });
}

class RationalePolicyBuilder {
  String _title = "Allow Location Access";
  String _message = "This app collects location data to record your trips.";
  String _positiveAction = "Settings";
  String _negativeAction = "Cancel";

  RationalePolicyBuilder setTitle(String v) {
    _title = v;
    return this;
  }

  RationalePolicyBuilder setMessage(String v) {
    _message = v;
    return this;
  }

  RationalePolicyBuilder setPositiveAction(String v) {
    _positiveAction = v;
    return this;
  }

  RationalePolicyBuilder setNegativeAction(String v) {
    _negativeAction = v;
    return this;
  }

  RationalePolicy build() => RationalePolicy(
    title: _title,
    message: _message,
    positiveAction: _positiveAction,
    negativeAction: _negativeAction,
  );
}

class NotificationPolicy {
  final String title;
  final String message;
  final int priority;
  const NotificationPolicy({
    required this.title,
    required this.message,
    this.priority = 0,
  });
}

class NotificationPolicyBuilder {
  String _title = "Tracking";
  String _message = "Active";
  int _priority = 0;

  NotificationPolicyBuilder setTitle(String v) {
    _title = v;
    return this;
  }

  NotificationPolicyBuilder setMessage(String v) {
    _message = v;
    return this;
  }

  NotificationPolicyBuilder setPriority(int v) {
    _priority = v;
    return this;
  }

  NotificationPolicy build() =>
      NotificationPolicy(title: _title, message: _message, priority: _priority);
}

class LoggingPolicy {
  final int logLevel;
  final bool debug;
  const LoggingPolicy({this.logLevel = 2, this.debug = true}); // 2 = verbose
}

class LoggingPolicyBuilder {
  int _logLevel = 2;
  bool _debug = true;

  LoggingPolicyBuilder setLogLevel(int v) {
    _logLevel = v;
    return this;
  }

  LoggingPolicyBuilder setDebug(bool v) {
    _debug = v;
    return this;
  }

  LoggingPolicy build() => LoggingPolicy(logLevel: _logLevel, debug: _debug);
}

class LocationManagerConfig {
  final TrackingPolicy tracking;
  final DataSyncPolicy sync;
  final PersistencePolicy persistence;
  final LifecyclePolicy lifecycle;
  final NotificationPolicy notification;
  final LoggingPolicy logging;
  final RationalePolicy rationale;
  final bool reset;
  final double arrivalRadius;

  LocationManagerConfig({
    required this.tracking,
    required this.sync,
    required this.persistence,
    required this.lifecycle,
    required this.notification,
    required this.logging,
    required this.rationale,
    this.reset = false,
    this.arrivalRadius = 2000.0,
  });
}

class LocationManagerConfigBuilder {
  TrackingPolicy _tracking = const TrackingPolicy();
  DataSyncPolicy _sync = const DataSyncPolicy();
  PersistencePolicy _persistence = const PersistencePolicy();
  LifecyclePolicy _lifecycle = const LifecyclePolicy();
  NotificationPolicy _notification = const NotificationPolicy(
    title: "Tracking",
    message: "Active",
  );
  LoggingPolicy _logging = const LoggingPolicy();
  RationalePolicy _rationale = const RationalePolicy();
  bool _reset = false;
  double _arrivalRadius = 2000.0;

  LocationManagerConfigBuilder setTracking(TrackingPolicy v) {
    _tracking = v;
    return this;
  }

  LocationManagerConfigBuilder setSync(DataSyncPolicy v) {
    _sync = v;
    return this;
  }

  LocationManagerConfigBuilder setPersistence(PersistencePolicy v) {
    _persistence = v;
    return this;
  }

  LocationManagerConfigBuilder setLifecycle(LifecyclePolicy v) {
    _lifecycle = v;
    return this;
  }

  LocationManagerConfigBuilder setNotification(NotificationPolicy v) {
    _notification = v;
    return this;
  }

  LocationManagerConfigBuilder setLogging(LoggingPolicy v) {
    _logging = v;
    return this;
  }

  LocationManagerConfigBuilder setRationale(RationalePolicy v) {
    _rationale = v;
    return this;
  }

  LocationManagerConfigBuilder setReset(bool v) {
    _reset = v;
    return this;
  }

  LocationManagerConfigBuilder setArrivalRadius(double v) {
    _arrivalRadius = v;
    return this;
  }

  LocationManagerConfig build() => LocationManagerConfig(
    tracking: _tracking,
    sync: _sync,
    persistence: _persistence,
    lifecycle: _lifecycle,
    notification: _notification,
    logging: _logging,
    rationale: _rationale,
    reset: _reset,
    arrivalRadius: _arrivalRadius,
  );
}
