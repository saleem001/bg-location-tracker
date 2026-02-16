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
import 'package:async/async.dart'; // For StreamGroup


class LocationEventAggregator {
  final BackgroundLocationServiceManager manager;

  const LocationEventAggregator({required this.manager});

  // Unified event stream
  /// //does not need dispose as async* and yield* is used, they auto dispose once done.
  Stream<LocationEvent> get events async* {
    print('[Aggregator] events subscribed');
    yield* StreamGroup.merge<LocationEvent>([
      manager.locationStream.map(LocationEvent.locationUpdated),
      manager.geofenceStream.map(LocationEvent.geofenceTriggered),
      manager.motionStream.map(LocationEvent.motionChanged),
      manager.statusStream.map(LocationEvent.serviceStatusChanged),
      manager.enabledStream.map(LocationEvent.serviceEnabledChanged),
    ]);


    // Listen to merged stream asynchronously
    // await for (final event in baseStream) {
    //   // Example of injecting custom logic
    //   if (event is _ServiceEnabledChanged && !event.isEnabled) {
    //     // Emit additional cleanup events when service is disabled
    //     yield LocationEvent.serviceDisabled();
    //     yield LocationEvent.clearLocationHistory();
    //   }
    //
    //   // Always forward the original event
    //   yield event;
    // }

  }
}
