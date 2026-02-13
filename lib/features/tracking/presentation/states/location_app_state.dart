import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/geofence_event.dart';
import '../../domain/entities/location_service_status.dart';
import '../../domain/entities/tracking_event.dart';
import 'location_state.dart';
// import 'location_state.dart';

part 'location_app_state.freezed.dart';

@freezed
abstract class LocationAppState with _$LocationAppState {
  const factory LocationAppState({
    LocationTrackingEvent? location,
    MotionChangeEvent? motion,
    GeofenceEvent? geofence,
    LocationServiceStatus? serviceStatus,

    // Service & motion
    @Default(false) bool isServiceEnabled,
    @Default(true) bool isStationary,
    @Default(false) bool isMoving,
    @Default(false) bool isLoading,

    // Trip info
    TripState? activeTrip,

    // Current location tracking
    LocationTrackingEvent? currentLocation,
    @Default([]) List<LocationTrackingEvent> locationHistory,
    @Default(0.0) double speedKmh,

    // Misc
    LocationTrackingEvent? pendingDestination,
    String? lastActivity,
    String? error,
  }) = _LocationAppState;

  factory LocationAppState.initial() => const LocationAppState();
}
