import 'tracking_event.dart';
import 'geofence_event.dart';

sealed class LocationEvent {
  final DateTime timestamp;
  LocationEvent(this.timestamp);
}

class LocationUpdated extends LocationEvent {
  final LocationTrackingEvent location;
  final bool isMoving;

  LocationUpdated({
    required this.location,
    required this.isMoving,
  }) : super(location.timestamp);
}

class GeofenceTriggered extends LocationEvent {
  final GeofenceEvent geofence;

  GeofenceTriggered({
    required this.geofence,
  }) : super(DateTime.now());
}

class MotionChanged extends LocationEvent {
  final MotionChangeEvent motion;

  MotionChanged({
    required this.motion,
  }) : super(motion.location.timestamp);
}
