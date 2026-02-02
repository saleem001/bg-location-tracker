import 'dart:async';
import '../models/location_models.dart';
import '../models/location_config.dart';
import 'location_plugin.dart';

class LocationManager {
  final ILocationPlugin _plugin;
  final _locController = StreamController<LocationEntity>.broadcast();
  final _geoController = StreamController<GeofenceEvent>.broadcast();
  final _actController = StreamController<ActivityChangeEvent>.broadcast();
  final _providerController = StreamController<ProviderChangeEvent>.broadcast();
  final _enabledController = StreamController<bool>.broadcast();
  final _motionController = StreamController<MotionChangeEvent>.broadcast();

  LocationManager(this._plugin);

  Stream<LocationEntity> get onLocation => _locController.stream;
  Stream<GeofenceEvent> get onGeofence => _geoController.stream;
  Stream<ActivityChangeEvent> get onActivity => _actController.stream;
  Stream<ProviderChangeEvent> get onProviderChange =>
      _providerController.stream;
  Stream<bool> get onEnabledChange => _enabledController.stream;
  Stream<MotionChangeEvent> get onMotionChange => _motionController.stream;

  Future<bool> initialize(LocationManagerConfig config) async {
    _plugin.removeListeners();
    _startPiping();
    return await _plugin.initialize(config);
  }

  Future<bool> restoreState() async {
    _plugin.removeListeners();
    _startPiping();
    return await _plugin.restoreState();
  }

  Future<void> updateConfig(Map<String, dynamic> extras) =>
      _plugin.setConfig(extras);

  void _startPiping() {
    _plugin.onLocation(_locController.add);
    _plugin.onGeofence(_geoController.add);
    _plugin.onActivityChange(_actController.add);
    _plugin.onProviderChange(_providerController.add);
    _plugin.onEnabledChange(_enabledController.add);
    _plugin.onMotionChange(
      (loc, isMoving) => _motionController.add(
        MotionChangeEvent(location: loc, isMoving: isMoving),
      ),
    );
  }

  Future<void> startTracking() => _plugin.start();
  Future<void> stopTracking() => _plugin.stop();
  Future<void> changePace(bool isMoving) => _plugin.changePace(isMoving);

  Future<LocationEntity> getCurrentPosition() => _plugin.getCurrentPosition();
  Future<int> requestPermission() => _plugin.requestPermission();
  Future<int> getAuthorizationStatus() => _plugin.getAuthorizationStatus();
  Future<void> setupArrivalZone(
    String id,
    double lat,
    double lng,
    double rad,
  ) => _plugin.addGeofence(id, lat, lng, rad);
  Future<void> clearZones() => _plugin.removeGeofences();

  Future<String> getNativeLogs() => _plugin.getLogs();

  Future<void> clearNativeLogs() => _plugin.clearLogs();

  void dispose() {
    _locController.close();
    _geoController.close();
    _actController.close();
    _providerController.close();
    _enabledController.close();
    _motionController.close();
    _plugin.removeListeners();
  }
}
