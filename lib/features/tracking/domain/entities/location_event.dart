import 'location_service_status.dart';
import 'tracking_event.dart';
import 'geofence_event.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'geofence_event.dart';
import 'location_service_status.dart';

part 'location_event.freezed.dart';

@freezed
class LocationEvent with _$LocationEvent {
  const factory LocationEvent.locationUpdated({
    required LocationTrackingEvent location,
    required bool isMoving,
  }) = LocationUpdated;

  const factory LocationEvent.motionChanged({
    required MotionChangeEvent motion,
  }) = MotionChanged;

  const factory LocationEvent.geofenceTriggered({
    required GeofenceEvent geofence,
  }) = GeofenceTriggered;

  const factory LocationEvent.serviceStatusChanged({
    required LocationServiceStatus status,
  }) = ServiceStatusChanged;

  const factory LocationEvent.serviceEnabledChanged({
    required bool isEnabled,
  }) = ServiceEnabledChanged;
}
