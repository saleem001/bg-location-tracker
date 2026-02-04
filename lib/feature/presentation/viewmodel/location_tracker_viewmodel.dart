import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_me/common/models/geofence_event.dart';
import 'package:track_me/common/models/location_events.dart';
import 'package:track_me/common/models/location_service_status.dart';
import 'package:track_me/common/models/tracking_events.dart';
import 'package:track_me/common/utils/location_utils.dart';
import '../../../common/models/location_config.dart';
import '../../../common/models/location_states.dart';
import '../../../common/services/location_manager.dart';

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
    _plugin.onLocation((loc) {
      _handleLocation(loc);
    });

    // Fires when movement state changes (moving <-> stationary)
    _plugin.onMotionChange((loc, isMoving) {
      _handleLocation(loc, isMoving: isMoving);
    });

    _plugin.onGeofence((identifier, action) {
      _handleGeofence(identifier, action);
    });

    _plugin.onLocationServiceStatusChange((event) {
      _onLocationServiceStatusChange(event);
    });
  }

  void _handleLocation(LocationTrackingEvent loc, {bool? isMoving}) {
    final speed = LocationUtils.msToKmh(loc.speed);
    TripState? updatedTrip = state.activeTrip;

    if (updatedTrip != null) {
      final distance = LocationUtils.calculateDistanceMeters(
        loc.latitude,
        loc.longitude,
        updatedTrip.destinationLat,
        updatedTrip.destinationLng,
      );

      updatedTrip = updatedTrip.copyWith(
        distanceRemainingKm: distance,
        hasArrived: distance < 0.05, // 50 meters
      );
    }

    state = state.copyWith(
      currentLocation: loc,
      speedKmh: speed,
      isMoving: isMoving ?? (speed > 1.0),
      isStationary: isMoving != null ? !isMoving : (speed <= 1.0),
      locationHistory: [...state.locationHistory, loc],
      activeTrip: updatedTrip,
    );
  }

  void _handleGeofence(String identifier, String action) {
    if (state.activeTrip?.tripId != identifier) return;

    final geofenceAction = GeofenceAction.fromString(action);

    state = state.copyWith(
      activeTrip: state.activeTrip?.copyWith(
        isWithinGeofence: geofenceAction.isInside,
      ),
    );
  }

  void _onLocationServiceStatusChange(LocationServiceStatus event) {
    if (!event.deviceLocationEnabled) {
      // Ask user to enable location services
    }

    if (event.locationPermissionStatus !=
        LocationPermissionStatus.allowedAlways) {
      // Ask user to grant "Always" permission
    }

    if (event.locationAccuracy == LocationAccuracy.reduced) {
      // Request precise location (iOS)
    }
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

      final tripId = "trip_${DateTime.now().millisecondsSinceEpoch}";

      final newTrip = TripState.newTrip(
        tripId: tripId,
        sourceLat: sourceLat,
        sourceLng: sourceLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        destinationName: name,
        geofenceRadius: geofenceRadius,
      );

      state = state.copyWith(isLoading: false, activeTrip: newTrip);

      await _plugin.setConfig({
        'tripId': tripId,
        'sourceLat': sourceLat,
        'sourceLng': sourceLng,
        'destinationLat': destinationLat,
        'destinationLng': destinationLng,
        'destinationName': name,
        'geofenceRadius': geofenceRadius,
      });

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
      state = state.copyWith(isLoading: false, activeTrip: null);
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
