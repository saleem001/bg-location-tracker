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