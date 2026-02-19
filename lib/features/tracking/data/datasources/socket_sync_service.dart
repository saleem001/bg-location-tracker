import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/location_event.dart';
import '../../domain/entities/tracking_event.dart';
import 'i_tracking_transport.dart';
import 'location_payload_builder.dart';
import 'location_service_config.dart';
import 'socket_tracking_transport.dart';
import 'location_event_aggregator.dart';

class SocketSyncService {
  static final SocketSyncService _instance = SocketSyncService._internal(SocketTrackingTransport());
  factory SocketSyncService() => _instance;
  SocketSyncService._internal(this._transport);

  final ITrackingTransport _transport;
  LocationServiceConfig _config = LocationServiceConfig();

  StreamSubscription<LocationEvent>? _subscription;

  void updateConfig(LocationServiceConfig config) {
    _config = config;
  }

  void start() {
    _subscription?.cancel();
    _subscription = LocationEventAggregator().events.listen(_handleEvent);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _handleEvent(LocationEvent event) async {
    if (event is LocationUpdated) {
      await _sendLocation(event.location);
    } else if (event is GeofenceTriggered) {
      await _transport.sendStationEntryAlert(event.geofence.identifier);
    }
  }

  Future<void> _sendLocation(LocationTrackingEvent event) async {
    final connectivity = await Connectivity().checkConnectivity();
    final deviceName = Platform.isAndroid ? "Android" : "iOS";

    final payload = LocationPayloadBuilder()
        .setLocationFromEvent(event)
        .setCaptainInfo(
          captainId: _config.captainId ?? "UNKNOWN",
          rideId: _config.rideId ?? "IDLE",
          tripStatus: _config.tripStatus ?? "IDLE",
        )
        .setDeviceInfo(deviceName: deviceName, batteryLevel: event.batteryLevel)
        .setNetworkInfo(
          isOnline: !connectivity.contains(ConnectivityResult.none),
          connectionType: connectivity.isNotEmpty
              ? connectivity.first.name
              : "none",
        )
        .build();

    await _transport.sendLocation(payload);
  }

  void dispose() {
    stop();
  }
}
