// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_app_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocationAppState {

 LocationTrackingEvent? get location; MotionChangeEvent? get motion; GeofenceEvent? get geofence; LocationServiceStatusEvent? get serviceStatus;
/// Create a copy of LocationAppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationAppStateCopyWith<LocationAppState> get copyWith => _$LocationAppStateCopyWithImpl<LocationAppState>(this as LocationAppState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationAppState&&(identical(other.location, location) || other.location == location)&&(identical(other.motion, motion) || other.motion == motion)&&(identical(other.geofence, geofence) || other.geofence == geofence)&&(identical(other.serviceStatus, serviceStatus) || other.serviceStatus == serviceStatus));
}


@override
int get hashCode => Object.hash(runtimeType,location,motion,geofence,serviceStatus);

@override
String toString() {
  return 'LocationAppState(location: $location, motion: $motion, geofence: $geofence, serviceStatus: $serviceStatus)';
}


}

/// @nodoc
abstract mixin class $LocationAppStateCopyWith<$Res>  {
  factory $LocationAppStateCopyWith(LocationAppState value, $Res Function(LocationAppState) _then) = _$LocationAppStateCopyWithImpl;
@useResult
$Res call({
 LocationTrackingEvent? location, MotionChangeEvent? motion, GeofenceEvent? geofence, LocationServiceStatusEvent? serviceStatus
});




}
/// @nodoc
class _$LocationAppStateCopyWithImpl<$Res>
    implements $LocationAppStateCopyWith<$Res> {
  _$LocationAppStateCopyWithImpl(this._self, this._then);

  final LocationAppState _self;
  final $Res Function(LocationAppState) _then;

/// Create a copy of LocationAppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = freezed,Object? motion = freezed,Object? geofence = freezed,Object? serviceStatus = freezed,}) {
  return _then(_self.copyWith(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationTrackingEvent?,motion: freezed == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionChangeEvent?,geofence: freezed == geofence ? _self.geofence : geofence // ignore: cast_nullable_to_non_nullable
as GeofenceEvent?,serviceStatus: freezed == serviceStatus ? _self.serviceStatus : serviceStatus // ignore: cast_nullable_to_non_nullable
as LocationServiceStatusEvent?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationAppState].
extension LocationAppStatePatterns on LocationAppState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationAppState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationAppState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationAppState value)  $default,){
final _that = this;
switch (_that) {
case _LocationAppState():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationAppState value)?  $default,){
final _that = this;
switch (_that) {
case _LocationAppState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocationTrackingEvent? location,  MotionChangeEvent? motion,  GeofenceEvent? geofence,  LocationServiceStatusEvent? serviceStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationAppState() when $default != null:
return $default(_that.location,_that.motion,_that.geofence,_that.serviceStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocationTrackingEvent? location,  MotionChangeEvent? motion,  GeofenceEvent? geofence,  LocationServiceStatusEvent? serviceStatus)  $default,) {final _that = this;
switch (_that) {
case _LocationAppState():
return $default(_that.location,_that.motion,_that.geofence,_that.serviceStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocationTrackingEvent? location,  MotionChangeEvent? motion,  GeofenceEvent? geofence,  LocationServiceStatusEvent? serviceStatus)?  $default,) {final _that = this;
switch (_that) {
case _LocationAppState() when $default != null:
return $default(_that.location,_that.motion,_that.geofence,_that.serviceStatus);case _:
  return null;

}
}

}

/// @nodoc


class _LocationAppState implements LocationAppState {
  const _LocationAppState({this.location, this.motion, this.geofence, this.serviceStatus});
  

@override final  LocationTrackingEvent? location;
@override final  MotionChangeEvent? motion;
@override final  GeofenceEvent? geofence;
@override final  LocationServiceStatusEvent? serviceStatus;

/// Create a copy of LocationAppState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationAppStateCopyWith<_LocationAppState> get copyWith => __$LocationAppStateCopyWithImpl<_LocationAppState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationAppState&&(identical(other.location, location) || other.location == location)&&(identical(other.motion, motion) || other.motion == motion)&&(identical(other.geofence, geofence) || other.geofence == geofence)&&(identical(other.serviceStatus, serviceStatus) || other.serviceStatus == serviceStatus));
}


@override
int get hashCode => Object.hash(runtimeType,location,motion,geofence,serviceStatus);

@override
String toString() {
  return 'LocationAppState(location: $location, motion: $motion, geofence: $geofence, serviceStatus: $serviceStatus)';
}


}

/// @nodoc
abstract mixin class _$LocationAppStateCopyWith<$Res> implements $LocationAppStateCopyWith<$Res> {
  factory _$LocationAppStateCopyWith(_LocationAppState value, $Res Function(_LocationAppState) _then) = __$LocationAppStateCopyWithImpl;
@override @useResult
$Res call({
 LocationTrackingEvent? location, MotionChangeEvent? motion, GeofenceEvent? geofence, LocationServiceStatusEvent? serviceStatus
});




}
/// @nodoc
class __$LocationAppStateCopyWithImpl<$Res>
    implements _$LocationAppStateCopyWith<$Res> {
  __$LocationAppStateCopyWithImpl(this._self, this._then);

  final _LocationAppState _self;
  final $Res Function(_LocationAppState) _then;

/// Create a copy of LocationAppState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = freezed,Object? motion = freezed,Object? geofence = freezed,Object? serviceStatus = freezed,}) {
  return _then(_LocationAppState(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationTrackingEvent?,motion: freezed == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionChangeEvent?,geofence: freezed == geofence ? _self.geofence : geofence // ignore: cast_nullable_to_non_nullable
as GeofenceEvent?,serviceStatus: freezed == serviceStatus ? _self.serviceStatus : serviceStatus // ignore: cast_nullable_to_non_nullable
as LocationServiceStatusEvent?,
  ));
}


}

// dart format on
