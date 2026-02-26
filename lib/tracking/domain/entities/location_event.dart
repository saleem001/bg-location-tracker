import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:freezed_annotation/freezed_annotation.dart';
part 'location_event.freezed.dart';

@freezed
class LocationEvent with _$LocationEvent {
  const factory LocationEvent.locationUpdated(bg.Location location) =
      _LocationUpdated;

  const factory LocationEvent.geofenceTriggered(bg.GeofenceEvent geofence) =
      _GeofenceTriggered;

  const factory LocationEvent.motionChanged(bg.Location motion) =
      _MotionChanged;

  const factory LocationEvent.serviceStatusChanged(
    bg.ProviderChangeEvent status,
  ) = _ServiceStatusChanged;

  const factory LocationEvent.serviceEnabledChanged(bool isEnabled) =
      _ServiceEnabledChanged;
}
