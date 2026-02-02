import 'dart:io';
import 'dart:convert';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:path_provider/path_provider.dart';

/// ---- HEADLESS TASK (Resilience) ----
/// This runs in a separate Isolate when the app is killed.
@pragma('vm:entry-point')
void locationHeadlessTask(bg.HeadlessEvent event) async {
  // Example of a custom task: Log to a private file for verification
  final timestamp = DateTime.now().toIso8601String();
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/headless_logs.jsonl');
    await file.writeAsString(
      '${jsonEncode({'event': event.name, 'ts': timestamp, 'data': event.event.toString()})}\n',
      mode: FileMode.append,
      flush: true,
    );
  } catch (_) {}
}
