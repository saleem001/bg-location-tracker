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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LocationUpdated value)?  locationUpdated,TResult Function( _GeofenceTriggered value)?  geofenceTriggered,TResult Function( _MotionChanged value)?  motionChanged,TResult Function( _ServiceStatusChanged value)?  serviceStatusChanged,TResult Function( _ServiceEnabledChanged value)?  serviceEnabledChanged,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationUpdated() when locationUpdated != null:
return locationUpdated(_that);case _GeofenceTriggered() when geofenceTriggered != null:
return geofenceTriggered(_that);case _MotionChanged() when motionChanged != null:
return motionChanged(_that);case _ServiceStatusChanged() when serviceStatusChanged != null:
return serviceStatusChanged(_that);case _ServiceEnabledChanged() when serviceEnabledChanged != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LocationUpdated value)  locationUpdated,required TResult Function( _GeofenceTriggered value)  geofenceTriggered,required TResult Function( _MotionChanged value)  motionChanged,required TResult Function( _ServiceStatusChanged value)  serviceStatusChanged,required TResult Function( _ServiceEnabledChanged value)  serviceEnabledChanged,}){
final _that = this;
switch (_that) {
case _LocationUpdated():
return locationUpdated(_that);case _GeofenceTriggered():
return geofenceTriggered(_that);case _MotionChanged():
return motionChanged(_that);case _ServiceStatusChanged():
return serviceStatusChanged(_that);case _ServiceEnabledChanged():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LocationUpdated value)?  locationUpdated,TResult? Function( _GeofenceTriggered value)?  geofenceTriggered,TResult? Function( _MotionChanged value)?  motionChanged,TResult? Function( _ServiceStatusChanged value)?  serviceStatusChanged,TResult? Function( _ServiceEnabledChanged value)?  serviceEnabledChanged,}){
final _that = this;
switch (_that) {
case _LocationUpdated() when locationUpdated != null:
return locationUpdated(_that);case _GeofenceTriggered() when geofenceTriggered != null:
return geofenceTriggered(_that);case _MotionChanged() when motionChanged != null:
return motionChanged(_that);case _ServiceStatusChanged() when serviceStatusChanged != null:
return serviceStatusChanged(_that);case _ServiceEnabledChanged() when serviceEnabledChanged != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( bg.Location location)?  locationUpdated,TResult Function( bg.GeofenceEvent geofence)?  geofenceTriggered,TResult Function( bg.Location motion)?  motionChanged,TResult Function( bg.ProviderChangeEvent status)?  serviceStatusChanged,TResult Function( bool isEnabled)?  serviceEnabledChanged,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationUpdated() when locationUpdated != null:
return locationUpdated(_that.location);case _GeofenceTriggered() when geofenceTriggered != null:
return geofenceTriggered(_that.geofence);case _MotionChanged() when motionChanged != null:
return motionChanged(_that.motion);case _ServiceStatusChanged() when serviceStatusChanged != null:
return serviceStatusChanged(_that.status);case _ServiceEnabledChanged() when serviceEnabledChanged != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( bg.Location location)  locationUpdated,required TResult Function( bg.GeofenceEvent geofence)  geofenceTriggered,required TResult Function( bg.Location motion)  motionChanged,required TResult Function( bg.ProviderChangeEvent status)  serviceStatusChanged,required TResult Function( bool isEnabled)  serviceEnabledChanged,}) {final _that = this;
switch (_that) {
case _LocationUpdated():
return locationUpdated(_that.location);case _GeofenceTriggered():
return geofenceTriggered(_that.geofence);case _MotionChanged():
return motionChanged(_that.motion);case _ServiceStatusChanged():
return serviceStatusChanged(_that.status);case _ServiceEnabledChanged():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( bg.Location location)?  locationUpdated,TResult? Function( bg.GeofenceEvent geofence)?  geofenceTriggered,TResult? Function( bg.Location motion)?  motionChanged,TResult? Function( bg.ProviderChangeEvent status)?  serviceStatusChanged,TResult? Function( bool isEnabled)?  serviceEnabledChanged,}) {final _that = this;
switch (_that) {
case _LocationUpdated() when locationUpdated != null:
return locationUpdated(_that.location);case _GeofenceTriggered() when geofenceTriggered != null:
return geofenceTriggered(_that.geofence);case _MotionChanged() when motionChanged != null:
return motionChanged(_that.motion);case _ServiceStatusChanged() when serviceStatusChanged != null:
return serviceStatusChanged(_that.status);case _ServiceEnabledChanged() when serviceEnabledChanged != null:
return serviceEnabledChanged(_that.isEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _LocationUpdated implements LocationEvent {
  const _LocationUpdated(this.location);
  

 final  bg.Location location;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationUpdatedCopyWith<_LocationUpdated> get copyWith => __$LocationUpdatedCopyWithImpl<_LocationUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationUpdated&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode => Object.hash(runtimeType,location);

@override
String toString() {
  return 'LocationEvent.locationUpdated(location: $location)';
}


}

/// @nodoc
abstract mixin class _$LocationUpdatedCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory _$LocationUpdatedCopyWith(_LocationUpdated value, $Res Function(_LocationUpdated) _then) = __$LocationUpdatedCopyWithImpl;
@useResult
$Res call({
 bg.Location location
});




}
/// @nodoc
class __$LocationUpdatedCopyWithImpl<$Res>
    implements _$LocationUpdatedCopyWith<$Res> {
  __$LocationUpdatedCopyWithImpl(this._self, this._then);

  final _LocationUpdated _self;
  final $Res Function(_LocationUpdated) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? location = null,}) {
  return _then(_LocationUpdated(
null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as bg.Location,
  ));
}


}

/// @nodoc


class _GeofenceTriggered implements LocationEvent {
  const _GeofenceTriggered(this.geofence);
  

 final  bg.GeofenceEvent geofence;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeofenceTriggeredCopyWith<_GeofenceTriggered> get copyWith => __$GeofenceTriggeredCopyWithImpl<_GeofenceTriggered>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeofenceTriggered&&(identical(other.geofence, geofence) || other.geofence == geofence));
}


@override
int get hashCode => Object.hash(runtimeType,geofence);

@override
String toString() {
  return 'LocationEvent.geofenceTriggered(geofence: $geofence)';
}


}

/// @nodoc
abstract mixin class _$GeofenceTriggeredCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory _$GeofenceTriggeredCopyWith(_GeofenceTriggered value, $Res Function(_GeofenceTriggered) _then) = __$GeofenceTriggeredCopyWithImpl;
@useResult
$Res call({
 bg.GeofenceEvent geofence
});




}
/// @nodoc
class __$GeofenceTriggeredCopyWithImpl<$Res>
    implements _$GeofenceTriggeredCopyWith<$Res> {
  __$GeofenceTriggeredCopyWithImpl(this._self, this._then);

  final _GeofenceTriggered _self;
  final $Res Function(_GeofenceTriggered) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? geofence = null,}) {
  return _then(_GeofenceTriggered(
null == geofence ? _self.geofence : geofence // ignore: cast_nullable_to_non_nullable
as bg.GeofenceEvent,
  ));
}


}

/// @nodoc


class _MotionChanged implements LocationEvent {
  const _MotionChanged(this.motion);
  

 final  bg.Location motion;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MotionChangedCopyWith<_MotionChanged> get copyWith => __$MotionChangedCopyWithImpl<_MotionChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MotionChanged&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,motion);

@override
String toString() {
  return 'LocationEvent.motionChanged(motion: $motion)';
}


}

/// @nodoc
abstract mixin class _$MotionChangedCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory _$MotionChangedCopyWith(_MotionChanged value, $Res Function(_MotionChanged) _then) = __$MotionChangedCopyWithImpl;
@useResult
$Res call({
 bg.Location motion
});




}
/// @nodoc
class __$MotionChangedCopyWithImpl<$Res>
    implements _$MotionChangedCopyWith<$Res> {
  __$MotionChangedCopyWithImpl(this._self, this._then);

  final _MotionChanged _self;
  final $Res Function(_MotionChanged) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? motion = null,}) {
  return _then(_MotionChanged(
null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as bg.Location,
  ));
}


}

/// @nodoc


class _ServiceStatusChanged implements LocationEvent {
  const _ServiceStatusChanged(this.status);
  

 final  bg.ProviderChangeEvent status;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceStatusChangedCopyWith<_ServiceStatusChanged> get copyWith => __$ServiceStatusChangedCopyWithImpl<_ServiceStatusChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceStatusChanged&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'LocationEvent.serviceStatusChanged(status: $status)';
}


}

/// @nodoc
abstract mixin class _$ServiceStatusChangedCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory _$ServiceStatusChangedCopyWith(_ServiceStatusChanged value, $Res Function(_ServiceStatusChanged) _then) = __$ServiceStatusChangedCopyWithImpl;
@useResult
$Res call({
 bg.ProviderChangeEvent status
});




}
/// @nodoc
class __$ServiceStatusChangedCopyWithImpl<$Res>
    implements _$ServiceStatusChangedCopyWith<$Res> {
  __$ServiceStatusChangedCopyWithImpl(this._self, this._then);

  final _ServiceStatusChanged _self;
  final $Res Function(_ServiceStatusChanged) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(_ServiceStatusChanged(
null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as bg.ProviderChangeEvent,
  ));
}


}

/// @nodoc


class _ServiceEnabledChanged implements LocationEvent {
  const _ServiceEnabledChanged(this.isEnabled);
  

 final  bool isEnabled;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceEnabledChangedCopyWith<_ServiceEnabledChanged> get copyWith => __$ServiceEnabledChangedCopyWithImpl<_ServiceEnabledChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceEnabledChanged&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,isEnabled);

@override
String toString() {
  return 'LocationEvent.serviceEnabledChanged(isEnabled: $isEnabled)';
}


}

/// @nodoc
abstract mixin class _$ServiceEnabledChangedCopyWith<$Res> implements $LocationEventCopyWith<$Res> {
  factory _$ServiceEnabledChangedCopyWith(_ServiceEnabledChanged value, $Res Function(_ServiceEnabledChanged) _then) = __$ServiceEnabledChangedCopyWithImpl;
@useResult
$Res call({
 bool isEnabled
});




}
/// @nodoc
class __$ServiceEnabledChangedCopyWithImpl<$Res>
    implements _$ServiceEnabledChangedCopyWith<$Res> {
  __$ServiceEnabledChangedCopyWithImpl(this._self, this._then);

  final _ServiceEnabledChanged _self;
  final $Res Function(_ServiceEnabledChanged) _then;

/// Create a copy of LocationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? isEnabled = null,}) {
  return _then(_ServiceEnabledChanged(
null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
