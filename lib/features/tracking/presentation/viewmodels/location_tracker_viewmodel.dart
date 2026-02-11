import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_me/features/tracking/data/datasources/location_plugin_configs.dart';
import '../providers/tracking_providers.dart';
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

    // Listen to the unified event stream from the aggregator
    ref.listen(locationEventStreamProvider, (previous, next) {
      if (next.hasValue) {
        _handleUnifiedEvent(next.value!);
      }
    });

    return LocationState.initial();
  }

  // Helper to get providers
  BackgroundLocationServiceManager get _manager => ref.read(backgroundLocationServiceManagerProvider);
  SocketSyncService get _syncService => ref.read(socketSyncServiceProvider);

  void _handleUnifiedEvent(LocationEvent event) {
    switch (event) {
      case LocationUpdated(:final location, :final isMoving):
        _processLocation(location, isMoving);
      case MotionChanged(:final motion):
        _processLocation(motion.location, motion.isMoving);
      case GeofenceTriggered(:final geofence):
        _handleGeofence(geofence.identifier, geofence.action.name.toUpperCase());
    }
  }

  void _processLocation(LocationTrackingEvent trackingEvent, bool isMoving) {
    final speed = LocationUtils.msToKmh(trackingEvent.speed);
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
      isMoving: isMoving,
      isStationary: !isMoving,
      locationHistory: [...state.locationHistory, trackingEvent],
      activeTrip: updatedTrip,
    );

    // Log location
    ref
        .watch(pluginLogsProvider.notifier)
        .logLocation(loc.latitude, loc.longitude, loc.speed, loc.odometer);
  }

  void _handleGeofence(String identifier, String action) {
    // The identifier is the full tripId (e.g., "trip_123:::StationName")
    if (state.activeTrip?.tripId != identifier) return;

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
        await _manager
            .initLocationStream()
            .initStationGeofenceStream()
            .initServiceStatusStream()
            .initMotionStream()
            .initialize(config);
        state = state.copyWith(isServiceEnabled: true);
      }

      _manager.updateCaptainInfo(
        captainId: captainId,
        rideId: rideId,
        tripStatus: "ON_TRIP",
      );

      _syncService.updateConfig(LocationServiceConfig(
        captainId: captainId,
        rideId: rideId,
        tripStatus: "ON_TRIP",
      ));

      final tripId = "trip_${DateTime.now().millisecondsSinceEpoch}:::$name";

      final newTrip = TripState.newTrip(
        tripId: tripId,
        sourceLat: sourceLat,
        sourceLng: sourceLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        destinationName: name,
        geofenceRadius: geofenceRadius,
        captainId: captainId,
        rideId: rideId,
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
      _syncService.updateConfig(LocationServiceConfig(tripStatus: "IDLE"));
      
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
