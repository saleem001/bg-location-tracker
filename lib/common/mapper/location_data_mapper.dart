import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'data_mapper.dart';

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
