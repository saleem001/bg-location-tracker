import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/location_service_status.dart';
import 'package:bg_location_tracker/features/tracking/domain/entities/geofence_event.dart';
import 'package:bg_location_tracker/features/tracking/domain/entities/tracking_event.dart';
import '../../domain/services/geofence_notification_handler.dart';
import '../../domain/services/location_state_notifier.dart';
import '../states/location_app_state.dart';
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

// Aggregator Provider
final locationEventAggregatorProvider = Provider<LocationEventAggregator>((
  ref,
) {
  final manager = ref.watch(backgroundLocationServiceManagerProvider);

  return LocationEventAggregator(
    locationStream: manager.locationStream,
    geofenceStream: manager.geofenceStream,
    motionStream: manager.motionStream,
    statusStream: manager.statusStream,
    enabledStream: manager.enabledStream,
  );
});

final locationStateNotifierProvider =
    StateNotifierProvider.autoDispose<LocationStateNotifier, LocationAppState>((
      ref,
    ) {
      final aggregator = ref.watch(locationEventAggregatorProvider);

      final notifier = LocationStateNotifier(aggregator.events);

      // ref.onDispose(() {
      //   notifier.dispose();
      // });

      return notifier;
    });

final geofenceNotificationHandlerProvider = Provider<void>((ref) {
  final aggregator = ref.watch(locationEventAggregatorProvider);

  final handler = GeofenceNotificationHandler(aggregator.events);

  ref.onDispose(() {
    handler.dispose();
  });
});

// Socket Sync Service Provider
final socketSyncServiceProvider = Provider<void>((ref) {
  final aggregator = ref.watch(locationEventAggregatorProvider);
  final transport = ref.watch(trackingTransportProvider);

  final service = SocketSyncService(transport);

  service.start(aggregator.events);

  ref.onDispose(() {
    service.dispose();
  });
});

// View Model Provider
final locationTrackerViewModelProvider =
    NotifierProvider<LocationTrackerViewModel, LocationState>(() {
      return LocationTrackerViewModel();
    });
