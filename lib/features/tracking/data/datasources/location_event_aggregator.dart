import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import '../../domain/entities/location_event.dart';
import '../../domain/entities/tracking_event.dart';
import '../../domain/entities/geofence_event.dart';
import '../../../../common/utils/notification_service.dart';

class LocationEventAggregator {
  final StreamController<LocationEvent> _eventController = StreamController<LocationEvent>.broadcast();

  Stream<LocationEvent> get eventStream => _eventController.stream;

  LocationEventAggregator() {
    _initListeners();
  }

  void _initListeners() {
    // 1. Location Updates
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      final trackingEvent = LocationMapper().map(location);
      _eventController.add(LocationUpdated(
        location: trackingEvent,
        isMoving: location.isMoving,
      ));
    });

    // 2. Motion Change
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      final motionEvent = MotionChangeEventMapper().map(location);
      _eventController.add(MotionChanged(
        motion: motionEvent,
      ));
    });

    // 3. Geofence Events
    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) async {
      final geofenceEvent = GeofenceEventMapper().map(event);
      _eventController.add(GeofenceTriggered(
        geofence: geofenceEvent,
      ));
      
      // Also handle notification here (since this is the single source of truth)
      if (event.action == "ENTER") {
        String displayName = event.identifier;
        if (displayName.contains(":::")) {
          displayName = displayName.split(":::").last;
        }
        
        // Import needed at top
        final notificationService = NotificationService();
        await notificationService.showGeofenceAlert(displayName);
      }
    });
  }

  void dispose() {
    _eventController.close();
  }
}
