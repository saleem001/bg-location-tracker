import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_me/common/models/plugin_log.dart';

/// Provider for managing plugin logs
final pluginLogsProvider =
    StateNotifierProvider<PluginLogsNotifier, PluginLogsState>((ref) {
      return PluginLogsNotifier();
    });

class PluginLogsNotifier extends StateNotifier<PluginLogsState> {
  PluginLogsNotifier() : super(PluginLogsState());

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
    state = state.addLog(entry);
  }

  /// Add a motion change log
  void logMotionChange(bool isMoving, double lat, double lng) {
    final entry = PluginLogEntry(
      timestamp: DateTime.now(),
      type: PluginLogType.motionChange,
      message: 'Motion Change: ${isMoving ? "MOVING" : "STATIONARY"}',
      data: {'isMoving': isMoving, 'latitude': lat, 'longitude': lng},
    );
    state = state.addLog(entry);
  }

  /// Add a geofence event log
  void logGeofence(String identifier, String action) {
    final entry = PluginLogEntry(
      timestamp: DateTime.now(),
      type: PluginLogType.geofence,
      message: 'Geofence $action',
      data: {'identifier': identifier, 'action': action},
    );
    state = state.addLog(entry);
  }

  /// Add a provider change log
  void logProviderChange(
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
    state = state.addLog(entry);
  }

  /// Add an activity change log
  void logActivityChange(String activity, int confidence) {
    final entry = PluginLogEntry(
      timestamp: DateTime.now(),
      type: PluginLogType.activityChange,
      message: 'Activity: $activity',
      data: {'activity': activity, 'confidence': '$confidence%'},
    );
    state = state.addLog(entry);
  }

  /// Add an error log
  void logError(String message, {dynamic error}) {
    final entry = PluginLogEntry(
      timestamp: DateTime.now(),
      type: PluginLogType.error,
      message: message,
      data: error != null ? {'error': error.toString()} : null,
    );
    state = state.addLog(entry);
  }

  /// Add an info log
  void logInfo(String message, {Map<String, dynamic>? data}) {
    final entry = PluginLogEntry(
      timestamp: DateTime.now(),
      type: PluginLogType.info,
      message: message,
      data: data,
    );
    state = state.addLog(entry);
  }

  /// Clear all logs
  void clearLogs() {
    state = state.clear();
  }

  /// Set maximum number of logs to keep
  void setMaxLogs(int max) {
    state = state.copyWith(maxLogs: max);
  }
}
