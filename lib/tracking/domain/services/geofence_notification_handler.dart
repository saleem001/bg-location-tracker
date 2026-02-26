import 'dart:async';
import '../../domain/entities/location_event.dart';
import '../../../../common/utils/notification_service.dart';
import '../entities/geofence_event.dart';
import 'package:async/async.dart'; // For StreamGroup

class GeofenceNotificationHandler {
  final NotificationService _notificationService;
  final Stream<LocationEvent> _eventStream;

  StreamSubscription<LocationEvent>? _subscription;

  GeofenceNotificationHandler(
    this._eventStream, {
    NotificationService? notificationService,
  }) : _notificationService = notificationService ?? NotificationService() {
    _subscription = _eventStream.listen(_handleEvent);
  }

  void _handleEvent(LocationEvent event) async {
    event.maybeWhen(
      geofenceTriggered: (geofence) async {
        String displayName = geofence.identifier;
        if (displayName.contains("_")) {
          displayName = displayName.split("_").first;
        }

        if (geofence.action == GeofenceAction.enter) {
          await _notificationService.showGeofenceAlert(
            displayName,
            geofence.identifier.hashCode,
          );
        } else if (geofence.action == GeofenceAction.exit) {
          await _notificationService.showGeofenceExitAlert(
            displayName,
            geofence.identifier.hashCode,
          );
        }
      },
      orElse: () {},
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}
