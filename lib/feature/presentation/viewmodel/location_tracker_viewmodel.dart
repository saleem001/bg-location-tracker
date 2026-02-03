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
    _plugin.onLocation(_handleLocation);
    // Fires when movement state changes (moving <-> stationary)
    _plugin.onMotionChange((loc, isMoving) {
      _handleLocation(loc, isMoving: isMoving);
    });
  }

  void _handleLocation(LocationEntity loc, {bool? isMoving}) {
    print(
      "SCREEN UPDATE: Lat: ${loc.latitude}, Lng: ${loc.longitude}, Speed: ${loc.speed}, Odometer: ${loc.odometer}",
    );

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
    required double lat,
    required double lng,
    required String name,
    bool reset = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final config = _buildAdvancedConfig(reset: reset);
      if (!state.isServiceEnabled) {
        await initializeService(config);
      }

      if (reset) {
        await _plugin.setOdometer(0.0);
      }

      final currentPos = await _plugin.getCurrentPosition();
      final tripId = "trip_${DateTime.now().millisecondsSinceEpoch}";

      final newTrip = TripState.newTrip(
        tripId: tripId,
        destinationLat: lat,
        destinationLng: lng,
        destinationName: name,
      ).copyWith(currentLocation: currentPos);

      // Store trip data in SDK extras for persistence across restarts
      await _plugin.setConfig({
        'tripId': tripId,
        'destinationLat': lat,
        'destinationLng': lng,
        'destinationName': name,
        'startedAt': newTrip.startedAt?.toIso8601String(),
      });

      await _plugin.start();

      state = state.copyWith(isLoading: false, activeTrip: newTrip);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Start Failed: $e");
    }
  }

  Future<void> stopTrip() async {
    state = state.copyWith(isLoading: true);
    try {
      await _plugin.setConfig({});
      await _plugin.stop();
      await _plugin.removeGeofences();
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
              .setAccuracy(5) // Navigation Accuracy
              .setDistanceFilter(
                5,
              ) // Update every 5 meters for more frequent UI updates
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
              .setTitle("Swvl Track Me")
              .setMessage("Tracking your activity in background")
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
