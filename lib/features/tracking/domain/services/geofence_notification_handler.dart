import 'dart:async';
import '../../domain/entities/location_event.dart';
import '../../../../common/utils/notification_service.dart';
import '../entities/geofence_event.dart';
import '../../data/datasources/location_event_aggregator.dart';

class GeofenceNotificationHandler {
  static final GeofenceNotificationHandler _instance = GeofenceNotificationHandler._internal();
  factory GeofenceNotificationHandler() => _instance;
  GeofenceNotificationHandler._internal() : _notificationService = NotificationService() {
    _subscription = LocationEventAggregator().events.listen(_handleEvent);
  }

  final NotificationService _notificationService;
  StreamSubscription<LocationEvent>? _subscription;

  void _handleEvent(LocationEvent event) async {
    if (event is GeofenceTriggered) {
      final geofence = event.geofence;
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
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
