import 'dart:async';
import '../../domain/entities/location_event.dart';
import 'location_service_manager.dart';
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
