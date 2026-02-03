import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import 'package:track_me/common/models/location_states.dart';
import 'package:track_me/feature/presentation/viewmodel/location_tracker_viewmodel.dart';
import 'package:track_me/log_viewer.dart';

class LocationDashboard extends ConsumerWidget {
  const LocationDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationTrackerViewModelProvider);
    final notifier = ref.read(locationTrackerViewModelProvider.notifier);

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
              _buildTripCard(state.activeTrip!, state, notifier)
            else ...[
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
                            if (await Permission.locationAlways.isGranted ==
                                false) {
                              Toast.show(
                                "Please allow all the time location permissions in settings",
                                duration: Toast.lengthLong,
                                gravity: Toast.bottom,
                              );
                              return;
                            }
                            final dest = state.pendingDestination;

                            // If user hasn't captured a custom destination, fallback to a local sample
                            final targetLat = dest?.latitude ?? 0.0;
                            final targetLng = dest?.longitude ?? 0.0;

                            await notifier.startTrip(
                              lat: targetLat,
                              lng: targetLng,
                              name: "Manual Trip",
                              reset: true,
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
            _buildDebugInfo(context, state, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(
    TripState trip,
    LocationState state,
    LocationTrackerViewModel notifier,
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

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => notifier.stopTrip(),
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

  Widget _buildDebugInfo(
    BuildContext context,
    LocationState state,
    LocationTrackerViewModel notifier,
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
}
