import 'dart:async';
import 'package:track_me/features/tracking/domain/entities/geofence_event.dart';
import 'package:track_me/features/tracking/domain/entities/location_service_status.dart';
import 'package:track_me/features/tracking/domain/entities/tracking_event.dart';

class LocationServiceStreams {
  final Stream<GeofenceEvent> geofence;
  final Stream<LocationTrackingEvent> location;
  final Stream<LocationServiceStatus> serviceStatus;
  final Stream<MotionChangeEvent> motion;

  const LocationServiceStreams({
    required this.geofence,
    required this.location,
    required this.serviceStatus,
    required this.motion,
  });
}
