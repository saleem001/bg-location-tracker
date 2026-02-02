import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:path_provider/path_provider.dart';

/// ---- 1. DOMAIN ENTITIES (Production Ready) ----

class LocationEntity {
  final double latitude;
  final double longitude;
  final double speed; // In m/s
  final double odometer;
  final DateTime timestamp;
  LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.speed,
    this.odometer = 0.0,
    required this.timestamp,
  });
}

class GeofenceEvent {
  final String identifier;
  final String action;
  GeofenceEvent({required this.identifier, required this.action});
}

class ActivityChangeEvent {
  final String activity;
  final int confidence;
  ActivityChangeEvent({required this.activity, required this.confidence});
}

class ProviderChangeEvent {
  final bool enabled;
  final int status;
  final bool network;
  final bool gps;
  ProviderChangeEvent({
    required this.enabled,
    required this.status,
    required this.network,
    required this.gps,
  });
}

class HttpEvent {
  final bool success;
  final int status;
  final String responseText;
  HttpEvent({
    required this.success,
    required this.status,
    required this.responseText,
  });
}

class MotionChangeEvent {
  final LocationEntity location;
  final bool isMoving;
  MotionChangeEvent({required this.location, required this.isMoving});
}

class DomainTransistorToken {
  final String accessToken;
  final String refreshToken;
  final int expires;
  final String url;
  DomainTransistorToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expires,
    required this.url,
  });
}

/// ---- 2. PRODUCTION STATE MODELS (Proper Architecture) ----

enum RouteStopStatus { pending, arrivingSoon, arrived }

class RouteStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final RouteStopStatus status;
  final DateTime? arrivalTime;

  RouteStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.status = RouteStopStatus.pending,
    this.arrivalTime,
  });

  RouteStop copyWith({RouteStopStatus? status, DateTime? arrivalTime}) =>
      RouteStop(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        status: status ?? this.status,
        arrivalTime: arrivalTime ?? this.arrivalTime,
      );
}

class TripState {
  final String tripId;
  final double destinationLat;
  final double destinationLng;
  final String destinationName;
  final List<RouteStop> stops;
  final LocationEntity? currentLocation;
  final List<LocationEntity> history;
  final double speedKmh;
  final double distanceRemainingKm;
  final bool isMoving;
  final bool isStationary;
  final bool hasArrived;
  final DateTime? startedAt;
  final DateTime? arrivedAt;

  TripState({
    required this.tripId,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
    this.stops = const [],
    this.currentLocation,
    this.history = const [],
    this.speedKmh = 0.0,
    this.distanceRemainingKm = 0.0,
    this.isMoving = false,
    this.isStationary = false,
    this.hasArrived = false,
    this.startedAt,
    this.arrivedAt,
  });

  factory TripState.newTrip({
    required String tripId,
    required double destinationLat,
    required double destinationLng,
    required String destinationName,
    List<RouteStop> stops = const [],
  }) => TripState(
    tripId: tripId,
    destinationLat: destinationLat,
    destinationLng: destinationLng,
    destinationName: destinationName,
    stops: stops,
    startedAt: DateTime.now(),
  );

  TripState copyWith({
    List<RouteStop>? stops,
    LocationEntity? currentLocation,
    List<LocationEntity>? history,
    double? speedKmh,
    double? distanceRemainingKm,
    bool? isMoving,
    bool? isStationary,
    bool? hasArrived,
    DateTime? arrivedAt,
  }) => TripState(
    tripId: tripId,
    destinationLat: destinationLat,
    destinationLng: destinationLng,
    destinationName: destinationName,
    stops: stops ?? this.stops,
    currentLocation: currentLocation ?? this.currentLocation,
    history: history ?? this.history,
    speedKmh: speedKmh ?? this.speedKmh,
    distanceRemainingKm: distanceRemainingKm ?? this.distanceRemainingKm,
    isMoving: isMoving ?? this.isMoving,
    isStationary: isStationary ?? this.isStationary,
    hasArrived: hasArrived ?? this.hasArrived,
    startedAt: startedAt,
    arrivedAt: arrivedAt ?? this.arrivedAt,
  );
}

class LocationState {
  final bool isServiceEnabled;
  final bool isStationary;
  final bool isLoading;
  final TripState? activeTrip;
  final List<LocationEntity> locationHistory;
  final LocationEntity? pendingDestination;
  final String? lastActivity;
  final String? error;

  LocationState({
    this.isServiceEnabled = false,
    this.isStationary = false,
    this.isLoading = false,
    this.activeTrip,
    this.locationHistory = const [],
    this.pendingDestination,
    this.lastActivity,
    this.error,
  });

  factory LocationState.initial() => LocationState();

  LocationState copyWith({
    bool? isServiceEnabled,
    bool? isStationary,
    bool? isLoading,
    TripState? activeTrip,
    List<LocationEntity>? locationHistory,
    LocationEntity? pendingDestination,
    String? lastActivity,
    String? error,
  }) => LocationState(
    isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
    isStationary: isStationary ?? this.isStationary,
    isLoading: isLoading ?? this.isLoading,
    activeTrip: activeTrip ?? this.activeTrip,
    locationHistory: locationHistory ?? this.locationHistory,
    pendingDestination: pendingDestination ?? this.pendingDestination,
    lastActivity: lastActivity ?? this.lastActivity,
    error: error ?? this.error,
  );
}

/// ---- 3. HEADLESS TASK (Resilience) ----
/// This runs in a separate Isolate when the app is killed.
@pragma('vm:entry-point')
void locationHeadlessTask(bg.HeadlessEvent event) async {
  // Example of a custom task: Log to a private file for verification
  final timestamp = DateTime.now().toIso8601String();
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/headless_logs.jsonl');
    await file.writeAsString(
      '${jsonEncode({'event': event.name, 'ts': timestamp, 'data': event.event.toString()})}\n',
      mode: FileMode.append,
      flush: true,
    );
  } catch (_) {}
}

/// ---- 4. DOMAIN POLICIES & BUILDERS ----

class TrackingPolicy {
  // Accuracy in meters, higher values are less accurate but use less battery
  final int accuracy;
  // Distance filter in meters, minimum distance between location updates
  final double distanceFilter;
  // Time in seconds to consider the device as stationary
  final int stopTimeout;
  // Movement threshold in meters, minimum distance to consider the device as moving
  final double movementThreshold;
  // Location update interval in milliseconds, even if no location change is detected
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

/// ---- 5. HARDWARE ABSTRACTION & PLUGIN ----

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

    // ready() handles both initial setup AND configuration updates (via #setConfig internally)
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
}

/// ---- 6. EVENT HUB (LocationManager) ----

class LocationManager {
  final ILocationPlugin _plugin;
  final _locController = StreamController<LocationEntity>.broadcast();
  final _geoController = StreamController<GeofenceEvent>.broadcast();
  final _actController = StreamController<ActivityChangeEvent>.broadcast();
  final _providerController = StreamController<ProviderChangeEvent>.broadcast();
  final _enabledController = StreamController<bool>.broadcast();
  final _motionController = StreamController<MotionChangeEvent>.broadcast();

  LocationManager(this._plugin);

  Stream<LocationEntity> get onLocation => _locController.stream;
  Stream<GeofenceEvent> get onGeofence => _geoController.stream;
  Stream<ActivityChangeEvent> get onActivity => _actController.stream;
  Stream<ProviderChangeEvent> get onProviderChange =>
      _providerController.stream;
  Stream<bool> get onEnabledChange => _enabledController.stream;
  Stream<MotionChangeEvent> get onMotionChange => _motionController.stream;

  Future<bool> initialize(LocationManagerConfig config) async {
    _plugin.removeListeners();
    _startPiping();
    return await _plugin.initialize(config);
  }

  Future<bool> restoreState() async {
    _plugin.removeListeners();
    _startPiping();
    return await _plugin.restoreState();
  }

  Future<void> updateConfig(Map<String, dynamic> extras) =>
      _plugin.setConfig(extras);

  void _startPiping() {
    _plugin.onLocation(_locController.add);
    _plugin.onGeofence(_geoController.add);
    _plugin.onActivityChange(_actController.add);
    _plugin.onProviderChange(_providerController.add);
    _plugin.onEnabledChange(_enabledController.add);
    _plugin.onMotionChange(
      (loc, isMoving) => _motionController.add(
        MotionChangeEvent(location: loc, isMoving: isMoving),
      ),
    );
  }

  Future<void> startTracking() => _plugin.start();
  Future<void> changePace(bool isMoving) => _plugin.changePace(isMoving);
  Future<void> stopTracking() => _plugin.stop();
  Future<LocationEntity> getCurrentPosition() => _plugin.getCurrentPosition();
  Future<int> requestPermission() => _plugin.requestPermission();
  Future<int> getAuthorizationStatus() => _plugin.getAuthorizationStatus();
  Future<void> setupArrivalZone(
    String id,
    double lat,
    double lng,
    double rad,
  ) => _plugin.addGeofence(id, lat, lng, rad);
  Future<void> clearZones() => _plugin.removeGeofences();

  Future<String> getNativeLogs() => bg.Logger.getLog();
  Future<void> clearNativeLogs() => bg.Logger.destroyLog();

  void dispose() {
    _locController.close();
    _geoController.close();
    _actController.close();
    _providerController.close();
    _enabledController.close();
    _motionController.close();
    _plugin.removeListeners();
  }
}

/// ---- 7. PRODUCTION SERVICE (Riverpod State Bridge) ----

class LocationService extends StateNotifier<LocationState> {
  final LocationManager _manager;
  final List<StreamSubscription> _subs = [];

  LocationService(this._manager) : super(LocationState.initial()) {
    _initSubscribers();
    _autoInitialize();
  }

  Future<LocationEntity> getCurrentPosition() => _manager.getCurrentPosition();

  Future<void> _autoInitialize() async {
    // Check if we have permissions already
    final status = await _manager.getAuthorizationStatus();
    if (status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_ALWAYS ||
        status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_WHEN_IN_USE) {
      // Re-initialize WITHOUT overwriting config
      try {
        final enabled = await _manager.restoreState();

        // Restore trip from plugin 'extras'
        TripState? restoredTrip;
        final statePlugin = await bg.BackgroundGeolocation.state;
        final extras = statePlugin.extras;

        if (enabled && extras != null && extras['tripId'] != null) {
          final List<RouteStop> restoredStops = [];
          final stopsData = extras['stops'] as String? ?? "";
          if (stopsData.isNotEmpty) {
            for (var stopStr in stopsData.split('|')) {
              final parts = stopStr.split(':');
              if (parts.length >= 4) {
                final stopId = parts[0];
                restoredStops.add(
                  RouteStop(
                    id: stopId,
                    name: parts[1],
                    latitude: double.parse(parts[2]),
                    longitude: double.parse(parts[3]),
                    status: RouteStopStatus.values.firstWhere(
                      (e) =>
                          e.name ==
                          (extras['stop_status_$stopId'] ?? 'pending'),
                      orElse: () => RouteStopStatus.pending,
                    ),
                    arrivalTime: extras['stop_arrival_time_$stopId'] != null
                        ? DateTime.tryParse(extras['stop_arrival_time_$stopId'])
                        : null,
                  ),
                );
              }
            }
          }

          restoredTrip = TripState(
            tripId: extras['tripId'],
            destinationLat: extras['destinationLat'] ?? 0.0,
            destinationLng: extras['destinationLng'] ?? 0.0,
            destinationName: extras['destinationName'] ?? "",
            stops: restoredStops,
            startedAt: DateTime.tryParse(extras['startedAt'] ?? ""),
            isMoving: statePlugin.isMoving == true,
          );
        }

        state = state.copyWith(
          isLoading: false,
          isServiceEnabled: enabled,
          activeTrip: restoredTrip,
          lastActivity: enabled ? "Restored" : "Ready",
        );
      } catch (_) {}
    }
  }

  void _initSubscribers() {
    _subs.add(_manager.onLocation.listen(_handleLocation));
    _subs.add(_manager.onGeofence.listen(_handleGeofence));
    _subs.add(
      _manager.onActivity.listen((a) {
        state = state.copyWith(
          lastActivity: '${a.activity} (${a.confidence}%)',
        );
      }),
    );
    _subs.add(
      _manager.onMotionChange.listen((event) {
        final isMoving = event.isMoving;
        final loc = event.location;

        state = state.copyWith(
          isStationary: !isMoving,
          activeTrip: state.activeTrip?.copyWith(
            isMoving: isMoving,
            isStationary: !isMoving,
            currentLocation: loc,
            speedKmh: isMoving ? (state.activeTrip?.speedKmh ?? 0.0) : 0.0,
          ),
        );
      }),
    );
    _subs.add(
      _manager.onEnabledChange.listen(
        (enabled) => state = state.copyWith(isServiceEnabled: enabled),
      ),
    );
  }

  void _handleLocation(LocationEntity loc) {
    print("📍 RAW GPS SPEED: ${loc.speed} m/s");
    final speedKmh = loc.speed * 3.6;
    TripState? updatedTrip;

    if (state.activeTrip != null) {
      updatedTrip = state.activeTrip!.copyWith(
        currentLocation: loc,
        speedKmh: speedKmh > 0 ? speedKmh : 0,
        // Do not override isMoving/isStationary here; let onMotionChange handle the state machine
        isMoving: state.activeTrip!.isMoving,
        isStationary: state.activeTrip!.isStationary,
        history: [...state.activeTrip!.history, loc],
      );
    }

    state = state.copyWith(
      activeTrip: updatedTrip,
      locationHistory: [...state.locationHistory, loc],
    );
  }

  void _handleGeofence(GeofenceEvent event) {
    if (state.activeTrip == null) return;

    final id = event.identifier;
    final action = event.action;

    print("🔔 GEOFENCE EVENT: ${id} - ${action}");

    // Check if it's the main destination
    if (state.activeTrip!.tripId == id && action == 'ENTER') {
      state = state.copyWith(
        activeTrip: state.activeTrip!.copyWith(
          hasArrived: true,
          arrivedAt: DateTime.now(),
        ),
      );
      _manager.updateConfig({
        'hasArrived': true,
        'arrivedAt': DateTime.now().toIso8601String(),
      });
      return;
    }

    // Check if it's one of the stops (proximity or arrival)
    final parts = id.split("::");
    if (parts.length < 2) return;

    final stopId = parts[0];
    final type = parts[1]; // 'p' for proximity, 'a' for arrival

    final stopIndex = state.activeTrip!.stops.indexWhere((s) => s.id == stopId);
    if (stopIndex == -1) return;

    final stop = state.activeTrip!.stops[stopIndex];
    RouteStopStatus newStatus = stop.status;

    if (action == 'ENTER') {
      if (type == 'p' && stop.status == RouteStopStatus.pending) {
        newStatus = RouteStopStatus.arrivingSoon;
      } else if (type == 'a') {
        newStatus = RouteStopStatus.arrived;
      }
    }

    if (newStatus != stop.status) {
      final now = DateTime.now();
      final updatedStops = List<RouteStop>.from(state.activeTrip!.stops);
      updatedStops[stopIndex] = stop.copyWith(
        status: newStatus,
        arrivalTime: newStatus == RouteStopStatus.arrived
            ? now
            : stop.arrivalTime,
      );

      state = state.copyWith(
        activeTrip: state.activeTrip!.copyWith(stops: updatedStops),
      );

      // Persist stop status
      _manager.updateConfig({
        'stop_status_${stopId}': newStatus.name,
        if (newStatus == RouteStopStatus.arrived)
          'stop_arrival_time_${stopId}': now.toIso8601String(),
      });
    }
  }

  Future<void> initializeWithPermission(LocationManagerConfig config) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      lastActivity: "Initializing...",
    );
    try {
      // 1. Request Permission FIRST
      final status = await _manager.requestPermission();

      // 2. Initialize Hardware Plugin only if we have permissions
      // Note: status 3=WHEN_IN_USE, 4=ALWAYS
      if (status >= 3) {
        final enabled = await _manager.initialize(config);
        state = state.copyWith(
          isLoading: false,
          isServiceEnabled: enabled,
          pendingDestination: config.reset ? null : state.pendingDestination,
          lastActivity: "System Online",
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Permission Denied: Location access required.",
          lastActivity: "Auth Failed",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Setup Failed: ${e.toString()}",
        lastActivity: "Error",
      );
    }
  }

  Future<void> initialize(LocationManagerConfig config) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final enabled = await _manager.initialize(config);

      TripState? restoredTrip;
      final statePlugin = await bg.BackgroundGeolocation.state;
      final extras = statePlugin.extras;

      if (enabled && extras != null && extras['tripId'] != null) {
        restoredTrip = TripState(
          tripId: extras['tripId'],
          destinationLat: extras['destinationLat'],
          destinationLng: extras['destinationLng'],
          destinationName: extras['destinationName'],
          startedAt: DateTime.tryParse(extras['startedAt'] ?? ""),
          isMoving: statePlugin.isMoving == true,
        );
      }

      state = state.copyWith(
        isLoading: false,
        isServiceEnabled: enabled,
        activeTrip: restoredTrip,
        pendingDestination: config.reset ? null : state.pendingDestination,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Init Failed: ${e.toString()}",
      );
    }
  }

  Future<void> captureDestination(LocationManagerConfig config) async {
    state = state.copyWith(isLoading: true);
    try {
      if (!state.isServiceEnabled) {
        await initializeWithPermission(config);
      }
      final loc = await _manager.getCurrentPosition();
      state = state.copyWith(pendingDestination: loc, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: "Capture Failed: ${e.toString()}",
        isLoading: false,
      );
    }
  }

  Future<void> requestPermission() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _manager.requestPermission();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Permission Request Failed: ${e.toString()}",
      );
    }
  }

  Future<void> startTrip({
    required double lat,
    required double lng,
    required String name,
    required LocationManagerConfig config,
    List<RouteStop> stops = const [],
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (!state.isServiceEnabled) {
        await initializeWithPermission(config);
      }

      final currentPos = await _manager.getCurrentPosition();
      final tripId = "trip_${DateTime.now().millisecondsSinceEpoch}";

      // 1. Setup DUAL geofences for destination AND all stops
      await _manager.clearZones();

      // Destination geofence
      await _manager.setupArrivalZone(tripId, lat, lng, config.arrivalRadius);

      // Each stop gets two zones:
      // 1. Proximity (1km) -> 'Arriving Soon'
      // 2. Arrival (200m) -> 'Arrived'
      for (var stop in stops) {
        print(
          "📍 REGISTERING GEOFENCE: ${stop.name} (ID: ${stop.id}) at ${stop.latitude}, ${stop.longitude}",
        );
        // Proximity Zone
        await _manager.setupArrivalZone(
          "${stop.id}::p",
          stop.latitude,
          stop.longitude,
          1000,
        );
        // Arrival Zone
        await _manager.setupArrivalZone(
          "${stop.id}::a",
          stop.latitude,
          stop.longitude,
          200,
        );
      }

      // 2. Create state
      final newTrip = TripState.newTrip(
        tripId: tripId,
        destinationLat: lat,
        destinationLng: lng,
        destinationName: name,
        stops: stops,
      ).copyWith(currentLocation: currentPos);

      // 3. Persist trip config
      final stopsCsv = stops
          .map((s) => "${s.id}:${s.name}:${s.latitude}:${s.longitude}")
          .join('|');

      await _manager.updateConfig({
        'tripId': tripId,
        'destinationLat': lat,
        'destinationLng': lng,
        'destinationName': name,
        'stops': stopsCsv,
        'startedAt': newTrip.startedAt?.toIso8601String(),
        'hasArrived': false,
      });

      await _manager.startTracking();
      await _manager.changePace(true);

      state = state.copyWith(isLoading: false, activeTrip: newTrip);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Start Failed: ${e.toString()}",
      );
    }
  }

  Future<void> stopTrip() async {
    // Clear the persistent state in the plugin
    await _manager.updateConfig({});
    state = state.copyWith(activeTrip: null, locationHistory: []);
    await _manager.stopTracking();
    await _manager.clearZones();
  }

  Future<String> getNativeLogs() => _manager.getNativeLogs();
  Future<void> clearNativeLogs() => _manager.clearNativeLogs();

  @override
  void dispose() {
    for (var s in _subs) {
      s.cancel();
    }
    _manager.dispose();
    super.dispose();
  }
}
