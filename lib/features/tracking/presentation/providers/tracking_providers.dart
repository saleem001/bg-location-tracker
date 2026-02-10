import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/location_service_status.dart';
import 'package:track_me/features/tracking/domain/entities/geofence_event.dart';
import 'package:track_me/features/tracking/domain/entities/tracking_event.dart';
import '../states/location_state.dart';
import '../viewmodels/location_tracker_viewmodel.dart';
import '../../data/datasources/location_service_manager.dart';
import '../../data/datasources/socket_tracking_transport.dart'; // I will move this too
import '../../data/datasources/i_tracking_transport.dart'; // I will move this too

import 'package:track_me/features/tracking/domain/services/location_update_service.dart';

// Transport Layer Provider
final trackingTransportProvider = Provider<ITrackingTransport>((ref) {
  return SocketTrackingTransport();
});

// Service Manager Provider (Concrete Implementation)
final backgroundLocationServiceManagerProvider =
    Provider<BackgroundLocationServiceManager>((ref) {
      return BackgroundLocationServiceManager();
    });

// Location Update Service Provider (Bridge: Manager -> Transport)
final locationUpdateServiceProvider = Provider<LocationUpdateService>((ref) {
  final transport = ref.watch(trackingTransportProvider);
  return LocationUpdateService(ref, transport);
});

// Geofence Alert Stream Provider
final geofenceStreamProvider = StreamProvider<GeofenceEvent>((ref) {
  final manager = ref.watch(backgroundLocationServiceManagerProvider);
  return manager.streams.geofence;
});

// Location Stream Provider
final locationStreamProvider = StreamProvider<LocationTrackingEvent>((ref) {
  final manager = ref.watch(backgroundLocationServiceManagerProvider);
  return manager.streams.location;
});

// Service Status Stream Provider
final serviceStatusStreamProvider = StreamProvider<LocationServiceStatus>((
  ref,
) {
  final manager = ref.watch(backgroundLocationServiceManagerProvider);
  return manager.streams.serviceStatus;
});

// Motion Stream Provider
final motionStreamProvider = StreamProvider<MotionChangeEvent>((ref) {
  final manager = ref.watch(backgroundLocationServiceManagerProvider);
  return manager.streams.motion;
});

// View Model Provider (using NotifierProvider for Riverpod 3.x)
final locationTrackerViewModelProvider =
    NotifierProvider<LocationTrackerViewModel, LocationState>(() {
      return LocationTrackerViewModel();
    });
