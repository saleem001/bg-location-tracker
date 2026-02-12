// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocationEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocationEvent()';
}


}

/// @nodoc
class $LocationEventCopyWith<$Res>  {
$LocationEventCopyWith(LocationEvent _, $Res Function(LocationEvent) __);
}


/// Adds pattern-matching-related methods to [LocationEvent].
extension LocationEventPatterns on LocationEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LocationUpdated value)?  locationUpdated,TResult Function( MotionChanged value)?  motionChanged,TResult Function( GeofenceTriggered value)?  geofenceTriggered,TResult Function( ServiceStatusChanged value)?  serviceStatusChanged,TResult Function( ServiceEnabledChanged value)?  serviceEnabledChanged,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LocationUpdated() when locationUpdated != null:
return locationUpdated(_that);case MotionChanged() when motionChanged != null:
return motionChanged(_that);case GeofenceTriggered() when geofenceTriggered != null:
return geofenceTriggered(_that);case ServiceStatusChanged() when serviceStatusChanged != null:
return serviceStatusChanged(_that);case ServiceEnabledChanged() when serviceEnabledChanged != null:
return serviceEnabledChanged(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LocationUpdated value)  locationUpdated,required TResult Function( MotionChanged value)  motionChanged,required TResult Function( GeofenceTriggered value)  geofenceTriggered,required TResult Function( ServiceStatusChanged value)  serviceStatusChanged,required TResult Function( ServiceEnabledChanged value)  serviceEnabledChanged,}){
final _that = this;
switch (_that) {
case LocationUpdated():
return locationUpdated(_that);case MotionChanged():
return motionChanged(_that);case GeofenceTriggered():
return geofenceTriggered(_that);case ServiceStatusChanged():
return serviceStatusChanged(_that);case ServiceEnabledChanged():
return serviceEnabledChanged(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LocationUpdated value)?  locationUpdated,TResult? Function( MotionChanged value)?  motionChanged,TResult? Function( GeofenceTriggered value)?  geofenceTriggered,TResult? Function( ServiceStatusChanged value)?  serviceStatusChanged,TResult? Function( ServiceEnabledChanged value)?  serviceEnabledChanged,}){
final _that = this;
switch (_that) {
case LocationUpdated() when locationUpdated != null:
return locationUpdated(_that);case MotionChanged() when motionChanged != null:
return motionChanged(_that);case GeofenceTriggered() when geofenceTriggered != null:
return geofenceTriggered(_that);case ServiceStatusChanged() when serviceStatusChanged != null:
return serviceStatusChanged(_that);case ServiceEnabledChanged() when serviceEnabledChanged != null:
return serviceEnabledChanged(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LocationTrackingEvent location,  bool isMoving)?  locationUpdated,TResult Function( MotionChangeEvent motion)?  motionChanged,TResult Function( GeofenceEvent geofence)?  geofenceTriggered,TResult Function( LocationServiceStatus status)?  serviceStatusChanged,TResult Function( bool isEnabled)?  serviceEnabledChanged,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LocationUpdated() when locationUpdated != null:
return locationUpdated(_that.location,_that.isMoving);case MotionChanged() when motionChanged != null:
return motionChanged(_that.motion);case GeofenceTriggered() when geofenceTriggered != null:
return geofenceTriggered(_that.geofence);case ServiceStatusChanged() when serviceStatusChanged != null:
return serviceStatusChanged(_that.status);case ServiceEnabledChanged() when serviceEnabledChanged != null:
return serviceEnabledChanged(_that.isEnabled);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LocationTrackingEvent location,  bool isMoving)  locationUpdated,required TResult Function( MotionChangeEvent motion)  motionChanged,required TResult Function( GeofenceEvent geofence)  geofenceTriggered,required TResult Function( LocationServiceStatus status)  serviceStatusChanged,required TResult Function( bool isEnabled)  serviceEnabledChanged,}) {final _that = this;
switch (_that) {
case LocationUpdated():
return locationUpdated(_that.location,_that.isMoving);case MotionChanged():
return motionChanged(_that.motion);case GeofenceTriggered():
return geofenceTriggered(_that.geofence);case ServiceStatusChanged():
return serviceStatusChanged(_that.status);case ServiceEnabledChanged():
return serviceEnabledChanged(_that.isEnabled);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LocationTrackingEvent location,  bool isMoving)?  locationUpdated,TResult? Function( MotionChangeEvent motion)?  motionChanged,TResult? Function( GeofenceEvent geofence)?  geofenceTriggered,TResult? Function( LocationServiceStatus status)?  serviceStatusChanged,TResult? Function( bool isEnabled)?  serviceEnabledChanged,}) {final _that = this;
switch (_that) {
case LocationUpdated() when locationUpdated != null:
return locationUpdated(_that.location,_that.isMoving);case MotionChanged() when motionChanged != null:
return motionChanged(_that.motion);case GeofenceTriggered() when geofenceTriggered != null:
return geofenceTriggered(_that.geofence);case ServiceStatusChanged() when serviceStatusChanged != null:
return serviceStatusChanged(_that.status);case ServiceEnabledChanged() when serviceEnabledChanged != null:
return serviceEnabledChanged(_that.isEnabled);case _:
  return null;

}
}

}

/// @nodoc


class LocationUpdated implements LocationEvent {
  const LocationUpdated({required this.location, required this.isMoving});
  

 final  LocationTrackingEvent location;
 final  bool isMoving;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationUpdatedCopyWith<LocationUpdated> get copyWith => _$LocationUpdatedCopyWithImpl<LocationUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationUpdated&&(identical(other.location, location) || other.location == location)&&(identical(other.isMoving, isMoving) || other.isMoving == isMoving));
}


@override
int get hashCode => Object.hash(runtimeType,location,isMoving);

@override
String toString() {
  return 'LocationEvent.locationUpdated(location: $location, isMoving: $isMoving)';
}


}

/// @nodoc
abstract mixin class $LocationUpdatedCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory $LocationUpdatedCopyWith(LocationUpdated value, $Res Function(LocationUpdated) _then) = _$LocationUpdatedCopyWithImpl;
@useResult
$Res call({
 LocationTrackingEvent location, bool isMoving
});




}
/// @nodoc
class _$LocationUpdatedCopyWithImpl<$Res>
    implements $LocationUpdatedCopyWith<$Res> {
  _$LocationUpdatedCopyWithImpl(this._self, this._then);

  final LocationUpdated _self;
  final $Res Function(LocationUpdated) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? location = null,Object? isMoving = null,}) {
  return _then(LocationUpdated(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationTrackingEvent,isMoving: null == isMoving ? _self.isMoving : isMoving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class MotionChanged implements LocationEvent {
  const MotionChanged({required this.motion});
  

 final  MotionChangeEvent motion;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MotionChangedCopyWith<MotionChanged> get copyWith => _$MotionChangedCopyWithImpl<MotionChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MotionChanged&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,motion);

@override
String toString() {
  return 'LocationEvent.motionChanged(motion: $motion)';
}


}

/// @nodoc
abstract mixin class $MotionChangedCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory $MotionChangedCopyWith(MotionChanged value, $Res Function(MotionChanged) _then) = _$MotionChangedCopyWithImpl;
@useResult
$Res call({
 MotionChangeEvent motion
});




}
/// @nodoc
class _$MotionChangedCopyWithImpl<$Res>
    implements $MotionChangedCopyWith<$Res> {
  _$MotionChangedCopyWithImpl(this._self, this._then);

  final MotionChanged _self;
  final $Res Function(MotionChanged) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? motion = null,}) {
  return _then(MotionChanged(
motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionChangeEvent,
  ));
}


}

/// @nodoc


class GeofenceTriggered implements LocationEvent {
  const GeofenceTriggered({required this.geofence});
  

 final  GeofenceEvent geofence;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeofenceTriggeredCopyWith<GeofenceTriggered> get copyWith => _$GeofenceTriggeredCopyWithImpl<GeofenceTriggered>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeofenceTriggered&&(identical(other.geofence, geofence) || other.geofence == geofence));
}


@override
int get hashCode => Object.hash(runtimeType,geofence);

@override
String toString() {
  return 'LocationEvent.geofenceTriggered(geofence: $geofence)';
}


}

/// @nodoc
abstract mixin class $GeofenceTriggeredCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory $GeofenceTriggeredCopyWith(GeofenceTriggered value, $Res Function(GeofenceTriggered) _then) = _$GeofenceTriggeredCopyWithImpl;
@useResult
$Res call({
 GeofenceEvent geofence
});




}
/// @nodoc
class _$GeofenceTriggeredCopyWithImpl<$Res>
    implements $GeofenceTriggeredCopyWith<$Res> {
  _$GeofenceTriggeredCopyWithImpl(this._self, this._then);

  final GeofenceTriggered _self;
  final $Res Function(GeofenceTriggered) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? geofence = null,}) {
  return _then(GeofenceTriggered(
geofence: null == geofence ? _self.geofence : geofence // ignore: cast_nullable_to_non_nullable
as GeofenceEvent,
  ));
}


}

/// @nodoc


class ServiceStatusChanged implements LocationEvent {
  const ServiceStatusChanged({required this.status});
  

 final  LocationServiceStatus status;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceStatusChangedCopyWith<ServiceStatusChanged> get copyWith => _$ServiceStatusChangedCopyWithImpl<ServiceStatusChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceStatusChanged&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'LocationEvent.serviceStatusChanged(status: $status)';
}


}

/// @nodoc
abstract mixin class $ServiceStatusChangedCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory $ServiceStatusChangedCopyWith(ServiceStatusChanged value, $Res Function(ServiceStatusChanged) _then) = _$ServiceStatusChangedCopyWithImpl;
@useResult
$Res call({
 LocationServiceStatus status
});




}
/// @nodoc
class _$ServiceStatusChangedCopyWithImpl<$Res>
    implements $ServiceStatusChangedCopyWith<$Res> {
  _$ServiceStatusChangedCopyWithImpl(this._self, this._then);

  final ServiceStatusChanged _self;
  final $Res Function(ServiceStatusChanged) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(ServiceStatusChanged(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LocationServiceStatus,
  ));
}


}

/// @nodoc


class ServiceEnabledChanged implements LocationEvent {
  const ServiceEnabledChanged({required this.isEnabled});
  

 final  bool isEnabled;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceEnabledChangedCopyWith<ServiceEnabledChanged> get copyWith => _$ServiceEnabledChangedCopyWithImpl<ServiceEnabledChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceEnabledChanged&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,isEnabled);

@override
String toString() {
  return 'LocationEvent.serviceEnabledChanged(isEnabled: $isEnabled)';
}


}

/// @nodoc
abstract mixin class $ServiceEnabledChangedCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory $ServiceEnabledChangedCopyWith(ServiceEnabledChanged value, $Res Function(ServiceEnabledChanged) _then) = _$ServiceEnabledChangedCopyWithImpl;
@useResult
$Res call({
 bool isEnabled
});




}
/// @nodoc
class _$ServiceEnabledChangedCopyWithImpl<$Res>
    implements $ServiceEnabledChangedCopyWith<$Res> {
  _$ServiceEnabledChangedCopyWithImpl(this._self, this._then);

  final ServiceEnabledChanged _self;
  final $Res Function(ServiceEnabledChanged) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? isEnabled = null,}) {
  return _then(ServiceEnabledChanged(
isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
