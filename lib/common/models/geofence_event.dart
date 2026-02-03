import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:track_me/common/constants/app_constants.dart';
import 'package:track_me/common/mapper/data_mapper.dart';

enum GeofenceAction {
  enter,
  exit;

  static GeofenceAction fromString(String value) {
    switch (value.toUpperCase()) {
      case AppConstants.geofenceActionEnter || AppConstants.geofenceActionDwell:
        return GeofenceAction.enter;
      case AppConstants.geofenceActionExit:
        return GeofenceAction.exit;
      default:
        throw ArgumentError('Unknown geofence action: $value');
    }
  }

  bool get isInside => this == GeofenceAction.enter;
}

class GeofenceEvent {
  final String identifier;
  final GeofenceAction action;
  GeofenceEvent({required this.identifier, required this.action});
}

class GeofenceEventMapper implements DataMapper<GeofenceEvent> {
  @override
  GeofenceEvent map(dynamic data) {
    final event = data as bg.GeofenceEvent;
    return GeofenceEvent(
      identifier: event.identifier,
      action: GeofenceAction.fromString(event.action),
    );
  }
}
