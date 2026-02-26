import 'package:freezed_annotation/freezed_annotation.dart';

import 'location_service_manager_config.dart';
import 'location_service_manager_config_policy.dart';

part 'location_service_manager_config_types.freezed.dart';

@freezed
class LocationServiceManagerConfigType with _$LocationServiceManagerConfigType {
  const factory LocationServiceManagerConfigType.low() = _Low;
  const factory LocationServiceManagerConfigType.high({
    required String notificationTitle,
    required String notificationMessage,
  }) = _High;

  const LocationServiceManagerConfigType._();

  LocationManagerConfig toLocationManagerConfig() => when(
    low: () => LocationManagerConfigBuilder()
        .setTracking(
          TrackingPolicyBuilder()
              .setAccuracy(3) // Maps to Medium accuracy
              .setDistanceFilter(50)
              .setMovementThreshold(50)
              .build(),
        )
        .setLifecycle(
          LifecyclePolicyBuilder()
              .setStopOnTerminate(true)
              .setStartOnBoot(false)
              .build(),
        )
        .setReset(true)
        // Note: Android requires a notification for foreground services.
        // We use default or discrete settings if "no notification needed".
        .setLogging(
          LoggingPolicyBuilder().setLogLevel(0).setDebug(false).build(),
        )
        .build(),
    high: (title, message) => LocationManagerConfigBuilder()
        .setTracking(
          TrackingPolicyBuilder()
              .setAccuracy(5) // Maps to Navigation accuracy
              .setDistanceFilter(5)
              .setMovementThreshold(5)
              .build(),
        )
        .setLifecycle(
          LifecyclePolicyBuilder()
              .setStopOnTerminate(false)
              .setStartOnBoot(true)
              .build(),
        )
        .setNotification(
          NotificationPolicyBuilder()
              .setTitle(title)
              .setMessage(message)
              .build(),
        )
        .setReset(true)
        .setLogging(
          LoggingPolicyBuilder().setLogLevel(2).setDebug(true).build(),
        )
        .build(),
  );
}
