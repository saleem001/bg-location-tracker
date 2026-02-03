import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:permission_handler/permission_handler.dart';
import 'package:track_me/feature/presentation/view/location_tracker_dashboard.dart';
import 'common/services/location_headless_task.dart';
import 'package:toast/toast.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Register Headless Task (Crucial to be here for app-kill resilience)
  bg.BackgroundGeolocation.registerHeadlessTask(locationHeadlessTask);

  runApp(const ProviderScope(child: POCApp()));
}

class POCApp extends StatefulWidget {
  const POCApp({super.key});

  @override
  State<POCApp> createState() => _POCAppState();
}

class _POCAppState extends State<POCApp> {
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    // Request both location and locationAlways permissions
    await _requestPermission(Permission.location);
    await _requestPermission(Permission.locationAlways);
  }

  Future<void> _requestPermission(Permission permission) async {
    PermissionStatus status = await permission.status;

    if (status.isDenied) {
      PermissionStatus newStatus = await permission.request();
      if (newStatus.isPermanentlyDenied) {
        Toast.show(
          "Please allow all the time location permissions in settings",
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
        );
      }
    } else if (status.isPermanentlyDenied) {
      Toast.show(
        "Please allow all the time location permissions in settings",
        duration: Toast.lengthLong,
        gravity: Toast.bottom,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
      ),
      home: Builder(
        builder: (context) {
          ToastContext().init(context);
          return const LocationDashboard();
        },
      ),
    );
  }
}
