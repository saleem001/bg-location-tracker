import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:track_me/features/tracking/domain/entities/tracking_event.dart';

import 'geofence_event.dart';
import 'location_service_status.dart';

part 'location_event.freezed.dart';

@freezed
class LocationEvent with _$LocationEvent {
  const factory LocationEvent.locationUpdated(LocationTrackingEvent location) =
      _LocationUpdated;

  const factory LocationEvent.geofenceTriggered(GeofenceEvent geofence) =
      _GeofenceTriggered;

  const factory LocationEvent.motionChanged(MotionChangeEvent motion) =
      _MotionChanged;

  const factory LocationEvent.serviceStatusChanged(
    LocationServiceStatus status,
  ) = _ServiceStatusChanged;

  const factory LocationEvent.serviceEnabledChanged(bool isEnabled) =
      _ServiceEnabledChanged;
}
