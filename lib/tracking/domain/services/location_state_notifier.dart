import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/states/location_app_state.dart';
import '../entities/geofence_event.dart';
import '../entities/location_event.dart';
import '../entities/location_service_status.dart';
import '../entities/tracking_event.dart';

class LocationStateNotifier extends StateNotifier<LocationAppState> {
  final Stream<LocationEvent> events;
  StreamSubscription<LocationEvent>? _sub;

  LocationStateNotifier(this.events) : super(LocationAppState.initial()) {
    _sub = events.listen(_handleEvent);
  }

  void _handleEvent(LocationEvent event) {
    event.when(
      locationUpdated: (rawLocation) {
        final location = LocationTrackingEventMapper().map(rawLocation);
        final speedInKmh = location.speed * 3.6;

        state = state.copyWith(
          location: location,
        );
      },
      geofenceTriggered: (rawGeofence) {
        final geofence = GeofenceEventMapper().map(rawGeofence);
        state = state.copyWith(geofence: geofence);
      },
      motionChanged: (rawMotion) {
        final motion = MotionChangeEventMapper().map(rawMotion);
        state = state.copyWith(
          motion: motion
        );
      },
      serviceStatusChanged: (rawStatus) {
        final status = LocationServiceStatusMapper().map(rawStatus);
        state = state.copyWith(serviceStatus: status);
      },
      serviceEnabledChanged: (isEnabled) {
        //update service enable
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
