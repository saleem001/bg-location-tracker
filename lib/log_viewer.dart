import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feature/presentation/viewmodel/location_tracker_viewmodel.dart';

class LogViewerScreen extends ConsumerStatefulWidget {
  const LogViewerScreen({super.key});

  @override
  ConsumerState<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends ConsumerState<LogViewerScreen> {
  String _logs = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // _loadLogs();
  }

  // Future<void> _loadLogs() async {
  //   try {
  //     final service = ref.read(locationTrackerViewModelProvider.notifier);
  //     final logs = await service.getNativeLogs();
  //     setState(() {
  //       _logs = logs;
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _logs = "Error loading logs: $e";
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _clearLogs() async {
    try {
      final service = ref.read(locationTrackerViewModelProvider.notifier);
      // await service.clearNativeLogs();
      setState(() {
        _logs = "";
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to clear logs: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("System Logs"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearLogs,
            tooltip: "Clear Logs",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              // _loadLogs();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(child: Text("No logs available"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _logs,
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 10),
                ),
              ),
            ),
    );
  }
}
