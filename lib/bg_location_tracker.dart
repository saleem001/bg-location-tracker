library bg_location_tracker;

// Export Models
export 'features/tracking/presentation/states/location_state.dart';
export 'features/tracking/presentation/states/location_app_state.dart';
export 'features/tracking/domain/entities/geofence_event.dart';
export 'features/tracking/domain/entities/location_event.dart';
export 'features/tracking/domain/entities/tracking_event.dart';

// Export Logic/ViewModels
export 'features/tracking/presentation/viewmodels/location_tracker_viewmodel.dart';
export 'features/tracking/presentation/providers/tracking_providers.dart';

// Export Services
export 'features/tracking/data/datasources/location_service_manager.dart';
export 'features/tracking/data/datasources/socket_sync_service.dart';
export 'common/utils/notification_service.dart';

// Export Headless Task (Crucial for background work)
export 'features/tracking/data/datasources/headless_task.dart';

// Export UI (if the user wants to use the pre-built components)
export 'features/tracking/presentation/screens/location_tracker_dashboard.dart';
export 'log_viewer.dart';
export 'features/tracking/presentation/providers/plugin_logs_provider.dart';
