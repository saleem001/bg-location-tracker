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
      manager.locationStream.map((loc) {
        print('[LocationEventAggregator] Adding location to stream: $loc');
        return LocationEvent.locationUpdated(loc);
      }),
      manager.geofenceStream.map((event) {
        print('[LocationEventAggregator] Adding geofence to stream: $event');
        return LocationEvent.geofenceTriggered(event);
      }),
      manager.motionStream.map((event) {
        print('[LocationEventAggregator] Adding motion to stream: $event');
        return LocationEvent.motionChanged(event);
      }),
      manager.statusStream.map((event) {
        print('[LocationEventAggregator] Adding status to stream: $event');
        return LocationEvent.serviceStatusChanged(event);
      }),
      manager.enabledStream.map((enabled) {
        print('[LocationEventAggregator] Adding enabled to stream: $enabled');
        return LocationEvent.serviceEnabledChanged(enabled);
      }),
    ]);
  }
}
