import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/framework.dart';
import 'package:track_me/features/tracking/data/datasources/location_plugin_configs.dart';
import '../../../../common/utils/scope_functions.dart';
import '../providers/tracking_providers.dart';
import '../states/location_app_state.dart';
import '../states/location_state.dart';

import '../../domain/entities/geofence_event.dart';
import '../../domain/entities/tracking_event.dart';
import '../../domain/entities/location_event.dart';
import '../../data/datasources/location_service_manager.dart';
import '../../data/datasources/socket_sync_service.dart';
import '../../data/datasources/location_service_config.dart';
import '../../../../common/utils/location_utils.dart';
import '../../presentation/providers/plugin_logs_provider.dart';

class LocationTrackerViewModel extends Notifier<LocationState> {
  @override
  LocationState build() {
    // Ensure Sync Service is active
    ref.read(socketSyncServiceProvider);
    ref.read(geofenceNotificationHandlerProvider);

    ref.listen<LocationAppState>(locationStateNotifierProvider, (
      previous,
      next,
    ) {
      _handleStateChange(previous, next);
    });

    return LocationState.initial();
  }

  // Helper to get providers
  BackgroundLocationServiceManager get _manager =>
      ref.read(backgroundLocationServiceManagerProvider);

  void _handleStateChange(LocationAppState? previous, LocationAppState next) {
    if (previous?.location != next.location && next.location != null) {
      next.location?.let((location) {
        _processLocation(location, location.isMoving);
      });
    }

    if (previous?.geofence != next.geofence && next.geofence != null) {
      next.geofence?.let((geofence) {
        _handleGeofence(geofence.identifier, geofence.action);
      });
    }

    if (previous?.motion != next.motion) {
      next.motion?.let((motion) {
        _processLocation(motion.location, motion.isMoving);
      });
    }

    if (previous?.isServiceEnabled != next.isServiceEnabled) {
      _handleServiceEnableChange(next.isServiceEnabled);
    }
  }

  void _processLocation(LocationTrackingEvent trackingEvent, bool isMoving) {
    final speed = LocationUtils.msToKmh(trackingEvent.speed);
    TripState? updatedTrip = state.activeTrip;

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

    state = state.copyWith(
      currentLocation: trackingEvent,
      speedKmh: speed,
      isMoving: isMoving,
      isStationary: !isMoving,
      locationHistory: [...state.locationHistory, trackingEvent],
      activeTrip: updatedTrip,
    );

    // Log location
    ref
        .watch(pluginLogsProvider.notifier)
        .logLocation(
          trackingEvent.latitude,
          trackingEvent.longitude,
          trackingEvent.speed,
          trackingEvent.odometer,
        );
  }

  void _handleGeofence(String identifier, GeofenceAction action) {
    if (state.activeTrip == null) return;

    final updatedGeofences = state.activeTrip!.geofences.map((g) {
      if (g.id == identifier) {
        final bool isInside = action == GeofenceAction.enter;
        return g.copyWith(
          isInside: isInside,
          status: isInside ? GeofenceStatus.arrived : GeofenceStatus.departed,
        );
      }
      return g;
    }).toList();

    state = state.copyWith(
      activeTrip: state.activeTrip!.copyWith(geofences: updatedGeofences),
    );
  }

  void _handleServiceEnableChange(bool isServiceEnabled) {
    state = state.copyWith(isServiceEnabled: isServiceEnabled);
  }

  Future<void> startTrip({
    required double sourceLat,
    required double sourceLng,
    required List<Station> stations,
    String? captainId,
    String? rideId,
    bool reset = true,
  }) async {
    if (state.isLoading || state.activeTrip != null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Simulate 2 seconds of processing/loading as requested
      await Future.delayed(const Duration(seconds: 2));

      if (!state.isServiceEnabled) {
        final config = _buildAdvancedConfig(reset: reset);
        await _manager
            .addOnLocation()
            // .addOnGeofence(stations)
            // .addOnServiceStatusChange()
            // .addOnMotionChange()
            .initialize(config)
            .then((manager) => manager.start());
        state = state.copyWith(isServiceEnabled: true);
      }

      // _syncService.updateConfig(
      //   LocationServiceConfig(
      //     captainId: captainId,
      //     rideId: rideId,
      //     tripStatus: "ON_TRIP",
      //   ),
      // );

      final tripId = "trip_${DateTime.now().millisecondsSinceEpoch}";

      final newTrip = TripState.newTrip(
        tripId: tripId,
        sourceLat: sourceLat,
        sourceLng: sourceLng,
        geofences: stations,
        captainId: captainId,
        rideId: rideId,
      );

      state = state.copyWith(isLoading: false, activeTrip: newTrip);

      await _manager.start();

      ref
          .watch(pluginLogsProvider.notifier)
          .logInfo("Trip started with ${stations.length} geofences");
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
      // _syncService.updateConfig(LocationServiceConfig(tripStatus: "IDLE"));

      // 3. Fully reset the state
      state = state.copyWith(
        isLoading: false,
        clearActiveTrip: true,
        // Use the new flag to properly clear the trip
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
