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
  final Stream<LocationTrackingEvent> locationStream;
  final Stream<GeofenceEvent> geofenceStream;
  final Stream<MotionChangeEvent> motionStream;
  final Stream<LocationServiceStatus> statusStream;
  final Stream<bool> enabledStream;

  const LocationEventAggregator({
    required this.locationStream,
    required this.geofenceStream,
    required this.motionStream,
    required this.statusStream,
    required this.enabledStream,
  });

  /// Unified event stream
  /// //does not need dispose as async* and yield* is used, they auto dispose once done.
  Stream<LocationEvent> get events async* {
    // Merge all base streams
    yield* StreamGroup.merge<LocationEvent>([
      locationStream.map(LocationEvent.locationUpdated),
      geofenceStream.map(LocationEvent.geofenceTriggered),
      motionStream.map(LocationEvent.motionChanged),
      statusStream.map(LocationEvent.serviceStatusChanged),
      enabledStream.map(LocationEvent.serviceEnabledChanged),
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
