import 'location_models.dart';

enum RouteStopStatus { pending, arrivingSoon, arrived }

class RouteStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final RouteStopStatus status;
  final DateTime? arrivalTime;

  RouteStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.status = RouteStopStatus.pending,
    this.arrivalTime,
  });

  RouteStop copyWith({RouteStopStatus? status, DateTime? arrivalTime}) =>
      RouteStop(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        status: status ?? this.status,
        arrivalTime: arrivalTime ?? this.arrivalTime,
      );
}

class TripState {
  final String tripId;
  final double destinationLat;
  final double destinationLng;
  final String destinationName;
  final List<RouteStop> stops;
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
    this.stops = const [],
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
    List<RouteStop> stops = const [],
  }) => TripState(
    tripId: tripId,
    destinationLat: destinationLat,
    destinationLng: destinationLng,
    destinationName: destinationName,
    stops: stops,
    startedAt: DateTime.now(),
  );

  TripState copyWith({
    List<RouteStop>? stops,
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
    stops: stops ?? this.stops,
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
