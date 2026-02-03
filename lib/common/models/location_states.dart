import 'tracking_events.dart';

class TripState {
  final String tripId;
  final double sourceLat;
  final double sourceLng;
  final double destinationLat;
  final double destinationLng;
  final String destinationName;
  final double distanceRemainingKm;
  final bool hasArrived;
  final bool isWithinGeofence;
  final double geofenceRadius;
  final DateTime? startedAt;
  final DateTime? arrivedAt;
  final DateTime? estimatedArrivalTime;

  TripState({
    required this.tripId,
    required this.sourceLat,
    required this.sourceLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
    this.distanceRemainingKm = 0.0,
    this.hasArrived = false,
    this.isWithinGeofence = false,
    this.geofenceRadius = 200.0,
    this.startedAt,
    this.arrivedAt,
    this.estimatedArrivalTime,
  });

  factory TripState.newTrip({
    required String tripId,
    required double sourceLat,
    required double sourceLng,
    required double destinationLat,
    required double destinationLng,
    required String destinationName,
    double geofenceRadius = 200.0,
  }) => TripState(
    tripId: tripId,
    sourceLat: sourceLat,
    sourceLng: sourceLng,
    destinationLat: destinationLat,
    destinationLng: destinationLng,
    destinationName: destinationName,
    geofenceRadius: geofenceRadius,
    startedAt: DateTime.now(),
  );

  TripState copyWith({
    double? distanceRemainingKm,
    bool? hasArrived,
    bool? isWithinGeofence,
    double? geofenceRadius,
    DateTime? arrivedAt,
    DateTime? estimatedArrivalTime,
  }) => TripState(
    tripId: tripId,
    sourceLat: sourceLat,
    sourceLng: sourceLng,
    destinationLat: destinationLat,
    destinationLng: destinationLng,
    destinationName: destinationName,
    distanceRemainingKm: distanceRemainingKm ?? this.distanceRemainingKm,
    hasArrived: hasArrived ?? this.hasArrived,
    isWithinGeofence: isWithinGeofence ?? this.isWithinGeofence,
    geofenceRadius: geofenceRadius ?? this.geofenceRadius,
    startedAt: startedAt,
    arrivedAt: arrivedAt ?? this.arrivedAt,
    estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
  );
}

class LocationState {
  final bool isServiceEnabled;
  final bool isStationary;
  final bool isMoving;
  final bool isLoading;
  final TripState? activeTrip;

  // Device-level tracking data
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
  }) => LocationState(
    isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
    isStationary: isStationary ?? this.isStationary,
    isMoving: isMoving ?? this.isMoving,
    isLoading: isLoading ?? this.isLoading,
    activeTrip: activeTrip ?? this.activeTrip,
    currentLocation: currentLocation ?? this.currentLocation,
    locationHistory: locationHistory ?? this.locationHistory,
    speedKmh: speedKmh ?? this.speedKmh,
    pendingDestination: pendingDestination ?? this.pendingDestination,
    lastActivity: lastActivity ?? this.lastActivity,
    error: error ?? this.error,
  );
}
