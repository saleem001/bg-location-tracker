import 'location_events.dart';

class TripState {
  final String tripId;
  final double destinationLat;
  final double destinationLng;
  final String destinationName;
  final LocationEntity? currentLocation;
  final List<LocationEntity> history;
  final double speedKmh;
  final double distanceRemainingKm;
  final bool isMoving;
  final bool isStationary;
  final bool hasArrived;
  final DateTime? startedAt;
  final DateTime? arrivedAt;

  TripState({
    required this.tripId,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
    this.currentLocation,
    this.history = const [],
    this.speedKmh = 0.0,
    this.distanceRemainingKm = 0.0,
    this.isMoving = false,
    this.isStationary = false,
    this.hasArrived = false,
    this.startedAt,
    this.arrivedAt,
  });

  factory TripState.newTrip({
    required String tripId,
    required double destinationLat,
    required double destinationLng,
    required String destinationName,
  }) => TripState(
    tripId: tripId,
    destinationLat: destinationLat,
    destinationLng: destinationLng,
    destinationName: destinationName,
    startedAt: DateTime.now(),
  );

  TripState copyWith({
    LocationEntity? currentLocation,
    List<LocationEntity>? history,
    double? speedKmh,
    double? distanceRemainingKm,
    bool? isMoving,
    bool? isStationary,
    bool? hasArrived,
    DateTime? arrivedAt,
  }) => TripState(
    tripId: tripId,
    destinationLat: destinationLat,
    destinationLng: destinationLng,
    destinationName: destinationName,
    currentLocation: currentLocation ?? this.currentLocation,
    history: history ?? this.history,
    speedKmh: speedKmh ?? this.speedKmh,
    distanceRemainingKm: distanceRemainingKm ?? this.distanceRemainingKm,
    isMoving: isMoving ?? this.isMoving,
    isStationary: isStationary ?? this.isStationary,
    hasArrived: hasArrived ?? this.hasArrived,
    startedAt: startedAt,
    arrivedAt: arrivedAt ?? this.arrivedAt,
  );
}

class LocationState {
  final bool isServiceEnabled;
  final bool isStationary;
  final bool isLoading;
  final TripState? activeTrip;
  final List<LocationEntity> locationHistory;
  final LocationEntity? pendingDestination;
  final String? lastActivity;
  final String? error;

  LocationState({
    this.isServiceEnabled = false,
    this.isStationary = false,
    this.isLoading = false,
    this.activeTrip,
    this.locationHistory = const [],
    this.pendingDestination,
    this.lastActivity,
    this.error,
  });

  factory LocationState.initial() => LocationState();

  LocationState copyWith({
    bool? isServiceEnabled,
    bool? isStationary,
    bool? isLoading,
    TripState? activeTrip,
    List<LocationEntity>? locationHistory,
    LocationEntity? pendingDestination,
    String? lastActivity,
    String? error,
  }) => LocationState(
    isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
    isStationary: isStationary ?? this.isStationary,
    isLoading: isLoading ?? this.isLoading,
    activeTrip: activeTrip ?? this.activeTrip,
    locationHistory: locationHistory ?? this.locationHistory,
    pendingDestination: pendingDestination ?? this.pendingDestination,
    lastActivity: lastActivity ?? this.lastActivity,
    error: error ?? this.error,
  );
}
