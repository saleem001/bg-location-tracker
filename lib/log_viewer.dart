import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_me/common/utils/plugin_logs.dart';
import 'package:track_me/features/tracking/presentation/providers/plugin_logs_provider.dart';

class LogViewerScreen extends ConsumerStatefulWidget {
  const LogViewerScreen({super.key});

  @override
  ConsumerState<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends ConsumerState<LogViewerScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  Set<PluginLogType> _selectedFilters = PluginLogType.values.toSet();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_autoScroll && _scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Color _getColorForLogType(PluginLogType type) {
    switch (type) {
      case PluginLogType.location:
        return Colors.blue;
      case PluginLogType.motionChange:
        return Colors.green;
      case PluginLogType.geofence:
        return Colors.purple;
      case PluginLogType.providerChange:
        return Colors.orange;
      case PluginLogType.activityChange:
        return Colors.teal;
      case PluginLogType.error:
        return Colors.red;
      case PluginLogType.info:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logsState = ref.watch(pluginLogsProvider);
    final filteredLogs = logsState.logs
        .where((log) => _selectedFilters.contains(log.type))
        .toList();

    // Auto-scroll when new logs arrive
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plugin Event Logs"),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(_autoScroll ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() => _autoScroll = !_autoScroll);
            },
            tooltip: _autoScroll ? "Pause auto-scroll" : "Resume auto-scroll",
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: "Filter logs",
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              ref.read(pluginLogsProvider.notifier).clearLogs();
            },
            tooltip: "Clear logs",
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Total: ${logsState.logs.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Filtered: ${filteredLogs.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Max: ${logsState.maxLogs}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Logs list
          Expanded(
            child: filteredLogs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 64, color: Colors.black),
                        SizedBox(height: 16),
                        Text(
                          'No logs available',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start a trip to see location events',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return _buildLogEntry(log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(PluginLogEntry log) {
    final color = _getColorForLogType(log.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showLogDetails(log),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(log.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      log.message,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  Text(
                    log.formattedTimestamp,
                    style: const TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ],
              ),
              if (log.data != null && log.data!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: log.data!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${entry.value}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showLogDetails(PluginLogEntry log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(log.icon),
            const SizedBox(width: 8),
            Expanded(child: Text(log.message)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Time: ${log.timestamp}'),
              Text('Type: ${log.type.name}'),
              if (log.data != null) ...[
                const SizedBox(height: 16),
                const Text('Data:'),
                const SizedBox(height: 8),
                ...log.data!.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('${entry.key}: ${entry.value}'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Log Types'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: PluginLogType.values.map((type) {
                  return CheckboxListTile(
                    title: Row(
                      children: [
                        Text(
                          _getIconForType(type),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(type.name),
                      ],
                    ),
                    value: _selectedFilters.contains(type),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          _selectedFilters.add(type);
                        } else {
                          _selectedFilters.remove(type);
                        }
                      });
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilters = PluginLogType.values.toSet();
              });
              Navigator.pop(context);
            },
            child: const Text('Select All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _getIconForType(PluginLogType type) {
    final dummyLog = PluginLogEntry(
      timestamp: DateTime.now(),
      type: type,
      message: '',
    );
    return dummyLog.icon;
  }
}
