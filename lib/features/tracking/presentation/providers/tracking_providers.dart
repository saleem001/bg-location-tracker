import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/location_service_status.dart';
import 'package:track_me/features/tracking/domain/entities/geofence_event.dart';
import 'package:track_me/features/tracking/domain/entities/tracking_event.dart';
import '../states/location_state.dart';
import '../viewmodels/location_tracker_viewmodel.dart';
import '../../data/datasources/location_service_manager.dart';
import '../../data/datasources/socket_tracking_transport.dart'; // I will move this too
import '../../data/datasources/i_tracking_transport.dart'; // I will move this too

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
final geofenceStreamProvider = StreamProvider<GeofenceEvent>((ref) {
  final manager = ref.watch(backgroundLocationServiceManagerProvider);
  return manager.geofenceStream;
});

// Location Stream Provider
final locationStreamProvider = StreamProvider<LocationTrackingEvent>((ref) {
  final manager = ref.watch(backgroundLocationServiceManagerProvider);
  return manager.locationStream;
});

// Service Status Stream Provider
final serviceStatusStreamProvider = StreamProvider<LocationServiceStatus>((
  ref,
) {
  final manager = ref.watch(backgroundLocationServiceManagerProvider);
  return manager.serviceStatusStream;
});

// Motion Stream Provider
final motionStreamProvider = StreamProvider<MotionChangeEvent>((ref) {
  final manager = ref.watch(backgroundLocationServiceManagerProvider);
  return manager.motionStream;
});

// View Model Provider (using NotifierProvider for Riverpod 3.x)
final locationTrackerViewModelProvider =
    NotifierProvider<LocationTrackerViewModel, LocationState>(() {
      return LocationTrackerViewModel();
    });
