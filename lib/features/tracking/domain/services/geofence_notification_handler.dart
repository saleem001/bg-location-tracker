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
      if (event.geofence.action == GeofenceAction.enter) {
        String displayName = event.geofence.identifier;
        if (displayName.contains(":::")) {
          displayName = displayName.split(":::").last;
        }

        await _notificationService.showGeofenceAlert(displayName);
      }
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
