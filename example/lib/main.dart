import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:permission_handler/permission_handler.dart';
import 'package:bg_location_tracker/bg_location_tracker.dart';
import 'package:toast/toast.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Register Headless Task
  bg.BackgroundGeolocation.registerHeadlessTask(
    backgroundGeolocationHeadlessTask,
  );

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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}
