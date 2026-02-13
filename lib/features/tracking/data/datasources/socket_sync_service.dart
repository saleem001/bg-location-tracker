import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';
import '../../domain/entities/location_event.dart';
import '../../domain/entities/tracking_event.dart';
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

  void start(Stream<LocationEvent> eventStream) {
    _subscription?.cancel();
    _subscription = eventStream.listen(_handleEvent);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _handleEvent(LocationEvent event) async {
    await event.when(
      locationUpdated: (location) async {
        await _sendLocation(location);
      },
      geofenceTriggered: (geofence) async {
        await _transport.sendStationEntryAlert(geofence.identifier);
      },
      motionChanged: (_) async {},
      serviceStatusChanged: (_) async {},
      serviceEnabledChanged: (_) async {},
    );
  }

  Future<void> _sendLocation(LocationTrackingEvent event) async {
    final connectivity = await Connectivity().checkConnectivity();
    final deviceName = Platform.isAndroid ? "Android" : "iOS";

    final payload = LocationPayloadBuilder()
        .setLocationRaw(
          lat: event.latitude,
          lng: event.longitude,
          speed: event.speed,
          odometer: event.odometer,
          timestamp: event.timestamp,
        )
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
