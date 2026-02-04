import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_me/features/tracking/presentation/providers/tracking_providers.dart';

class LogViewerScreen extends ConsumerStatefulWidget {
  const LogViewerScreen({super.key});

  @override
  ConsumerState<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends ConsumerState<LogViewerScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationTrackerViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Location History"),
      ),
      body: ListView.builder(
        itemCount: state.locationHistory.length,
        itemBuilder: (context, index) {
          final loc = state.locationHistory[index];
          return ListTile(
            title: Text("Lat: ${loc.latitude}, Lng: ${loc.longitude}"),
            subtitle: Text("Time: ${loc.timestamp.toIso8601String()}"),
          );
        },
      ),
    );
  }
}
