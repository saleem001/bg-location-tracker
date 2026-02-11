import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:track_me/features/tracking/domain/entities/tracking_event.dart';
import 'package:track_me/features/tracking/data/datasources/i_tracking_transport.dart';
import 'package:track_me/features/tracking/data/datasources/location_payload_builder.dart';
import 'package:track_me/features/tracking/presentation/providers/tracking_providers.dart';
import 'package:track_me/features/tracking/presentation/providers/plugin_logs_provider.dart';

/// Service responsible for listening to location updates and sending them to the transport layer.
/// This acts as the bridge between the BackgroundLocationServiceManager (Provider) and the Transport (Socket).
class LocationUpdateService {
  final Ref _ref;
  final ITrackingTransport _transport;

  LocationUpdateService(this._ref, this._transport) {
    _init();
  }

  void _init() {
    // Listen to location stream
    _ref.listen(locationStreamProvider, (previous, next) {
      if (next.hasValue) {
        _handleLocationUpdate(next.value!);
      }
    });

    // Listen to motion stream?
    // Motion events usually come with a location location, so we might want to handle them too.
    // However, the location stream usually emits on motion changes too if configured.
    // We'll stick to locationStream for now to avoid duplicates.
  }

  Future<void> _handleLocationUpdate(LocationTrackingEvent location) async {
    final state = _ref.read(locationTrackerViewModelProvider);
    final trip = state.activeTrip;

    final captainId = trip?.captainId ?? "UNKNOWN";
    final rideId = trip?.rideId ?? "IDLE";
    final tripStatus = trip != null ? "ON_TRIP" : "IDLE";

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    // connectivity_plus 6.0 returns List<ConnectivityResult>, older returns single.
    // Assuming compatible version or single result for simplicity, or using toString().
    final connectionType = connectivityResult.toString();
    final isOnline = connectivityResult != ConnectivityResult.none;

    try {
      final payload = LocationPayloadBuilder()
          .setLocationFromEvent(location)
          .setCaptainInfo(
            captainId: captainId,
            rideId: rideId,
            tripStatus: tripStatus,
          )
          .setDeviceInfo(batteryLevel: location.batteryLevel)
          .setNetworkInfo(isOnline: isOnline, connectionType: connectionType)
          .build();

      await _transport.sendLocation(payload);

      // Log success?
      // _ref.read(pluginLogsProvider.notifier).logInfo("Location sent: ${location.timestamp}");
    } catch (e) {
      _ref
          .read(pluginLogsProvider.notifier)
          .logError("Failed to send location", error: e);
    }
  }
}
