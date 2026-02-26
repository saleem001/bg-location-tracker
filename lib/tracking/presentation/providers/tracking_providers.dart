import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/location_service_manager.dart';
import '../../data/datasources/location_event_aggregator.dart';

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

  return LocationEventAggregator(manager: manager);
});
