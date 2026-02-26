import 'geofence_event.dart';
import 'tracking_event.dart';

class Station {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isInside;
  final double distanceMeters;
  final GeofenceAction status;
  final bool notifyOnEntry;
  final bool notifyOnExit;

  Station({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radius = 200.0, // default radius
    this.isInside = false,
    this.distanceMeters = 0.0,
    this.notifyOnEntry = true, // default notification on entry
    this.notifyOnExit = true, // default notification on exi
    this.status = GeofenceAction.none,
  });

  Station copyWith({
    bool? isInside,
    double? distanceMeters,
    GeofenceAction? status,
  }) => Station(
    id: id,
    name: name,
    latitude: latitude,
    longitude: longitude,
    radius: radius,
    isInside: isInside ?? this.isInside,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    status: status ?? this.status,
  );
}
