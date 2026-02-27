import 'package:bg_location_tracker/common/constants/app_constants.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_riverpod/flutter_riverpod.dart';

@pragma('vm:entry-point')
void backgroundGeolocationHeadlessTask(bg.HeadlessEvent event) async {
  print('[HeadlessTask] Event received: ${event.name}');

  // Create a temporary ProviderContainer to access our ServiceManager
  final container = ProviderContainer();

  try {
    switch (event.name) {
      case bg.Event.LOCATION:
      case bg.Event.MOTIONCHANGE:
        // bg.Location location = event.event;
        print('[HeadlessTask] Processing Location event');
        break;

      case bg.Event.GEOFENCE:
        bg.GeofenceEvent geofenceEvent = event.event;
        print('[HeadlessTask] Geofence: ${geofenceEvent.identifier}');

        String displayName = geofenceEvent.identifier;
        if (displayName.contains("_")) {
          displayName = displayName.split("_").first;
        }
        final notificationId = geofenceEvent.identifier.hashCode;
        switch (geofenceEvent.action) {
          case AppConstants.geofenceActionEnter:

            break;
          case AppConstants.geofenceActionExit:
            break;
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
