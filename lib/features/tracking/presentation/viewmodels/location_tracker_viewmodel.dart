import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../common/utils/location_utils.dart';
import '../../../../common/utils/scope_functions.dart';
import '../../data/datasources/location_plugin_configs.dart';
import '../../domain/entities/geofence_event.dart';
import '../../domain/entities/location_event.dart';
import '../../domain/entities/tracking_event.dart';
import '../../data/datasources/location_service_manager.dart';
import '../../data/datasources/location_event_aggregator.dart';
import '../../data/datasources/socket_sync_service.dart';
import '../../domain/services/geofence_notification_handler.dart';
import '../providers/plugin_logs_provider.dart';
import '../states/location_state.dart';

class LocationTrackerViewModel extends ChangeNotifier {
  static final LocationTrackerViewModel _instance = LocationTrackerViewModel._internal();
  factory LocationTrackerViewModel() => _instance;

  LocationTrackerViewModel._internal() {
    _init();
  }

  LocationState _state = LocationState.initial();
  LocationState get state => _state;

  StreamSubscription<LocationEvent>? _subscription;
  final BackgroundLocationServiceManager _manager = BackgroundLocationServiceManager();

  void _init() {
    // Ensure Sync Service is active
    SocketSyncService().start();
    GeofenceNotificationHandler();

    _subscription = LocationEventAggregator().events.listen(_handleEvent);
  }

  void _handleEvent(LocationEvent event) {
    if (event is LocationUpdated) {
      _processLocation(event.location, event.location.isMoving);
    } else if (event is GeofenceTriggered) {
      _handleGeofence(event.geofence.identifier, event.geofence.action);
    } else if (event is MotionChanged) {
      PluginLogsNotifier().logMotionChange(
        event.motion.isMoving,
        event.motion.location.latitude,
        event.motion.location.longitude,
      );
      _processLocation(event.motion.location, event.motion.isMoving);
    } else if (event is ServiceEnabledChanged) {
      _handleServiceEnableChange(event.isEnabled);
    }
  }

  void _processLocation(LocationTrackingEvent trackingEvent, bool isMoving) {
    final speed = LocationUtils.msToKmh(trackingEvent.speed);
    TripState? updatedTrip = _state.activeTrip;

    if (updatedTrip != null) {
      double minDistance = double.infinity;
      final updatedGeofences = updatedTrip.geofences.map((g) {
        final d = LocationUtils.calculateDistanceMeters(
          trackingEvent.latitude,
          trackingEvent.longitude,
          g.latitude,
          g.longitude,
        );
        if (d < minDistance) minDistance = d;
        return g.copyWith(distanceMeters: d);
      }).toList();

      updatedTrip = updatedTrip.copyWith(
        geofences: updatedGeofences,
        distanceRemainingMeters: minDistance == double.infinity
            ? 0.0
            : minDistance,
        hasArrived: minDistance < 50, // 50 meters from any station
      );
    }

    _state = _state.copyWith(
      currentLocation: trackingEvent,
      speedKmh: speed,
      isMoving: isMoving,
      isStationary: !isMoving,
      locationHistory: [..._state.locationHistory, trackingEvent],
      activeTrip: updatedTrip,
    );

    // Log location
    PluginLogsNotifier().logLocation(
      trackingEvent.latitude,
      trackingEvent.longitude,
      trackingEvent.speed,
      trackingEvent.odometer,
    );
    notifyListeners();
  }

  void _handleGeofence(String identifier, GeofenceAction action) {
    if (_state.activeTrip == null) return;

    final updatedGeofences = _state.activeTrip!.geofences.map((g) {
      if (g.id == identifier) {
        final bool isInside = action == GeofenceAction.enter;
        return g.copyWith(
          isInside: isInside,
          status: isInside ? GeofenceStatus.arrived : GeofenceStatus.departed,
        );
      }
      return g;
    }).toList();

    _state = _state.copyWith(
      activeTrip: _state.activeTrip!.copyWith(geofences: updatedGeofences),
    );

    // Log the geofence event
    PluginLogsNotifier().logGeofence(identifier, action.name);
    notifyListeners();
  }

  void _handleServiceEnableChange(bool isServiceEnabled) {
    _state = _state.copyWith(isServiceEnabled: isServiceEnabled);
    notifyListeners();
  }

  Future<void> startTrip({
    required double sourceLat,
    required double sourceLng,
    required List<Station> stations,
    String? captainId,
    String? rideId,
    bool reset = true,
  }) async {
    if (_state.isLoading || _state.activeTrip != null) return;
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();
    try {
      // Simulate 2 seconds of processing/loading as requested
      await Future.delayed(const Duration(seconds: 2));

      if (!_state.isServiceEnabled) {
        final config = _buildAdvancedConfig(reset: reset);
        await _manager
            .addOnLocation()
            .addOnGeofence(stations)
            .addOnServiceStatusChange()
            .addOnMotionChange()
            .initialize(config);
        _state = _state.copyWith(isServiceEnabled: true);
      }

      final tripId = "trip_${DateTime.now().millisecondsSinceEpoch}";

      final newTrip = TripState.newTrip(
        tripId: tripId,
        sourceLat: sourceLat,
        sourceLng: sourceLng,
        geofences: stations,
        captainId: captainId,
        rideId: rideId,
      );

      _state = _state.copyWith(isLoading: false, activeTrip: newTrip);
      notifyListeners();

      await _manager.start();

      PluginLogsNotifier().logInfo("Trip started with ${stations.length} geofences");
    } catch (e) {
      PluginLogsNotifier().logError("Start Trip Failed", error: e);
      _state = _state.copyWith(isLoading: false, error: "Start Failed: $e");
      notifyListeners();
    }
  }

  Future<void> stopTrip() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();
    try {
      // 1. Stop the background geolocation service
      await _manager.pause();

      // 2. Fully reset the state
      _state = _state.copyWith(
        isLoading: false,
        clearActiveTrip: true,
        isServiceEnabled: false,
        isMoving: false,
        isStationary: true,
        speedKmh: 0.0,
      );

      PluginLogsNotifier().logInfo("Trip stopped");
      notifyListeners();
    } catch (e) {
      PluginLogsNotifier().logError("Stop Trip Failed", error: e);
      _state = _state.copyWith(isLoading: false, error: "Stop Failed: $e");
      notifyListeners();
    }
  }

  Future<LocationTrackingEvent> getCurrentPosition() async {
    return await _manager.getCurrentPosition();
  }

  LocationManagerConfig _buildAdvancedConfig({required bool reset}) {
    return LocationManagerConfigBuilder()
        .setTracking(
          TrackingPolicyBuilder()
              .setAccuracy(5)
              .setDistanceFilter(5)
              .setMovementThreshold(5)
              .build(),
        )
        .setLifecycle(
          LifecyclePolicyBuilder()
              .setStopOnTerminate(false)
              .setStartOnBoot(true)
              .build(),
        )
        .setNotification(
          NotificationPolicyBuilder()
              .setTitle("Location Tracking Active")
              .setMessage("Updating position, speed, and odometer")
              .build(),
        )
        .setLogging(
          LoggingPolicyBuilder().setLogLevel(2).setDebug(true).build(),
        )
        .setReset(reset)
        .build();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
