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
  static final LocationEventAggregator _instance =
      LocationEventAggregator._internal();
  factory LocationEventAggregator() => _instance;
  LocationEventAggregator._internal() : manager = BackgroundLocationServiceManager();

  final BackgroundLocationServiceManager manager;

  // Unified event stream
  /// //does not need dispose as async* and yield* is used, they auto dispose once done.
  Stream<LocationEvent> get events async* {
    print('[Aggregator] events subscribed');
    yield* StreamGroup.merge<LocationEvent>([
      manager.locationStream.map((location) => LocationUpdated(location)),
      manager.geofenceStream.map((geofence) => GeofenceTriggered(geofence)),
      manager.motionStream.map((motion) => MotionChanged(motion)),
      manager.statusStream.map((status) => ServiceStatusChanged(status)),
      manager.enabledStream.map((isEnabled) => ServiceEnabledChanged(isEnabled)),
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
