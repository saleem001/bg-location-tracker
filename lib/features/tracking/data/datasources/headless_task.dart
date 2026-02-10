import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/providers/tracking_providers.dart';

@pragma('vm:entry-point')
void backgroundGeolocationHeadlessTask(bg.HeadlessEvent event) async {
  print('[HeadlessTask] Event received: ${event.name}');

  // Create a temporary ProviderContainer to access our ServiceManager
  final container = ProviderContainer();

  try {
    final transport = container.read(trackingTransportProvider);

    switch (event.name) {
      case bg.Event.LOCATION:
      case bg.Event.MOTIONCHANGE:
        // bg.Location location = event.event;
        print('[HeadlessTask] Processing Location event');
        break;

      case bg.Event.GEOFENCE:
        bg.GeofenceEvent geofenceEvent = event.event;
        print('[HeadlessTask] Geofence: ${geofenceEvent.identifier}');
        if (geofenceEvent.action == 'ENTER') {
          // We can still use the transport layer independently
          await transport.sendStationEntryAlert(geofenceEvent.identifier);
        }
        break;

      case bg.Event.TERMINATE:
        print('[HeadlessTask] Terminate event');
        break;

      default:
        print('[HeadlessTask] Unhandled event: ${event.name}');
    }
  } catch (e, stack) {
    print('[HeadlessTask] Error: $e\n$stack');
  } finally {
    container.dispose();
  }
}
