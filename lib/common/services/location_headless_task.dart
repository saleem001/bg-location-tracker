import 'dart:io';
import 'dart:convert';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:path_provider/path_provider.dart';

/// ---- HEADLESS TASK (Resilience) ----
/// This runs in a separate Isolate when the app is killed.
@pragma('vm:entry-point')
void locationHeadlessTask(bg.HeadlessEvent headlessEvent) async {
  print('📬 [HeadlessTask] ${headlessEvent.name}');

  // 1. Existing file logging for verification
  final timestamp = DateTime.now().toIso8601String();
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/headless_logs.jsonl');
    await file.writeAsString(
      '${jsonEncode({'event': headlessEvent.name, 'ts': timestamp, 'data': headlessEvent.event.toString()})}\n',
      mode: FileMode.append,
      flush: true,
    );
  } catch (_) {}

  // 2. Event-specific handling
  switch (headlessEvent.name) {
    case bg.Event.BOOT:
      bg.State state = await bg.BackgroundGeolocation.state;
      print("📬 didDeviceReboot: ${state.didDeviceReboot}");
      break;

    case bg.Event.TERMINATE:
      bg.State state = await bg.BackgroundGeolocation.state;
      if (state.stopOnTerminate!) {
        return;
      }
      try {
        bg.Location location =
            await bg.BackgroundGeolocation.getCurrentPosition(
              samples: 1,
              persist: true,
              extras: {"event": "terminate", "headless": true},
            );
        print("[getCurrentPosition] Headless (Terminate): $location");
      } catch (error) {
        print("[getCurrentPosition] Headless ERROR: $error");
      }
      break;

    case bg.Event.HEARTBEAT:
      try {
        bg.Location location =
            await bg.BackgroundGeolocation.getCurrentPosition(
              samples: 2,
              timeout: 10,
              extras: {"event": "heartbeat", "headless": true},
            );
        print('[getCurrentPosition] Headless (Heartbeat): $location');
      } catch (error) {
        print('[getCurrentPosition] Headless ERROR: $error');
      }
      break;

    case bg.Event.LOCATION:
      bg.Location location = headlessEvent.event;
      print("[Headless Location] $location");
      break;

    case bg.Event.MOTIONCHANGE:
      bg.Location location = headlessEvent.event;
      print("[Headless MotionChange] $location");
      break;

    case bg.Event.GEOFENCE:
      bg.GeofenceEvent geofenceEvent = headlessEvent.event;
      print("[Headless Geofence] $geofenceEvent");
      break;

    case bg.Event.GEOFENCESCHANGE:
      bg.GeofencesChangeEvent event = headlessEvent.event;
      print("[Headless GeofencesChange] $event");
      break;

    case bg.Event.SCHEDULE:
      bg.State state = headlessEvent.event;
      print("[Headless Schedule] $state");
      break;

    case bg.Event.ACTIVITYCHANGE:
      bg.ActivityChangeEvent event = headlessEvent.event;
      print("[Headless ActivityChange] $event");
      break;

    case bg.Event.HTTP:
      bg.HttpEvent response = headlessEvent.event;
      print("[Headless HTTP] $response");
      break;

    case bg.Event.POWERSAVECHANGE:
      bool enabled = headlessEvent.event;
      print("[Headless PowerSaveChange] $enabled");
      break;

    case bg.Event.CONNECTIVITYCHANGE:
      bg.ConnectivityChangeEvent event = headlessEvent.event;
      print("[Headless ConnectivityChange] $event");
      break;

    case bg.Event.ENABLEDCHANGE:
      bool enabled = headlessEvent.event;
      print("[Headless EnabledChange] $enabled");
      break;
  }
}
