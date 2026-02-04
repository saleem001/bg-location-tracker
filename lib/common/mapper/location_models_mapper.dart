import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:track_me/common/models/geofence_event.dart';
import '../models/location_events.dart';
import 'data_mapper.dart';

class ActivityChangeEventMapper implements DataMapper<ActivityChangeEvent> {
  @override
  ActivityChangeEvent map(dynamic data) {
    final event = data as bg.ActivityChangeEvent;
    return ActivityChangeEvent(
      activity: event.activity,
      confidence: event.confidence,
    );
  }
}

// Top-level mapping functions for Config policies
bg.DesiredAccuracy mapAccuracy(int l) => l >= 5
    ? bg.DesiredAccuracy.navigation
    : (l >= 4 ? bg.DesiredAccuracy.high : bg.DesiredAccuracy.medium);

bg.PersistMode mapPersistMode(int m) => m == 0
    ? bg.PersistMode.none
    : (m == 1 ? bg.PersistMode.location : bg.PersistMode.all);

int mapLogLevel(int l) => l >= 2
    ? 5 // Verbose
    : (l >= 1 ? 4 : 0); // Debug or Off

bg.NotificationPriority mapPriority(int p) {
  if (p >= 2) return bg.NotificationPriority.max;
  if (p >= 1) return bg.NotificationPriority.high;
  if (p <= -2) return bg.NotificationPriority.min;
  if (p <= -1) return bg.NotificationPriority.low;
  return bg.NotificationPriority.defaultPriority;
}
