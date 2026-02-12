import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/location_event.dart';
import 'i_tracking_transport.dart';
import 'location_payload_builder.dart';
import 'location_service_config.dart';

class SocketSyncService {
  final ITrackingTransport _transport;
  LocationServiceConfig _config = LocationServiceConfig();
  StreamSubscription<LocationEvent>? _subscription;

  SocketSyncService(this._transport);

  void updateConfig(LocationServiceConfig config) {
    _config = config;
  }

  void startListening(Stream<LocationEvent> eventStream) {
    _subscription?.cancel();
    _subscription = eventStream.listen(_handleEvent);
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _handleEvent(LocationEvent event) async {
    if (event is LocationUpdated) {
      await _sendLocation(event);
    } else if (event is GeofenceTriggered) {
      await _transport.sendStationEntryAlert(event.geofence.identifier);
    }
  }

  Future<void> _sendLocation(LocationUpdated event) async {
    final List<ConnectivityResult> connectivity = await Connectivity().checkConnectivity();
    final deviceName = Platform.isAndroid ? "Android" : "iOS";

    final payload = LocationPayloadBuilder()
        .setLocationRaw(
          lat: event.location.latitude,
          lng: event.location.longitude,
          speed: event.location.speed,
          odometer: event.location.odometer,
          timestamp: event.location.timestamp,
        )
        .setCaptainInfo(
          captainId: _config.captainId ?? "UNKNOWN",
          rideId: _config.rideId ?? "IDLE",
          tripStatus: _config.tripStatus ?? "IDLE",
        )
        .setDeviceInfo(
          deviceName: deviceName,
          batteryLevel: event.location.batteryLevel,
        )
        .setNetworkInfo(
          isOnline: !connectivity.contains(ConnectivityResult.none),
          connectionType: connectivity.isNotEmpty ? connectivity.first.toString().split('.').last : "none",
        )
        .build();

    await _transport.sendLocation(payload);
  }
}
