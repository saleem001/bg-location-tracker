import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';
import '../states/location_state.dart';
import '../providers/tracking_providers.dart';
import '../../../../log_viewer.dart';
import 'package:flutter_map/flutter_map.dart';

class LocationDashboard extends ConsumerStatefulWidget {
  const LocationDashboard({super.key});

  @override
  ConsumerState<LocationDashboard> createState() => _LocationDashboardState();
}

// zeeshan latlong
String sourceLat = "34.740674";
String sourceLng = "72.361101";

class _LocationDashboardState extends ConsumerState<LocationDashboard> {
  final TextEditingController _destLatController = TextEditingController(text: "34.743282");
  final TextEditingController _destLngController = TextEditingController(text: "72.358245");
  final TextEditingController _destNameController = TextEditingController(text: "Station A");
  final MapController _mapController = MapController();

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
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(state),
            const SizedBox(height: 16),
            _buildTripInputs(),
            const SizedBox(height: 16),
            _buildActionButtons(state, viewModel),
            const SizedBox(height: 16),
            _buildTripInfo(state),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildMap(state),
            ),
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
            _buildStatusRow("Service", state.isServiceEnabled ? "Enabled" : "Disabled", 
                state.isServiceEnabled ? Colors.green : Colors.red),
            _buildStatusRow("Activity", state.isMoving ? "Moving" : "Stationary", 
                state.isMoving ? Colors.blue : Colors.orange),
            _buildStatusRow("Speed", "${state.speedKmh.toStringAsFixed(1)} km/h", Colors.white),
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
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTripInputs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Trip Destination", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _destNameController, decoration: const InputDecoration(labelText: "Name")),
            Row(
              children: [
                Expanded(child: TextField(controller: _destLatController, decoration: const InputDecoration(labelText: "Lat"))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _destLngController, decoration: const InputDecoration(labelText: "Lng"))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(LocationState state, dynamic viewModel) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: state.isLoading ? null : () => _handleStartTrip(viewModel),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text("Start Trip"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: (state.isLoading || state.activeTrip == null) ? null : () => viewModel.stopTrip(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Stop Trip"),
          ),
        ),
      ],
    );
  }

  Widget _buildTripInfo(LocationState state) {
    if (state.activeTrip == null) return const SizedBox();
    final trip = state.activeTrip!;
    final bool isArrived = trip.isWithinGeofence || trip.hasArrived;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isArrived ? Colors.green.shade900 : Colors.blueGrey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(isArrived ? Icons.check_circle : Icons.navigation, color: Colors.cyan, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.destinationName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        "Destination Station",
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${trip.distanceRemainingMeters.toStringAsFixed(0)}m",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                  ),
                ),
              ],
            ),
            if (isArrived) ...[
              const Divider(height: 24, color: Colors.white24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.stars, color: Colors.greenAccent),
                    SizedBox(width: 8),
                    Text(
                      "USER ARRIVED",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMap(LocationState state) {
    final currentLatLng = state.currentLocation != null 
        ? LatLng(state.currentLocation!.latitude, state.currentLocation!.longitude)
        : LatLng(double.parse(sourceLat), double.parse(sourceLng));

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: currentLatLng,
        initialZoom: 15,
      ),
      children: [
        TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
        if (state.activeTrip != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(state.activeTrip!.destinationLat, state.activeTrip!.destinationLng),
                radius: state.activeTrip!.geofenceRadius,
                useRadiusInMeter: true,
                color: Colors.cyan.withOpacity(0.2),
                borderColor: Colors.cyan,
                borderStrokeWidth: 2,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: currentLatLng,
              width: 40,
              height: 40,
              child: const Icon(Icons.navigation, color: Colors.cyan, size: 40),
            ),
            if (state.activeTrip != null)
              Marker(
                point: LatLng(state.activeTrip!.destinationLat, state.activeTrip!.destinationLng),
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleStartTrip(dynamic viewModel) async {
    final status = await Permission.locationAlways.request();
    if (status.isGranted) {
      await viewModel.startTrip(
        sourceLat: double.parse(sourceLat),
        sourceLng: double.parse(sourceLng),
        destinationLat: double.parse(_destLatController.text),
        destinationLng: double.parse(_destLngController.text),
        name: _destNameController.text,
      );
    } else {
       Toast.show("Location Permission Required", duration: Toast.lengthLong);
    }
  }
}
