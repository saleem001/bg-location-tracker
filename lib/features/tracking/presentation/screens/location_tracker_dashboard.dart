import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import '../states/location_state.dart';
import '../providers/tracking_providers.dart';
import '../../../../log_viewer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

class LocationDashboard extends ConsumerStatefulWidget {
  const LocationDashboard({super.key});

  @override
  ConsumerState<LocationDashboard> createState() => _LocationDashboardState();
}

class StationControllers {
  final TextEditingController name;
  final TextEditingController lat;
  final TextEditingController lng;

  StationControllers({String? initialName, String? initialLat, String? initialLng})
      : name = TextEditingController(text: initialName ?? ""),
        lat = TextEditingController(text: initialLat ?? ""),
        lng = TextEditingController(text: initialLng ?? "");

  void dispose() {
    name.dispose();
    lat.dispose();
    lng.dispose();
  }
}

class _LocationDashboardState extends ConsumerState<LocationDashboard> {
  final List<StationControllers> _stations = [
    StationControllers(
      initialName: "Stop & Shop",
      initialLat: "34.742949",
      initialLng: "72.359715",
    )
  ];
  //saidu chok 34.749598, 72.357232
  //DHQ hospital 34.758003, 72.357872
  //grassy ground 34.765879, 72.359467
  final MapController _mapController = MapController();

  @override
  void dispose() {
    for (var station in _stations) {
      station.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationTrackerViewModelProvider);
    final viewModel = ref.read(locationTrackerViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Tracker Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LogViewerScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(state),
            const SizedBox(height: 16),
            _buildTripInputs(state),
            const SizedBox(height: 16),
            _buildActionButtons(state, viewModel),
            const SizedBox(height: 16),
            _buildTripInfo(state),
            const SizedBox(height: 16),
            SizedBox(height: 300, child: _buildMap(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(LocationState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusRow(
              "Service",
              state.isServiceEnabled ? "Enabled" : "Disabled",
              state.isServiceEnabled ? Colors.green : Colors.red,
            ),
            _buildStatusRow(
              "Activity",
              state.isMoving ? "Moving" : "Stationary",
              state.isMoving ? Colors.blue : Colors.orange,
            ),
            _buildStatusRow(
              "Speed",
              "${state.speedKmh.toStringAsFixed(1)} km/h",
              Colors.white,
            ),
            if (state.error != null)
              Text(state.error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInputs(LocationState state) {
    return Column(
      children: [
        ..._stations.asMap().entries.map((entry) {
          final index = entry.key;
          final controllers = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Station ${index + 1}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (index > 0 && state.activeTrip == null)
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => setState(() => _stations.removeAt(index)),
                        ),
                    ],
                  ),
                  TextField(
                    controller: controllers.name,
                    enabled: state.activeTrip == null,
                    decoration: const InputDecoration(labelText: "Station Name"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controllers.lat,
                          enabled: state.activeTrip == null,
                          decoration: const InputDecoration(labelText: "Lat"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controllers.lng,
                          enabled: state.activeTrip == null,
                          decoration: const InputDecoration(labelText: "Lng"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        if (state.activeTrip == null)
          Center(
            child: IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green, size: 40),
              onPressed: () => setState(() => _stations.add(StationControllers())),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(LocationState state, dynamic viewModel) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            // Disable if loading OR if there's already an active trip
            onPressed: (state.isLoading || state.activeTrip != null)
                ? null
                : () => _handleStartTrip(viewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.green.withOpacity(0.5),
            ),
            child: state.isLoading && state.activeTrip == null
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text("Start Trip"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            // Disable if loading OR if there is NO active trip
            onPressed: (state.isLoading || state.activeTrip == null)
                ? null
                : () => viewModel.stopTrip(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.red.withOpacity(0.5),
            ),
            child: state.isLoading && state.activeTrip != null
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text("Stop Trip"),
          ),
        ),
      ],
    );
  }

  Widget _buildTripInfo(LocationState state) {
    if (state.activeTrip == null) return const SizedBox();
    final trip = state.activeTrip!;

    // Find if any station is currently arrived at
    final arrivedStations = trip.geofences.where((g) => g.isInside).toList();

    return Column(
      children: [
        ...trip.geofences.map((g) {
          final distanceStr = g.distanceMeters < 1000
              ? "${g.distanceMeters.toStringAsFixed(0)}m"
              : "${(g.distanceMeters / 1000).toStringAsFixed(2)}km";

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: g.isInside ? Colors.green.shade900 : Colors.blueGrey.shade900,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    g.isInside ? Icons.check_circle : Icons.location_on,
                    color: g.isInside ? Colors.greenAccent : Colors.cyan,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      g.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (g.status != GeofenceStatus.none)
                        Text(
                          g.status == GeofenceStatus.arrived
                              ? "Arrived"
                              : "Depart",
                          style: TextStyle(
                            color: g.status == GeofenceStatus.arrived
                                ? Colors.greenAccent
                                : Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      Text(
                        distanceStr,
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        if (arrivedStations.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars, color: Colors.greenAccent),
                const SizedBox(width: 8),
                Text(
                  "ARRIVED AT: ${arrivedStations.last.name}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMap(LocationState state) {
    final currentLatLng = state.currentLocation != null
        ? LatLng(
            state.currentLocation!.latitude,
            state.currentLocation!.longitude,
          )
        : const LatLng(
            34.740674,
            72.361101,
          ); // Fallback to a default if no location yet

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: currentLatLng, initialZoom: 15),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.track_me_test_project',
        ),
        if (state.activeTrip != null) ...[
          CircleLayer(
            circles: state.activeTrip!.geofences
                .map(
                  (g) => CircleMarker(
                    point: LatLng(g.latitude, g.longitude),
                    radius: g.radius,
                    useRadiusInMeter: true,
                    color: g.isInside
                        ? Colors.green.withOpacity(0.2)
                        : Colors.cyan.withOpacity(0.2),
                    borderColor: g.isInside ? Colors.green : Colors.cyan,
                    borderStrokeWidth: 2,
                  ),
                )
                .toList(),
          ),
          MarkerLayer(
            markers: state.activeTrip!.geofences
                .map(
                  (g) => Marker(
                    point: LatLng(g.latitude, g.longitude),
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.location_on,
                      color: g.isInside ? Colors.greenAccent : Colors.redAccent,
                      size: 40,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        MarkerLayer(
          markers: [
            Marker(
              point: currentLatLng,
              width: 40,
              height: 40,
              child: const Icon(Icons.navigation, color: Colors.cyan, size: 40),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleStartTrip(dynamic viewModel) async {
    // Validation
    for (int i = 0; i < _stations.length; i++) {
      final station = _stations[i];
      if (station.name.text.trim().isEmpty ||
          station.lat.text.trim().isEmpty ||
          station.lng.text.trim().isEmpty) {
        Toast.show(
          "Please fill all fields for Station ${i + 1}",
          duration: Toast.lengthLong,
        );
        return;
      }

      if (double.tryParse(station.lat.text) == null ||
          double.tryParse(station.lng.text) == null) {
        Toast.show(
          "Invalid Lat/Lng for Station ${i + 1}",
          duration: Toast.lengthLong,
        );
        return;
      }
    }

    final status = await Permission.locationAlways.request();
    if (status.isGranted) {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final List<Station> stations = _stations.map((s) {
        return Station(
          id: "trip_${DateTime.now().millisecondsSinceEpoch}",
          name: s.name.text.trim(),// assuming 'name' is unique
          latitude: double.parse(s.lat.text.replaceAll(' ', '')),
          longitude: double.parse(s.lng.text.replaceAll(' ', '')),
          radius: 300.0,
          notifyOnEntry: true, // default, can be customized per station
          notifyOnExit: true, // default, can be customized per station
        );
      }).toList();

      await viewModel.startTrip(
        sourceLat: position.latitude,
        sourceLng: position.longitude,
        stations: stations,
      );

      // Move camera to user current location
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0,
      );
    } else {
      Toast.show("Location Permission Required", duration: Toast.lengthLong);
    }
  }
}
