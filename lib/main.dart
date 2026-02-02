import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'common/services/location_manager.dart';
import 'log_viewer.dart';
import 'common/providers/location_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Register Headless Task (Crucial to be here for app-kill resilience)
  bg.BackgroundGeolocation.registerHeadlessTask(locationHeadlessTask);

  runApp(const ProviderScope(child: POCApp()));
}

class POCApp extends StatelessWidget {
  const POCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
      ),
      home: const LocationDashboard(),
    );
  }
}

class LocationDashboard extends ConsumerWidget {
  const LocationDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationServiceProvider);
    final service = ref.read(locationServiceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Swvl track me"),
        actions: [
          if (state.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(state, ref),
            const SizedBox(height: 16),
            if (state.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            if (state.activeTrip != null)
              _buildTripCard(state.activeTrip!, state, service)
            else ...[
              _buildDestinationSetup(state, service),
              const SizedBox(height: 16),
              _buildIdleCard(),
            ],
            const SizedBox(height: 24),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                            final config = _buildAdvancedConfig(reset: true);
                            final dest = state.pendingDestination;

                            // If user hasn't captured a custom destination, fallback to a local sample
                            final targetLat = dest?.latitude ?? 0.0;
                            final targetLng = dest?.longitude ?? 0.0;

                            // 1. Get actual current position as Source
                            final sourcePos = await service
                                .getCurrentPosition();
                            final startLat = sourcePos.latitude;
                            final startLng = sourcePos.longitude;

                            // 2. Interpolate 3 stops between source and destination (25%, 50%, 75%)
                            final List<RouteStop> stops = [];
                            for (int i = 1; i <= 3; i++) {
                              final fraction = i / 4.0;
                              stops.add(
                                RouteStop(
                                  id: "stop_$i",
                                  name:
                                      "Waypoint $i (${(fraction * 100).toInt()}%)",
                                  latitude:
                                      startLat +
                                      (targetLat - startLat) * fraction,
                                  longitude:
                                      startLng +
                                      (targetLng - startLng) * fraction,
                                ),
                              );
                            }

                            await service.startTrip(
                              lat: targetLat,
                              lng: targetLng,
                              name: "Multi-Stop Route",
                              config: config,
                              stops: stops,
                            );
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("🚀 BEGIN TRIP TRACKING"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      backgroundColor: Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDebugInfo(context, state, service),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationSetup(LocationState state, LocationService service) {
    return Card(
      color: Colors.cyan.shade900.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "DESTINATION SELECTOR",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (state.pendingDestination == null)
              const Text(
                "1. Move Emulator pin to destination\n2. Tap Capture button below",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 11),
              )
            else
              _row(
                "Target Loc",
                "${state.pendingDestination!.latitude.toStringAsFixed(6)}, ${state.pendingDestination!.longitude.toStringAsFixed(6)}",
                Colors.greenAccent,
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                final config = _buildAdvancedConfig(reset: false);
                service.captureDestination(config);
              },
              icon: const Icon(Icons.my_location),
              label: const Text("📍 SET DESTINATION FROM MAP PIN"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(
    TripState trip,
    LocationState state,
    LocationService service,
  ) {
    return Card(
      color: Colors.blueGrey.shade900,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.cyan.shade800, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.cyan),
                const SizedBox(width: 8),
                const Text(
                  "ACTIVE TRIP",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: state.isStationary ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    state.isStationary ? "STATIONARY" : "TRACKING",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            _row("Destination", trip.destinationName),
            _row(
              "Current Pos",
              trip.currentLocation != null
                  ? "${trip.currentLocation?.latitude.toStringAsFixed(6)}, ${trip.currentLocation?.longitude.toStringAsFixed(6)}"
                  : "WAITING FOR SIGNAL...",
              trip.currentLocation != null ? Colors.white : Colors.grey,
            ),
            _row(
              "Speed",
              "${trip.speedKmh.toStringAsFixed(1)} km/h",
              trip.isMoving ? Colors.green : Colors.orange,
            ),
            _row(
              "Odometer",
              "${((trip.currentLocation?.odometer ?? 0.0) / 1000.0).toStringAsFixed(2)} km",
              Colors.cyan,
            ),
            _row(
              "Status",
              trip.hasArrived ? "ARRIVED" : "EN ROUTE",
              trip.hasArrived ? Colors.green : Colors.blue,
            ),
            _row(
              "Points Collected",
              trip.history.length.toString(),
              Colors.grey,
            ),

            if (trip.stops.isNotEmpty) ...[
              const Divider(),
              const Text(
                "STOPS ON ROUTE",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...trip.stops.map((stop) {
                final isArrived = stop.status == RouteStopStatus.arrived;
                final isArriving = stop.status == RouteStopStatus.arrivingSoon;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        isArrived
                            ? Icons.check_circle
                            : (isArriving
                                  ? Icons.notifications_active
                                  : Icons.radio_button_unchecked),
                        size: 16,
                        color: isArrived
                            ? Colors.greenAccent
                            : (isArriving ? Colors.amber : Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: isArrived ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${stop.latitude.toStringAsFixed(5)}, ${stop.longitude.toStringAsFixed(5)}",
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.blueGrey,
                              ),
                            ),
                            if (isArriving)
                              const Text(
                                "ARRIVING SOON (1km)",
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isArrived && stop.arrivalTime != null)
                        Text(
                          "${stop.arrivalTime!.hour}:${stop.arrivalTime!.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.greenAccent,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => service.stopTrip(),
              icon: const Icon(Icons.stop),
              label: const Text("STOP TRIP"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(LocationState state, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<int>(
              future: ref
                  .read(locationManagerProvider)
                  .getAuthorizationStatus(),
              builder: (context, snapshot) {
                final status = snapshot.data;
                final statusLabel = status == 4
                    ? "ALWAYS"
                    : (status == 3 ? "WHEN IN USE" : "DENIED ($status)");
                return _row(
                  "OS Permission",
                  statusLabel,
                  status == 4
                      ? Colors.green
                      : (status == 3 ? Colors.orange : Colors.red),
                );
              },
            ),
            _row(
              "Hardware Plugin",
              state.isServiceEnabled ? "ONLINE (Tracking)" : "OFFLINE",
              state.isServiceEnabled ? Colors.green : Colors.redAccent,
            ),
            _row("Last Activity", state.lastActivity ?? "Unknown"),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfo(
    BuildContext context,
    LocationState state,
    LocationService service,
  ) {
    return Card(
      color: Colors.black45,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "System Logs",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                SizedBox(
                  height: 24,
                  width: 24,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.description,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LogViewerScreen(),
                        ),
                      );
                    },
                    tooltip: "View Logs",
                  ),
                ),
              ],
            ),
            _row(
              "Total Session Points",
              state.locationHistory.length.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(Icons.location_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No Active Trip",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  LocationManagerConfig _buildAdvancedConfig({required bool reset}) {
    return LocationManagerConfigBuilder()
        .setTracking(
          const TrackingPolicy(
            accuracy: 5,
            distanceFilter: 10,
            stopTimeout: 1,
            movementThreshold: 10,
          ),
        )
        .setSync(
          const DataSyncPolicy(
            autoSync: true,
            uploadUrl: "https://webhook.site/your-id",
          ),
        )
        .setPersistence(
          const PersistencePolicy(maxDaysToPersist: 1, persistMode: 2),
        )
        .setLifecycle(
          const LifecyclePolicy(stopOnTerminate: false, startOnBoot: true),
        )
        .setNotification(
          const NotificationPolicy(
            title: "Swvl Track Me",
            message: "Tracking your activity in background",
            permissionTitle: "Background Location Access",
            permissionMessage:
                "We need access to your location even when the app is closed.",
          ),
        )
        .setLogging(const LoggingPolicy(logLevel: 2, debug: true))
        .setReset(reset)
        .build();
  }
}
