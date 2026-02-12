import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:track_me/features/tracking/domain/services/location_update_service.dart';
import '../../domain/entities/location_service_status.dart';
import 'package:track_me/features/tracking/domain/entities/geofence_event.dart';
import 'package:track_me/features/tracking/domain/entities/tracking_event.dart';
import '../../domain/services/geofence_notification_handler.dart';
import '../states/location_state.dart';
import '../viewmodels/location_tracker_viewmodel.dart';
import '../../data/datasources/location_service_manager.dart';
import '../../data/datasources/i_tracking_transport.dart';
import '../../data/datasources/location_event_aggregator.dart';
import '../../data/datasources/socket_sync_service.dart';
import '../../data/datasources/socket_tracking_transport.dart';
import '../../domain/entities/location_event.dart';

// Transport Layer Provider
final trackingTransportProvider = Provider<ITrackingTransport>((ref) {
  return SocketTrackingTransport();
});

// Service Manager Provider (Concrete Implementation)
final backgroundLocationServiceManagerProvider =
    Provider<BackgroundLocationServiceManager>((ref) {
      final manager = BackgroundLocationServiceManager();
      ref.onDispose(() => manager.dispose());
      return manager;
    });

// Location Update Service Provider (Bridge: Manager -> Transport)
final locationUpdateServiceProvider = Provider<LocationUpdateService>((ref) {
  final transport = ref.watch(trackingTransportProvider);
  return LocationUpdateService(ref, transport);
});

// Aggregator Provider
final locationEventAggregatorProvider = Provider<LocationEventAggregator>((
  ref,
) {
  final manager = ref.watch(backgroundLocationServiceManagerProvider);

  final aggregator = LocationEventAggregator(manager);

  ref.onDispose(() => aggregator.dispose());

  return aggregator;
});

final geofenceNotificationHandlerProvider =
    Provider<GeofenceNotificationHandler>((ref) {
      final aggregator = ref.watch(locationEventAggregatorProvider);

      final handler = GeofenceNotificationHandler(aggregator.eventStream);

      ref.onDispose(() => handler.dispose());

      return handler;
    });

// Unified Event Stream Provider
final locationEventStreamProvider = StreamProvider<LocationEvent>((ref) {
  final aggregator = ref.watch(locationEventAggregatorProvider);
  return aggregator.eventStream;
});

// Socket Sync Service Provider
final socketSyncServiceProvider = Provider<SocketSyncService>((ref) {
  final transport = ref.watch(trackingTransportProvider);
  final aggregator = ref.watch(locationEventAggregatorProvider);
  final service = SocketSyncService(transport);

  // Listen to the aggregated stream directly from the aggregator
  service.startListening(aggregator.eventStream);

  ref.onDispose(() => service.stopListening());

  return service;
});

// View Model Provider
final locationTrackerViewModelProvider =
    NotifierProvider<LocationTrackerViewModel, LocationState>(() {
      return LocationTrackerViewModel();
    });
