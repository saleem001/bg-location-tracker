import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import '../../../common/models/location_config.dart';
import '../../../common/models/location_states.dart';
import '../../../common/models/location_events.dart';
import '../../../common/services/location_plugin.dart';

final locationTrackerViewModelProvider =
    StateNotifierProvider<LocationTrackerViewModel, LocationState>((ref) {
      return LocationTrackerViewModel(BackgroundGeolocationPlugin());
    });

class LocationTrackerViewModel extends StateNotifier<LocationState> {
  final ILocationPlugin _plugin;

  LocationTrackerViewModel(this._plugin) : super(LocationState.initial()) {
    _initSubscribers();
  }

  void _initSubscribers() {
    // Primary location updates
    _plugin.onLocation((loc) {
      _handleLocation(loc);
    });

    // Fires when movement state changes (moving <-> stationary)
    _plugin.onMotionChange((loc, isMoving) {
      _handleLocation(loc, isMoving: isMoving);
    });

    // Geofence events
    _plugin.onGeofence((identifier, action) {
      if (state.activeTrip?.tripId == identifier) {
        if (action == "ENTER") {
          state = state.copyWith(
            activeTrip: state.activeTrip?.copyWith(isWithinGeofence: true),
          );
        } else if (action == "EXIT") {
          state = state.copyWith(
            activeTrip: state.activeTrip?.copyWith(isWithinGeofence: false),
          );
        }
      }
    });
  }

  void _handleLocation(LocationEntity loc, {bool? isMoving}) {
    final speedKmh = loc.speed * 3.6;
    TripState? updatedTrip;

    if (state.activeTrip != null) {
      updatedTrip = state.activeTrip!.copyWith(
        currentLocation: loc,
        speedKmh: speedKmh > 0 ? speedKmh : 0,
        isMoving: isMoving ?? state.activeTrip!.isMoving,
        isStationary: isMoving != null
            ? !isMoving
            : state.activeTrip!.isStationary,
        history: [...state.activeTrip!.history, loc],
      );
    }

    state = state.copyWith(
      activeTrip: updatedTrip,
      locationHistory: [...state.locationHistory, loc],
      isStationary: isMoving != null ? !isMoving : state.isStationary,
    );
  }

  Future<void> initializeService(LocationManagerConfig config) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final enabled = await _plugin.initialize(config);
      state = state.copyWith(
        isLoading: false,
        isServiceEnabled: enabled,
        lastActivity: "Plugin Ready",
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Initialization Error: ${e.toString()}",
      );
    }
  }

  Future<void> captureDestination({bool reset = true}) async {
    state = state.copyWith(isLoading: true);
    try {
      if (!state.isServiceEnabled) {
        await initializeService(_buildAdvancedConfig(reset: reset));
      }
      final loc = await _plugin.getCurrentPosition();
      state = state.copyWith(pendingDestination: loc, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Capture Failed: $e");
    }
  }

  Future<void> startTrip({
    required double sourceLat,
    required double sourceLng,
    required double destinationLat,
    required double destinationLng,
    required String name,
    double geofenceRadius = 200.0,
    bool reset = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final config = _buildAdvancedConfig(reset: reset);
      if (!state.isServiceEnabled) {
        await initializeService(config);
      }

      final currentPos = await _plugin.getCurrentPosition();
      final tripId = "trip_${DateTime.now().millisecondsSinceEpoch}";

      final newTrip = TripState.newTrip(
        tripId: tripId,
        sourceLat: sourceLat,
        sourceLng: sourceLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        destinationName: name,
        geofenceRadius: geofenceRadius,
      ).copyWith(currentLocation: currentPos);

      state = state.copyWith(isLoading: false, activeTrip: newTrip);

      await _plugin.setConfig({
        'tripId': tripId,
        'sourceLat': sourceLat,
        'sourceLng': sourceLng,
        'destinationLat': destinationLat,
        'destinationLng': destinationLng,
        'destinationName': name,
        'geofenceRadius': geofenceRadius,
        'startedAt': newTrip.startedAt?.toIso8601String(),
      });

      // Register geofence for the destination
      await _plugin.addGeofence(
        tripId,
        destinationLat,
        destinationLng,
        geofenceRadius,
      );

      await _plugin.start();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Start Failed: $e");
    }
  }

  Future<void> stopTrip() async {
    state = state.copyWith(isLoading: true);
    try {
      if (state.activeTrip != null) {
        await _plugin.removeGeofence(state.activeTrip!.tripId);
      }
      await _plugin.setConfig({});
      await _plugin.stop();
      state = state.copyWith(
        isLoading: false,
        activeTrip: null,
        locationHistory: [],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Stop Failed: $e");
    }
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
    _plugin.removeListeners();
    super.dispose();
  }
}
