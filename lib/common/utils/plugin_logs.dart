/// Represents a single log entry from the background location plugin
class PluginLogEntry {
  final DateTime timestamp;
  final PluginLogType type;
  final String message;
  final Map<String, dynamic>? data;

  PluginLogEntry({
    required this.timestamp,
    required this.type,
    required this.message,
    this.data,
  });

  String get formattedTimestamp {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  String get icon {
    switch (type) {
      case PluginLogType.location:
        return '📍';
      case PluginLogType.motionChange:
        return '🚶';
      case PluginLogType.geofence:
        return '🎯';
      case PluginLogType.providerChange:
        return '⚙️';
      case PluginLogType.activityChange:
        return '🏃';
      case PluginLogType.error:
        return '❌';
      case PluginLogType.info:
        return 'ℹ️';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$icon [$formattedTimestamp] $message');
    if (data != null && data!.isNotEmpty) {
      buffer.write('\n  Data: $data');
    }
    return buffer.toString();
  }
}

enum PluginLogType {
  location,
  motionChange,
  geofence,
  providerChange,
  activityChange,
  error,
  info,
}

/// State for managing plugin logs
class PluginLogsState {
  final List<PluginLogEntry> logs;
  final int maxLogs;

  PluginLogsState({this.logs = const [], this.maxLogs = 100});

  PluginLogsState copyWith({List<PluginLogEntry>? logs, int? maxLogs}) {
    return PluginLogsState(
      logs: logs ?? this.logs,
      maxLogs: maxLogs ?? this.maxLogs,
    );
  }

  /// Add a new log entry, keeping only the most recent maxLogs entries
  PluginLogsState addLog(PluginLogEntry entry) {
    final newLogs = [...logs, entry];
    if (newLogs.length > maxLogs) {
      return copyWith(logs: newLogs.sublist(newLogs.length - maxLogs));
    }
    return copyWith(logs: newLogs);
  }

  /// Clear all logs
  PluginLogsState clear() {
    return copyWith(logs: []);
  }

  /// Get logs as a formatted string
  String get formattedLogs {
    if (logs.isEmpty) return 'No logs available';
    return logs.map((log) => log.toString()).join('\n\n');
  }
}
