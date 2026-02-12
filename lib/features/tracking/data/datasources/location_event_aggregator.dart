import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import '../../domain/entities/location_event.dart';
import '../../domain/entities/location_feature.dart';
import '../../domain/entities/tracking_event.dart';
import '../../domain/entities/geofence_event.dart';
import 'location_service_manager.dart';

class LocationEventAggregator {
  final BackgroundLocationServiceManager _manager;

  final StreamController<LocationEvent> _eventController =
      StreamController<LocationEvent>.broadcast();

  late final StreamSubscription _locationSub;
  late final StreamSubscription _motionSub;
  late final StreamSubscription _geofenceSub;
  late final StreamSubscription _statusSub;
  late final StreamSubscription _enabledSub;

  Stream<LocationEvent> get eventStream => _eventController.stream;

  LocationEventAggregator(this._manager) {
    _attach();
  }

  void _attach() {
    _locationSub = _manager.locationStream.listen((location) {
      if (_manager.isFeatureEnabled(LocationFeature.location)) {
        _eventController.add(
          LocationUpdated(location: location, isMoving: location.isMoving),
        );
      }
    });

    _motionSub = _manager.motionStream.listen((motion) {
      if (_manager.isFeatureEnabled(LocationFeature.motion)) {
        _eventController.add(MotionChanged(motion: motion));
      }
    });

    _geofenceSub = _manager.geofenceStream.listen((geofence) {
      if (_manager.isFeatureEnabled(LocationFeature.geofence)) {
        _eventController.add(GeofenceTriggered(geofence: geofence));
      }
    });

    _statusSub = _manager.statusStream.listen((status) {
      if (_manager.isFeatureEnabled(LocationFeature.status)) {
        _eventController.add(ServiceStatusChanged(status: status));
      }
    });

    _enabledSub = _manager.enabledStream.listen((enabled) {
      if (_manager.isFeatureEnabled(LocationFeature.enable)) {
        _eventController.add(ServiceEnabledChanged(isEnabled: enabled));
      }
    });
  }

  void dispose() {
    _locationSub.cancel();
    _motionSub.cancel();
    _geofenceSub.cancel();
    _statusSub.cancel();
    _enabledSub.cancel();
    _eventController.close();
  }
}
