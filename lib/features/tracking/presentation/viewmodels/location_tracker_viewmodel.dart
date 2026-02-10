import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tracking_providers.dart';
import '../states/location_state.dart';
import '../../domain/entities/tracking_event.dart';
import '../../domain/entities/location_event.dart';
import '../../data/datasources/location_service_manager.dart';
import '../../data/datasources/socket_sync_service.dart';
import '../../data/datasources/location_service_config.dart';
import '../../../../common/utils/location_utils.dart';

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
        trackingEvent.latitude,
        trackingEvent.longitude,
        updatedTrip.destinationLat,
        updatedTrip.destinationLng,
      );

      updatedTrip = updatedTrip.copyWith(
        distanceRemainingMeters: distance,
        hasArrived: distance < 50, // 50 meters
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
  }

  void _handleGeofence(String identifier, String action) {
    // The identifier is the full tripId (e.g., "trip_123:::StationName")
    if (state.activeTrip?.tripId != identifier) return;

    state = state.copyWith(
      activeTrip: state.activeTrip?.copyWith(
        isWithinGeofence: action == "ENTER",
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
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (!state.isServiceEnabled) {
        await _manager.initialize();
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
    } catch (e) {
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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Stop Failed: $e");
    }
  }
}
