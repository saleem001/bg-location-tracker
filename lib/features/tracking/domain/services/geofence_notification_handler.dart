import 'dart:async';
import '../../domain/entities/location_event.dart';
import '../../../../common/utils/notification_service.dart';
import '../entities/geofence_event.dart';

class GeofenceNotificationHandler {
  final NotificationService _notificationService;
  late final StreamSubscription _subscription;

  GeofenceNotificationHandler(
    Stream<LocationEvent> eventStream, {
    NotificationService? notificationService,
  }) : _notificationService = notificationService ?? NotificationService() {
    _subscription = eventStream.listen(_handleEvent);
  }

  void _handleEvent(LocationEvent event) async {
    if (event is GeofenceTriggered) {
      String displayName = event.geofence.identifier;
      if (displayName.contains(":::")) {
        displayName = displayName.split(":::").last;
      }

      if (event.geofence.action == GeofenceAction.enter) {
        await _notificationService.showGeofenceAlert(
          displayName,
          event.geofence.identifier.hashCode,
        );
      } else if (event.geofence.action == GeofenceAction.exit) {
        await _notificationService.showGeofenceExitAlert(
          displayName,
          event.geofence.identifier.hashCode,
        );
      }
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
