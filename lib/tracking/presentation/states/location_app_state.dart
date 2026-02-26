import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/geofence_event.dart';
import '../../domain/entities/location_service_status.dart';
import '../../domain/entities/tracking_event.dart';
import '../../domain/entities/location_state.dart';
// import 'location_state.dart';

part 'location_app_state.freezed.dart';

@freezed
abstract class LocationAppState with _$LocationAppState {
  const factory LocationAppState({
    LocationTrackingEvent? location,
    MotionChangeEvent? motion,
    GeofenceEvent? geofence,
    LocationServiceStatusEvent? serviceStatus,
  }) = _LocationAppState;

  factory LocationAppState.initial() => const LocationAppState();
}
