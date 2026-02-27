library bg_location_tracker;

// Export Models
export 'tracking/domain/entities/location_state.dart';
export 'tracking/presentation/states/location_app_state.dart';
export 'tracking/domain/entities/geofence_event.dart';
export 'tracking/domain/entities/location_event.dart';
export 'tracking/domain/entities/tracking_event.dart';

// Export Logic/ViewModels
export 'tracking/presentation/providers/tracking_providers.dart';

// Export Services
export 'tracking/data/datasources/location_service_manager.dart';

// Export Headless Task (Crucial for background work)
export 'tracking/data/datasources/headless_task.dart';

// Export logs
export 'tracking/presentation/providers/plugin_logs_provider.dart';
