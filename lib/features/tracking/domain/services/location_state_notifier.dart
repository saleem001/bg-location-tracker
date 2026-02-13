import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import '../../domain/entities/tracking_event.dart';
import '../../domain/entities/geofence_event.dart';
import '../../domain/entities/location_service_status.dart';
import '../../presentation/states/location_app_state.dart';
import '../entities/location_event.dart';

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationStateNotifier extends StateNotifier<LocationAppState> {
  final Stream<LocationEvent> events;
  StreamSubscription<LocationEvent>? _sub;

  LocationStateNotifier(this.events) : super(LocationAppState.initial()) {
    // Subscribe to the unified aggregator stream
    _sub = events.listen(_handleEvent);
  }

  void _handleEvent(LocationEvent event) {
    // Using `when` from freezed for pattern matching
    event.when(
      locationUpdated: (location) {
        final speedInMps = location.speed ?? 0.0;
        final speedInKmh = speedInMps * 3.6;

        final updatedHistory = [...state.locationHistory, location];

        state = state.copyWith(
          location: location,
          currentLocation: location,
          speedKmh: speedInKmh,
          isMoving: location.isMoving,
          isStationary: !location.isMoving,
          locationHistory: updatedHistory,
        );
      },
      geofenceTriggered: (geofence) {
        state = state.copyWith(geofence: geofence);
      },
      motionChanged: (motion) {
        state = state.copyWith(
          motion: motion,
          isMoving: motion.isMoving,
          isStationary: !motion.isMoving,
        );
      },
      serviceStatusChanged: (status) {
        state = state.copyWith(serviceStatus: status);
      },
      serviceEnabledChanged: (isEnabled) {
        state = state.copyWith(isServiceEnabled: isEnabled);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
