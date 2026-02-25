import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import '../../domain/entities/captain_location_data.dart';
import '../../domain/entities/location_event.dart';
import '../../domain/entities/location_feature.dart';
import '../../domain/entities/tracking_event.dart';
import '../../domain/entities/geofence_event.dart';
import 'location_service_manager.dart';
import '../../domain/entities/location_service_status.dart';
import 'package:async/async.dart';

class LocationEventAggregator {
  final BackgroundLocationServiceManager manager;

  LocationEventAggregator({required this.manager});

  // Unified event stream
  ///does not need dispose as async* and yield* is used, they auto dispose once done.
  Stream<LocationEvent> get events async* {
    yield* StreamGroup.merge<LocationEvent>([
      manager.locationStream.map((loc) => LocationEvent.locationUpdated(loc)),
      manager.geofenceStream.map(
        (event) => LocationEvent.geofenceTriggered(event),
      ),
      manager.motionStream.map((event) => LocationEvent.motionChanged(event)),
      manager.statusStream.map(
        (event) => LocationEvent.serviceStatusChanged(event),
      ),
      manager.enabledStream.map(
        (enabled) => LocationEvent.serviceEnabledChanged(enabled),
      ),
    ]);
  }
}
