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

  Future<void> _handleEvent(LocationEvent event) async {
    event.maybeWhen(
      geofenceTriggered: (geofence) async {
        if (geofence.action == GeofenceAction.enter) {
          String displayName = geofence.identifier;

          if (displayName.contains(":::")) {
            displayName = displayName.split(":::").last;
          }

          await _notificationService.showGeofenceAlert(displayName);
        }
      },
      orElse: () {},
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}
