import 'package:bg_location_tracker/features/tracking/domain/entities/tracking_event.dart';
import 'geofence_event.dart';
import 'location_service_status.dart';

sealed class LocationEvent {
  const LocationEvent();
}

class LocationUpdated extends LocationEvent {
  final LocationTrackingEvent location;
  const LocationUpdated(this.location);
}

class GeofenceTriggered extends LocationEvent {
  final GeofenceEvent geofence;
  const GeofenceTriggered(this.geofence);
}

class MotionChanged extends LocationEvent {
  final MotionChangeEvent motion;
  const MotionChanged(this.motion);
}

class ServiceStatusChanged extends LocationEvent {
  final LocationServiceStatus status;
  const ServiceStatusChanged(this.status);
}

class ServiceEnabledChanged extends LocationEvent {
  final bool isEnabled;
  const ServiceEnabledChanged(this.isEnabled);
}
