import 'location_service_manager_config_policy.dart';

class LocationManagerConfig {
  final TrackingPolicy tracking;
  final PersistencePolicy persistence;
  final LifecyclePolicy lifecycle;
  final NotificationPolicy notification;
  final LoggingPolicy logging;
  final RationalePolicy rationale;
  final bool reset;
  final double arrivalRadius;

  LocationManagerConfig({
    required this.tracking,
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
    persistence: _persistence,
    lifecycle: _lifecycle,
    notification: _notification,
    logging: _logging,
    rationale: _rationale,
    reset: _reset,
    arrivalRadius: _arrivalRadius,
  );
}