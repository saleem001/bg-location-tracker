import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_manager.dart';

/// 1. INFRASTRUCTURE PROVIDER
final locationManagerProvider = Provider<LocationManager>((ref) {
  return LocationManager(BackgroundGeolocationPlugin());
});

/// 2. STATE LOGIC PROVIDER
final locationServiceProvider =
    StateNotifierProvider<LocationService, LocationState>((ref) {
      final manager = ref.watch(locationManagerProvider);
      return LocationService(manager);
    });
