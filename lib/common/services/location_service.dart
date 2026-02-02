import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import '../models/location_models.dart';
import '../models/location_config.dart';
import '../models/trip_models.dart';
import 'location_manager.dart';

class LocationService extends StateNotifier<LocationState> {
  final LocationManager _manager;
  final List<StreamSubscription> _subs = [];

  LocationService(this._manager) : super(LocationState.initial()) {
    _initSubscribers();
    _autoInitialize();
  }

  Future<LocationEntity> getCurrentPosition() => _manager.getCurrentPosition();

  Future<void> _autoInitialize() async {
    // Check if we have permissions already
    final status = await _manager.getAuthorizationStatus();
    if (status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_ALWAYS ||
        status == bg.ProviderChangeEvent.AUTHORIZATION_STATUS_WHEN_IN_USE) {
      // Re-initialize WITHOUT overwriting config
      try {
        final enabled = await _manager.restoreState();

        // Restore trip from plugin 'extras'
        TripState? restoredTrip;
        final statePlugin = await bg.BackgroundGeolocation.state;
        final extras = statePlugin.extras;

        if (enabled && extras != null && extras['tripId'] != null) {
          final List<RouteStop> restoredStops = [];
          final stopsData = extras['stops'] as String? ?? "";
          if (stopsData.isNotEmpty) {
            for (var stopStr in stopsData.split('|')) {
              final parts = stopStr.split(':');
              if (parts.length >= 4) {
                final stopId = parts[0];
                restoredStops.add(
                  RouteStop(
                    id: stopId,
                    name: parts[1],
                    latitude: double.parse(parts[2]),
                    longitude: double.parse(parts[3]),
                    status: RouteStopStatus.values.firstWhere(
                      (e) =>
                          e.name ==
                          (extras['stop_status_$stopId'] ?? 'pending'),
                      orElse: () => RouteStopStatus.pending,
                    ),
                    arrivalTime: extras['stop_arrival_time_$stopId'] != null
                        ? DateTime.tryParse(extras['stop_arrival_time_$stopId'])
                        : null,
                  ),
                );
              }
            }
          }

          restoredTrip = TripState(
            tripId: extras['tripId'],
            destinationLat: extras['destinationLat'] ?? 0.0,
            destinationLng: extras['destinationLng'] ?? 0.0,
            destinationName: extras['destinationName'] ?? "",
            stops: restoredStops,
            startedAt: DateTime.tryParse(extras['startedAt'] ?? ""),
            isMoving: statePlugin.isMoving == true,
          );
        }

        state = state.copyWith(
          isLoading: false,
          isServiceEnabled: enabled,
          activeTrip: restoredTrip,
          lastActivity: enabled ? "Restored" : "Ready",
        );
      } catch (_) {}
    }
  }

  void _initSubscribers() {
    _subs.add(_manager.onLocation.listen(_handleLocation));
    _subs.add(_manager.onGeofence.listen(_handleGeofence));
    _subs.add(
      _manager.onActivity.listen((a) {
        state = state.copyWith(
          lastActivity: '${a.activity} (${a.confidence}%)',
        );
      }),
    );
    _subs.add(
      _manager.onMotionChange.listen((event) {
        final isMoving = event.isMoving;
        final loc = event.location;

        state = state.copyWith(
          isStationary: !isMoving,
          activeTrip: state.activeTrip?.copyWith(
            isMoving: isMoving,
            isStationary: !isMoving,
            currentLocation: loc,
            speedKmh: isMoving ? (state.activeTrip?.speedKmh ?? 0.0) : 0.0,
          ),
        );
      }),
    );
    _subs.add(
      _manager.onEnabledChange.listen(
        (enabled) => state = state.copyWith(isServiceEnabled: enabled),
      ),
    );
  }

  void _handleLocation(LocationEntity loc) {
    print("📍 RAW GPS SPEED: ${loc.speed} m/s");
    final speedKmh = loc.speed * 3.6;
    TripState? updatedTrip;

    if (state.activeTrip != null) {
      updatedTrip = state.activeTrip!.copyWith(
        currentLocation: loc,
        speedKmh: speedKmh > 0 ? speedKmh : 0,
        // Do not override isMoving/isStationary here; let onMotionChange handle the state machine
        isMoving: state.activeTrip!.isMoving,
        isStationary: state.activeTrip!.isStationary,
        history: [...state.activeTrip!.history, loc],
      );
    }

    state = state.copyWith(
      activeTrip: updatedTrip,
      locationHistory: [...state.locationHistory, loc],
    );
  }

  void _handleGeofence(GeofenceEvent event) {
    if (state.activeTrip == null) return;

    final id = event.identifier;
    final action = event.action;

    print("🔔 GEOFENCE EVENT: ${id} - ${action}");

    // Check if it's the main destination
    if (state.activeTrip!.tripId == id && action == 'ENTER') {
      state = state.copyWith(
        activeTrip: state.activeTrip!.copyWith(
          hasArrived: true,
          arrivedAt: DateTime.now(),
        ),
      );
      _manager.updateConfig({
        'hasArrived': true,
        'arrivedAt': DateTime.now().toIso8601String(),
      });
      return;
    }

    // Check if it's one of the stops (proximity or arrival)
    final parts = id.split("::");
    if (parts.length < 2) return;

    final stopId = parts[0];
    final type = parts[1]; // 'p' for proximity, 'a' for arrival

    final stopIndex = state.activeTrip!.stops.indexWhere((s) => s.id == stopId);
    if (stopIndex == -1) return;

    final stop = state.activeTrip!.stops[stopIndex];
    RouteStopStatus newStatus = stop.status;

    if (action == 'ENTER') {
      if (type == 'p' && stop.status == RouteStopStatus.pending) {
        newStatus = RouteStopStatus.arrivingSoon;
      } else if (type == 'a') {
        newStatus = RouteStopStatus.arrived;
      }
    }

    if (newStatus != stop.status) {
      final now = DateTime.now();
      final updatedStops = List<RouteStop>.from(state.activeTrip!.stops);
      updatedStops[stopIndex] = stop.copyWith(
        status: newStatus,
        arrivalTime: newStatus == RouteStopStatus.arrived
            ? now
            : stop.arrivalTime,
      );

      state = state.copyWith(
        activeTrip: state.activeTrip!.copyWith(stops: updatedStops),
      );

      // Persist stop status
      _manager.updateConfig({
        'stop_status_${stopId}': newStatus.name,
        if (newStatus == RouteStopStatus.arrived)
          'stop_arrival_time_${stopId}': now.toIso8601String(),
      });
    }
  }

  Future<void> initializeWithPermission(LocationManagerConfig config) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      lastActivity: "Initializing...",
    );
    try {
      // 1. Request Permission FIRST
      final status = await _manager.requestPermission();

      // 2. Initialize Hardware Plugin only if we have permissions
      // Note: status 3=WHEN_IN_USE, 4=ALWAYS
      if (status >= 3) {
        final enabled = await _manager.initialize(config);
        state = state.copyWith(
          isLoading: false,
          isServiceEnabled: enabled,
          pendingDestination: config.reset ? null : state.pendingDestination,
          lastActivity: "System Online",
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Permission Denied: Location access required.",
          lastActivity: "Auth Failed",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Setup Failed: ${e.toString()}",
        lastActivity: "Error",
      );
    }
  }

  Future<void> initialize(LocationManagerConfig config) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final enabled = await _manager.initialize(config);

      TripState? restoredTrip;
      final statePlugin = await bg.BackgroundGeolocation.state;
      final extras = statePlugin.extras;

      if (enabled && extras != null && extras['tripId'] != null) {
        restoredTrip = TripState(
          tripId: extras['tripId'],
          destinationLat: extras['destinationLat'],
          destinationLng: extras['destinationLng'],
          destinationName: extras['destinationName'],
          startedAt: DateTime.tryParse(extras['startedAt'] ?? ""),
          isMoving: statePlugin.isMoving == true,
        );
      }

      state = state.copyWith(
        isLoading: false,
        isServiceEnabled: enabled,
        activeTrip: restoredTrip,
        pendingDestination: config.reset ? null : state.pendingDestination,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Init Failed: ${e.toString()}",
      );
    }
  }

  Future<void> captureDestination(LocationManagerConfig config) async {
    state = state.copyWith(isLoading: true);
    try {
      if (!state.isServiceEnabled) {
        await initializeWithPermission(config);
      }
      final loc = await _manager.getCurrentPosition();
      state = state.copyWith(pendingDestination: loc, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: "Capture Failed: ${e.toString()}",
        isLoading: false,
      );
    }
  }

  Future<void> requestPermission() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _manager.requestPermission();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Permission Request Failed: ${e.toString()}",
      );
    }
  }

  Future<void> startTrip({
    required double lat,
    required double lng,
    required String name,
    required LocationManagerConfig config,
    List<RouteStop> stops = const [],
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (!state.isServiceEnabled) {
        await initializeWithPermission(config);
      }

      final currentPos = await _manager.getCurrentPosition();
      final tripId = "trip_${DateTime.now().millisecondsSinceEpoch}";

      // 1. Setup DUAL geofences for destination AND all stops
      await _manager.clearZones();

      // Destination geofence
      await _manager.setupArrivalZone(tripId, lat, lng, config.arrivalRadius);

      // Each stop gets two zones:
      // 1. Proximity (1km) -> 'Arriving Soon'
      // 2. Arrival (200m) -> 'Arrived'
      for (var stop in stops) {
        print(
          "📍 REGISTERING GEOFENCE: ${stop.name} (ID: ${stop.id}) at ${stop.latitude}, ${stop.longitude}",
        );
        // Proximity Zone
        await _manager.setupArrivalZone(
          "${stop.id}::p",
          stop.latitude,
          stop.longitude,
          1000,
        );
        // Arrival Zone
        await _manager.setupArrivalZone(
          "${stop.id}::a",
          stop.latitude,
          stop.longitude,
          200,
        );
      }

      // 2. Create state
      final newTrip = TripState.newTrip(
        tripId: tripId,
        destinationLat: lat,
        destinationLng: lng,
        destinationName: name,
        stops: stops,
      ).copyWith(currentLocation: currentPos);

      // 3. Persist trip config
      final stopsCsv = stops
          .map((s) => "${s.id}:${s.name}:${s.latitude}:${s.longitude}")
          .join('|');

      await _manager.updateConfig({
        'tripId': tripId,
        'destinationLat': lat,
        'destinationLng': lng,
        'destinationName': name,
        'stops': stopsCsv,
        'startedAt': newTrip.startedAt?.toIso8601String(),
        'hasArrived': false,
      });

      await _manager.startTracking();
      await _manager.changePace(true);

      state = state.copyWith(isLoading: false, activeTrip: newTrip);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Start Failed: ${e.toString()}",
      );
    }
  }

  Future<void> stopTrip() async {
    // Clear the persistent state in the plugin
    await _manager.updateConfig({});
    state = state.copyWith(activeTrip: null, locationHistory: []);
    await _manager.stopTracking();
    await _manager.clearZones();
  }

  Future<String> getNativeLogs() => _manager.getNativeLogs();
  Future<void> clearNativeLogs() => _manager.clearNativeLogs();

  @override
  void dispose() {
    for (var s in _subs) {
      s.cancel();
    }
    _manager.dispose();
    super.dispose();
  }
}
