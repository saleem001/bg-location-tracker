/// Station info for auto arrival geofences
class Station {
  final String id;
  final double latitude;
  final double longitude;
  final double radius;
  final bool notifyOnEntry;
  final bool notifyOnExit;

  const Station({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.radius = 200.0, // default radius
    this.notifyOnEntry = true, // default notification on entry
    this.notifyOnExit = false, // default notification on exit
  });
}