import 'package:flutter/foundation.dart';
import 'package:bg_location_tracker/common/utils/plugin_logs.dart';

/// Provider for managing plugin logs
class PluginLogsNotifier extends ChangeNotifier {
  static final PluginLogsNotifier _instance = PluginLogsNotifier._internal();
  factory PluginLogsNotifier() => _instance;
  PluginLogsNotifier._internal();

  PluginLogsState _state = PluginLogsState();
  PluginLogsState get state => _state;

  /// Add a location update log
  void logLocation(double lat, double lng, double speed, double odometer) {
    final entry = PluginLogEntry(
      timestamp: DateTime.now(),
      type: PluginLogType.location,
      message: 'Location Update',
      data: {
        'latitude': lat,
        'longitude': lng,
        'speed': '${speed.toStringAsFixed(2)} m/s',
        'odometer': '${odometer.toStringAsFixed(2)} m',
      },
    );
    _state = _state.addLog(entry);
    notifyListeners();
  }

  /// Add a motion change log
  void logMotionChange(bool isMoving, double lat, double lng) {
    final entry = PluginLogEntry(
      timestamp: DateTime.now(),
      type: PluginLogType.motionChange,
      message: 'Motion Change: ${isMoving ? "MOVING" : "STATIONARY"}',
      data: {'isMoving': isMoving, 'latitude': lat, 'longitude': lng},
    );
    _state = _state.addLog(entry);
    notifyListeners();
  }

  /// Add a geofence event log
  void logGeofence(String identifier, String action) {
    final entry = PluginLogEntry(
      timestamp: DateTime.now(),
      type: PluginLogType.geofence,
      message: 'Geofence $action',
      data: {'identifier': identifier, 'action': action},
    );
    _state = _state.addLog(entry);
    notifyListeners();
  }

  /// Add a provider change log
  void logServiceStatusChange(
    bool enabled,
    String permissionStatus,
    String accuracy,
    bool gps,
    bool network,
  ) {
    final entry = PluginLogEntry(
      timestamp: DateTime.now(),
      type: PluginLogType.providerChange,
      message: 'Location Service Status Changed',
      data: {
        'enabled': enabled,
        'permission': permissionStatus,
        'accuracy': accuracy,
        'gps': gps,
        'network': network,
      },
    );
    _state = _state.addLog(entry);
    notifyListeners();
  }

  /// Add an activity change log
  void logActivityChange(String activity, int confidence) {
    final entry = PluginLogEntry(
      timestamp: DateTime.now(),
      type: PluginLogType.activityChange,
      message: 'Activity: $activity',
      data: {'activity': activity, 'confidence': '$confidence%'},
    );
    _state = _state.addLog(entry);
    notifyListeners();
  }

  /// Add an error log
  void logError(String message, {dynamic error}) {
    final entry = PluginLogEntry(
      timestamp: DateTime.now(),
      type: PluginLogType.error,
      message: message,
      data: error != null ? {'error': error.toString()} : null,
    );
    _state = _state.addLog(entry);
    notifyListeners();
  }

  /// Add an info log
  void logInfo(String message, {Map<String, dynamic>? data}) {
    final entry = PluginLogEntry(
      timestamp: DateTime.now(),
      type: PluginLogType.info,
      message: message,
      data: data,
    );
    _state = _state.addLog(entry);
    notifyListeners();
  }

  /// Clear all logs
  void clearLogs() {
    _state = _state.clear();
    notifyListeners();
  }

  /// Set maximum number of logs to keep
  void setMaxLogs(int max) {
    _state = _state.copyWith(maxLogs: max);
    notifyListeners();
  }
}
