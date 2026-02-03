import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import 'package:track_me/common/models/location_states.dart';
import 'package:track_me/feature/presentation/viewmodel/location_tracker_viewmodel.dart';
import 'package:track_me/log_viewer.dart';
import 'package:flutter_map/flutter_map.dart';
class LocationDashboard extends ConsumerStatefulWidget {
  const LocationDashboard({super.key});

  @override
  ConsumerState<LocationDashboard> createState() => _LocationDashboardState();
}


class _LocationDashboardState extends ConsumerState<LocationDashboard> {
  final MapController _mapController = MapController();
  final TextEditingController _sourceLatController =
      TextEditingController(text: "34.740674");
  final TextEditingController _sourceLngController =
      TextEditingController(text: "72.361101");
  final TextEditingController _destLatController =
      TextEditingController(text: "34.749608");
  final TextEditingController _destLngController =
      TextEditingController(text: "72.357231");
  final TextEditingController _radiusController =
      TextEditingController(text: "200");

  @override
  void dispose() {
    _sourceLatController.dispose();
    _sourceLngController.dispose();
    _destLatController.dispose();
    _destLngController.dispose();
    _radiusController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationTrackerViewModelProvider);
    final notifier = ref.read(locationTrackerViewModelProvider.notifier);

    // Auto-center map on current location if trip is active
    if (state.activeTrip?.currentLocation != null) {
      final cur = state.activeTrip!.currentLocation!;
      _mapController.move(LatLng(cur.latitude, cur.longitude), 15);
    }
    // 34.740674, 72.361101
    //     34.749608, 72.357231
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
      body: Column(
        children: [
          // Upper Half: Map View
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(30.0444, 31.2357),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.track_me',
                    ),
                    if (state.activeTrip != null) ...[
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: LatLng(
                              state.activeTrip!.destinationLat,
                              state.activeTrip!.destinationLng,
                            ),
                            radius: state.activeTrip!.geofenceRadius,
                            useRadiusInMeter: true,
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderColor: Colors.blue,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          // Source Marker
                          Marker(
                            point: LatLng(
                              state.activeTrip!.sourceLat,
                              state.activeTrip!.sourceLng,
                            ),
                            width: 30,
                            height: 30,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 30,
                            ),
                          ),
                          // Destination Marker
                          Marker(
                            point: LatLng(
                              state.activeTrip!.destinationLat,
                              state.activeTrip!.destinationLng,
                            ),
                            width: 30,
                            height: 30,
                            child: const Icon(
                              Icons.flag,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                          // Current Location Marker
                          if (state.activeTrip!.currentLocation != null)
                            Marker(
                              point: LatLng(
                                state.activeTrip!.currentLocation!.latitude,
                                state.activeTrip!.currentLocation!.longitude,
                              ),
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.navigation,
                                color: Colors.blue,
                                size: 30,
                              ),
                            ),
                        ],
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              LatLng(
                                state.activeTrip!.sourceLat,
                                state.activeTrip!.sourceLng,
                              ),
                              ...state.activeTrip!.history.map(
                                (l) => LatLng(l.latitude, l.longitude),
                              ),
                            ],
                            color: Colors.blueAccent,
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                if (state.activeTrip?.isWithinGeofence == true)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "AUTO ARRIVAL: You are within ${state.activeTrip!.geofenceRadius.toInt()}m of destination!",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    onPressed: () {
                      if (state.activeTrip?.currentLocation != null) {
                        final cur = state.activeTrip!.currentLocation!;
                        _mapController.move(
                          LatLng(cur.latitude, cur.longitude),
                          15,
                        );
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          // Lower Half: Controls & Info
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (state.activeTrip != null)
                    _buildTripCard(state.activeTrip!, state, notifier),
                    _buildInputFields(),
                    // const SizedBox(height: 16),
                    // _buildIdleCard(),
                  const SizedBox(height: 16),
                  if (state.activeTrip == null)
                    ElevatedButton.icon(
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

                              final sLat =
                                  double.tryParse(_sourceLatController.text) ??
                                  0.0;
                              final sLng =
                                  double.tryParse(_sourceLngController.text) ??
                                  0.0;
                              final dLat =
                                  double.tryParse(_destLatController.text) ??
                                  0.0;
                              final dLng =
                                  double.tryParse(_destLngController.text) ??
                                  0.0;
                              final radius =
                                  double.tryParse(_radiusController.text) ??
                                  200.0;

                              await notifier.startTrip(
                                sourceLat: sLat,
                                sourceLng: sLng,
                                destinationLat: dLat,
                                destinationLng: dLng,
                                name: "Manual Trip",
                                geofenceRadius: radius,
                                reset: true,
                              );
                            },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("🚀 BEGIN TRIP TRACKING"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.green.shade900,
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildDebugInfo(context, state, notifier),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Card(
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text(
              "Trip Configuration",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _inputRow("Source", _sourceLatController, _sourceLngController),
            const SizedBox(height: 8),
            _inputRow("Destination", _destLatController, _destLngController),
            const SizedBox(height: 8),
            TextField(
              controller: _radiusController,
              decoration: const InputDecoration(
                labelText: "Geofence Radius (meters)",
                prefixIcon: Icon(Icons.radar),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputRow(
    String label,
    TextEditingController lat,
    TextEditingController lng,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: lat,
                decoration: const InputDecoration(hintText: "Lat"),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: lng,
                decoration: const InputDecoration(hintText: "Lng"),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
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
        side: BorderSide(
          color: trip.isWithinGeofence ? Colors.green : Colors.cyan.shade800,
          width: 2,
        ),
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
              "Status",
              trip.isWithinGeofence ? "ARRIVED (Proximal)" : "EN ROUTE",
              trip.isWithinGeofence ? Colors.green : Colors.blue,
            ),
            _row(
              "Geofence Radius",
              "${trip.geofenceRadius.toInt()}m",
              Colors.cyan,
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
        padding: EdgeInsets.all(24.0),
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
