import 'package:track_me/features/tracking/data/datasources/location_plugin_configs.dart';
import 'package:track_me/features/tracking/domain/entities/location_service_status.dart';
import 'package:track_me/features/tracking/domain/entities/tracking_event.dart';

abstract class ILocationTracking {
  Future<bool> initialize(LocationManagerConfig config);
  Future<void> start();
  Future<void> stop();
  Future<LocationTrackingEvent> getCurrentPosition();
  void onLocation(
    void Function(LocationTrackingEvent) s, [
    void Function(dynamic)? f,
  ]);
  void onGeofence(void Function(String identifier, String action) callback);
  void onEnabledChange(void Function(bool) callback);
  void onMotionChange(void Function(LocationTrackingEvent, bool) callback);
  void onLocationServiceStatusChange(
    void Function(LocationServiceStatus) callback,
  );
  void removeListeners();
  Future<void> setConfig(Map<String, dynamic> extras);
  Future<void> addGeofence(String id, double lat, double lng, double radius);
  Future<void> removeGeofence(String id);
}
