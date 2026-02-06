import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_me/features/tracking/data/datasources/location_plugin_configs.dart';
import '../providers/tracking_providers.dart';
import '../states/location_state.dart';

import '../../domain/entities/geofence_event.dart';
import '../../domain/entities/tracking_event.dart';
import '../../../../common/utils/location_utils.dart';
import '../../presentation/providers/plugin_logs_provider.dart';

class LocationTrackerViewModel extends Notifier<LocationState> {
  @override
  LocationState build() {
    // Listen to location stream via Provider
    ref.listen(locationStreamProvider, (previous, next) {
      if (next.hasValue) {
        _handleLocation(next.value!);
      }
    });

    // Listen to geofence alerts via Provider
    ref.listen(geofenceStreamProvider, (previous, next) {
      if (next.hasValue) {
        _handleGeofence(next.value!);
      }
    });

    // Listen to service status via Provider
    ref.listen(serviceStatusStreamProvider, (previous, next) {
      if (next.hasValue) {
        final status = next.value!;
        ref
            .read(pluginLogsProvider.notifier)
            .logServiceStatusChange(
              status.deviceLocationEnabled,
              status.locationPermissionStatus.name,
              status.locationAccuracy.name,
              status.gpsEnabled,
              status.networkEnabled,
            );
      }
    });

    return LocationState.initial();
  }

  // Helper to get the manager
  get _manager => ref.watch(backgroundLocationServiceManagerProvider);

  void _handleLocation(LocationTrackingEvent loc) {
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
        distanceRemainingMeters: distance,
        hasArrived: distance < 50, // 50 meters
      );
    }

    state = state.copyWith(
      currentLocation: loc,
      speedKmh: speed,
      isMoving: loc.isMoving,
      isStationary: !loc.isMoving,
      locationHistory: [...state.locationHistory, loc],
      activeTrip: updatedTrip,
    );

    // Log location
    ref
        .watch(pluginLogsProvider.notifier)
        .logLocation(loc.latitude, loc.longitude, loc.speed, loc.odometer);
  }

  void _handleGeofence(GeofenceEvent event) {
    ref
        .watch(pluginLogsProvider.notifier)
        .logGeofence(event.identifier, event.action.name.toUpperCase());

    if (state.activeTrip?.tripId != event.identifier) return;

    state = state.copyWith(
      activeTrip: state.activeTrip?.copyWith(
        isWithinGeofence: event.action == GeofenceAction.enter,
      ),
    );
  }

  Future<void> startTrip({
    required double sourceLat,
    required double sourceLng,
    required double destinationLat,
    required double destinationLng,
    required String name,
    String? captainId,
    String? rideId,
    double geofenceRadius = 200.0,
    bool reset = true,
  }) async {
    if (state.isLoading || state.activeTrip != null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (!state.isServiceEnabled) {
        final config = _buildAdvancedConfig(reset: reset);
        await _manager.initialize(config);
        state = state.copyWith(isServiceEnabled: true);
      }

      _manager.updateCaptainInfo(
        captainId: captainId,
        rideId: rideId,
        tripStatus: "ON_TRIP",
      );

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

      await _manager.setStationGeofences([
        {
          'id': tripId,
          'lat': destinationLat,
          'lng': destinationLng,
          'radius': geofenceRadius,
        },
      ]);

      await _manager.start();

      ref.watch(pluginLogsProvider.notifier).logInfo("Trip started: $tripId");
    } catch (e) {
      ref
          .watch(pluginLogsProvider.notifier)
          .logError("Start Trip Failed", error: e);
      state = state.copyWith(isLoading: false, error: "Start Failed: $e");
    }
  }

  Future<void> stopTrip() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // 1. Stop the background geolocation service
      await _manager.stop();

      // 2. Update captain info to IDLE
      _manager.updateCaptainInfo(tripStatus: "IDLE");

      // 3. Fully reset the state
      state = state.copyWith(
        isLoading: false,
        clearActiveTrip: true, // Use the new flag to properly clear the trip
        isServiceEnabled: false,
        isMoving: false,
        isStationary: true,
        speedKmh: 0.0,
      );

      ref.watch(pluginLogsProvider.notifier).logInfo("Trip stopped");
    } catch (e) {
      ref
          .watch(pluginLogsProvider.notifier)
          .logError("Stop Trip Failed", error: e);
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
}
