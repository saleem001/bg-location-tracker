import '../../domain/entities/tracking_event.dart';

enum GeofenceStatus { none, arrived, departed }

class Station {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isInside;
  final double distanceMeters;
  final GeofenceStatus status;
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
    this.status = GeofenceStatus.none,
  });

  Station copyWith({
    bool? isInside,
    double? distanceMeters,
    GeofenceStatus? status,
  }) =>
      Station(
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

class TripState {
  final String tripId;
  final double sourceLat;
  final double sourceLng;
  final List<Station> geofences;
  final double distanceRemainingMeters; // To nearest geofence maybe? Or first one?
  final bool hasArrived;
  final DateTime? startedAt;
  final String? captainId;
  final String? rideId;

  TripState({
    required this.tripId,
    required this.sourceLat,
    required this.sourceLng,
    required this.geofences,
    this.distanceRemainingMeters = 0.0,
    this.hasArrived = false,
    this.startedAt,
    this.captainId,
    this.rideId,
  });

  factory TripState.newTrip({
    required String tripId,
    required double sourceLat,
    required double sourceLng,
    required List<Station> geofences,
    String? captainId,
    String? rideId,
  }) =>
      TripState(
        tripId: tripId,
        sourceLat: sourceLat,
        sourceLng: sourceLng,
        geofences: geofences,
        startedAt: DateTime.now(),
        captainId: captainId,
        rideId: rideId,
      );

  TripState copyWith({
    List<Station>? geofences,
    double? distanceRemainingMeters,
    bool? hasArrived,
    String? captainId,
    String? rideId,
  }) =>
      TripState(
        tripId: tripId,
        sourceLat: sourceLat,
        sourceLng: sourceLng,
        geofences: geofences ?? this.geofences,
        distanceRemainingMeters:
            distanceRemainingMeters ?? this.distanceRemainingMeters,
        hasArrived: hasArrived ?? this.hasArrived,
        startedAt: startedAt,
        captainId: captainId ?? this.captainId,
        rideId: rideId ?? this.rideId,
      );

  // Helper getters for backward compatibility or UI convenience
  bool get isWithinAnyGeofence => geofences.any((g) => g.isInside);
  
  // For UI that expects a single destination (we'll use the first one as primary for now or logic can be updated)
  double get destinationLat => geofences.isNotEmpty ? geofences.first.latitude : 0.0;
  double get destinationLng => geofences.isNotEmpty ? geofences.first.longitude : 0.0;
  String get destinationName => geofences.isNotEmpty ? geofences.first.name : "None";
  double get geofenceRadius => geofences.isNotEmpty ? geofences.first.radius : 0.0;
  bool get isWithinGeofence => isWithinAnyGeofence;
}

class LocationState {
  final bool isServiceEnabled;
  final bool isStationary;
  final bool isMoving;
  final bool isLoading;
  final TripState? activeTrip;

  final LocationTrackingEvent? currentLocation;
  final List<LocationTrackingEvent> locationHistory;
  final double speedKmh;

  final LocationTrackingEvent? pendingDestination;
  final String? lastActivity;
  final String? error;

  LocationState({
    this.isServiceEnabled = false,
    this.isStationary = false,
    this.isMoving = false,
    this.isLoading = false,
    this.activeTrip,
    this.currentLocation,
    this.locationHistory = const [],
    this.speedKmh = 0.0,
    this.pendingDestination,
    this.lastActivity,
    this.error,
  });

  factory LocationState.initial() => LocationState();

  LocationState copyWith({
    bool? isServiceEnabled,
    bool? isStationary,
    bool? isMoving,
    bool? isLoading,
    TripState? activeTrip,
    LocationTrackingEvent? currentLocation,
    List<LocationTrackingEvent>? locationHistory,
    double? speedKmh,
    LocationTrackingEvent? pendingDestination,
    String? lastActivity,
    String? error,
    bool clearActiveTrip = false,
    bool clearError = false, // Added flag to clear the error
  }) => LocationState(
    isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
    isStationary: isStationary ?? this.isStationary,
    isMoving: isMoving ?? this.isMoving,
    isLoading: isLoading ?? this.isLoading,
    activeTrip: clearActiveTrip ? null : (activeTrip ?? this.activeTrip),
    currentLocation: currentLocation ?? this.currentLocation,
    locationHistory: locationHistory ?? this.locationHistory,
    speedKmh: speedKmh ?? this.speedKmh,
    pendingDestination: pendingDestination ?? this.pendingDestination,
    lastActivity: lastActivity ?? this.lastActivity,
    error: clearError ? null : (error ?? this.error),
  );
}
