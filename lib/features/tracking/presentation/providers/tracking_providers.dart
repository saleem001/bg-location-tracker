import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../states/location_state.dart';
import '../viewmodels/location_tracker_viewmodel.dart';
import '../../data/datasources/location_service_manager.dart';
import '../../data/datasources/socket_tracking_transport.dart'; // I will move this too
import '../../data/datasources/i_tracking_transport.dart'; // I will move this too
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

// Transport Layer Provider
final trackingTransportProvider = Provider<ITrackingTransport>((ref) {
  return SocketTrackingTransport();
});

// Service Manager Provider
final backgroundLocationServiceManagerProvider =
    Provider<BackgroundLocationServiceManager>((ref) {
      final transport = ref.watch(trackingTransportProvider);
      return BackgroundLocationServiceManager(transport);
    });

// Geofence Alert Stream Provider
final stationAlertStreamProvider = StreamProvider<String>((ref) {
  final manager = ref.watch(backgroundLocationServiceManagerProvider);
  return manager.stationAlertStream;
});

// Location Stream Provider
final locationStreamProvider = StreamProvider<bg.Location>((ref) {
  final manager = ref.watch(backgroundLocationServiceManagerProvider);
  return manager.locationStream;
});

// View Model Provider (using NotifierProvider for Riverpod 3.x)
final locationTrackerViewModelProvider =
    NotifierProvider<LocationTrackerViewModel, LocationState>(() {
      return LocationTrackerViewModel();
    });
