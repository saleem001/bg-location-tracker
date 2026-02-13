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

 LocationTrackingEvent? get location; MotionChangeEvent? get motion; GeofenceEvent? get geofence; LocationServiceStatus? get serviceStatus;// Service & motion
 bool get isServiceEnabled; bool get isStationary; bool get isMoving; bool get isLoading;// Trip info
 TripState? get activeTrip;// Current location tracking
 LocationTrackingEvent? get currentLocation; List<LocationTrackingEvent> get locationHistory; double get speedKmh;// Misc
 LocationTrackingEvent? get pendingDestination; String? get lastActivity; String? get error;
/// Create a copy of LocationAppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationAppStateCopyWith<LocationAppState> get copyWith => _$LocationAppStateCopyWithImpl<LocationAppState>(this as LocationAppState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationAppState&&(identical(other.location, location) || other.location == location)&&(identical(other.motion, motion) || other.motion == motion)&&(identical(other.geofence, geofence) || other.geofence == geofence)&&(identical(other.serviceStatus, serviceStatus) || other.serviceStatus == serviceStatus)&&(identical(other.isServiceEnabled, isServiceEnabled) || other.isServiceEnabled == isServiceEnabled)&&(identical(other.isStationary, isStationary) || other.isStationary == isStationary)&&(identical(other.isMoving, isMoving) || other.isMoving == isMoving)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.activeTrip, activeTrip) || other.activeTrip == activeTrip)&&(identical(other.currentLocation, currentLocation) || other.currentLocation == currentLocation)&&const DeepCollectionEquality().equals(other.locationHistory, locationHistory)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.pendingDestination, pendingDestination) || other.pendingDestination == pendingDestination)&&(identical(other.lastActivity, lastActivity) || other.lastActivity == lastActivity)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,location,motion,geofence,serviceStatus,isServiceEnabled,isStationary,isMoving,isLoading,activeTrip,currentLocation,const DeepCollectionEquality().hash(locationHistory),speedKmh,pendingDestination,lastActivity,error);

@override
String toString() {
  return 'LocationAppState(location: $location, motion: $motion, geofence: $geofence, serviceStatus: $serviceStatus, isServiceEnabled: $isServiceEnabled, isStationary: $isStationary, isMoving: $isMoving, isLoading: $isLoading, activeTrip: $activeTrip, currentLocation: $currentLocation, locationHistory: $locationHistory, speedKmh: $speedKmh, pendingDestination: $pendingDestination, lastActivity: $lastActivity, error: $error)';
}


}

/// @nodoc
abstract mixin class $LocationAppStateCopyWith<$Res>  {
  factory $LocationAppStateCopyWith(LocationAppState value, $Res Function(LocationAppState) _then) = _$LocationAppStateCopyWithImpl;
@useResult
$Res call({
 LocationTrackingEvent? location, MotionChangeEvent? motion, GeofenceEvent? geofence, LocationServiceStatus? serviceStatus, bool isServiceEnabled, bool isStationary, bool isMoving, bool isLoading, TripState? activeTrip, LocationTrackingEvent? currentLocation, List<LocationTrackingEvent> locationHistory, double speedKmh, LocationTrackingEvent? pendingDestination, String? lastActivity, String? error
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
@pragma('vm:prefer-inline') @override $Res call({Object? location = freezed,Object? motion = freezed,Object? geofence = freezed,Object? serviceStatus = freezed,Object? isServiceEnabled = null,Object? isStationary = null,Object? isMoving = null,Object? isLoading = null,Object? activeTrip = freezed,Object? currentLocation = freezed,Object? locationHistory = null,Object? speedKmh = null,Object? pendingDestination = freezed,Object? lastActivity = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationTrackingEvent?,motion: freezed == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionChangeEvent?,geofence: freezed == geofence ? _self.geofence : geofence // ignore: cast_nullable_to_non_nullable
as GeofenceEvent?,serviceStatus: freezed == serviceStatus ? _self.serviceStatus : serviceStatus // ignore: cast_nullable_to_non_nullable
as LocationServiceStatus?,isServiceEnabled: null == isServiceEnabled ? _self.isServiceEnabled : isServiceEnabled // ignore: cast_nullable_to_non_nullable
as bool,isStationary: null == isStationary ? _self.isStationary : isStationary // ignore: cast_nullable_to_non_nullable
as bool,isMoving: null == isMoving ? _self.isMoving : isMoving // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,activeTrip: freezed == activeTrip ? _self.activeTrip : activeTrip // ignore: cast_nullable_to_non_nullable
as TripState?,currentLocation: freezed == currentLocation ? _self.currentLocation : currentLocation // ignore: cast_nullable_to_non_nullable
as LocationTrackingEvent?,locationHistory: null == locationHistory ? _self.locationHistory : locationHistory // ignore: cast_nullable_to_non_nullable
as List<LocationTrackingEvent>,speedKmh: null == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double,pendingDestination: freezed == pendingDestination ? _self.pendingDestination : pendingDestination // ignore: cast_nullable_to_non_nullable
as LocationTrackingEvent?,lastActivity: freezed == lastActivity ? _self.lastActivity : lastActivity // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LocationTrackingEvent? location,  MotionChangeEvent? motion,  GeofenceEvent? geofence,  LocationServiceStatus? serviceStatus,  bool isServiceEnabled,  bool isStationary,  bool isMoving,  bool isLoading,  TripState? activeTrip,  LocationTrackingEvent? currentLocation,  List<LocationTrackingEvent> locationHistory,  double speedKmh,  LocationTrackingEvent? pendingDestination,  String? lastActivity,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationAppState() when $default != null:
return $default(_that.location,_that.motion,_that.geofence,_that.serviceStatus,_that.isServiceEnabled,_that.isStationary,_that.isMoving,_that.isLoading,_that.activeTrip,_that.currentLocation,_that.locationHistory,_that.speedKmh,_that.pendingDestination,_that.lastActivity,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LocationTrackingEvent? location,  MotionChangeEvent? motion,  GeofenceEvent? geofence,  LocationServiceStatus? serviceStatus,  bool isServiceEnabled,  bool isStationary,  bool isMoving,  bool isLoading,  TripState? activeTrip,  LocationTrackingEvent? currentLocation,  List<LocationTrackingEvent> locationHistory,  double speedKmh,  LocationTrackingEvent? pendingDestination,  String? lastActivity,  String? error)  $default,) {final _that = this;
switch (_that) {
case _LocationAppState():
return $default(_that.location,_that.motion,_that.geofence,_that.serviceStatus,_that.isServiceEnabled,_that.isStationary,_that.isMoving,_that.isLoading,_that.activeTrip,_that.currentLocation,_that.locationHistory,_that.speedKmh,_that.pendingDestination,_that.lastActivity,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LocationTrackingEvent? location,  MotionChangeEvent? motion,  GeofenceEvent? geofence,  LocationServiceStatus? serviceStatus,  bool isServiceEnabled,  bool isStationary,  bool isMoving,  bool isLoading,  TripState? activeTrip,  LocationTrackingEvent? currentLocation,  List<LocationTrackingEvent> locationHistory,  double speedKmh,  LocationTrackingEvent? pendingDestination,  String? lastActivity,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _LocationAppState() when $default != null:
return $default(_that.location,_that.motion,_that.geofence,_that.serviceStatus,_that.isServiceEnabled,_that.isStationary,_that.isMoving,_that.isLoading,_that.activeTrip,_that.currentLocation,_that.locationHistory,_that.speedKmh,_that.pendingDestination,_that.lastActivity,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _LocationAppState implements LocationAppState {
  const _LocationAppState({this.location, this.motion, this.geofence, this.serviceStatus, this.isServiceEnabled = false, this.isStationary = true, this.isMoving = false, this.isLoading = false, this.activeTrip, this.currentLocation, final  List<LocationTrackingEvent> locationHistory = const [], this.speedKmh = 0.0, this.pendingDestination, this.lastActivity, this.error}): _locationHistory = locationHistory;
  

@override final  LocationTrackingEvent? location;
@override final  MotionChangeEvent? motion;
@override final  GeofenceEvent? geofence;
@override final  LocationServiceStatus? serviceStatus;
// Service & motion
@override@JsonKey() final  bool isServiceEnabled;
@override@JsonKey() final  bool isStationary;
@override@JsonKey() final  bool isMoving;
@override@JsonKey() final  bool isLoading;
// Trip info
@override final  TripState? activeTrip;
// Current location tracking
@override final  LocationTrackingEvent? currentLocation;
 final  List<LocationTrackingEvent> _locationHistory;
@override@JsonKey() List<LocationTrackingEvent> get locationHistory {
  if (_locationHistory is EqualUnmodifiableListView) return _locationHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locationHistory);
}

@override@JsonKey() final  double speedKmh;
// Misc
@override final  LocationTrackingEvent? pendingDestination;
@override final  String? lastActivity;
@override final  String? error;

/// Create a copy of LocationAppState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationAppStateCopyWith<_LocationAppState> get copyWith => __$LocationAppStateCopyWithImpl<_LocationAppState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationAppState&&(identical(other.location, location) || other.location == location)&&(identical(other.motion, motion) || other.motion == motion)&&(identical(other.geofence, geofence) || other.geofence == geofence)&&(identical(other.serviceStatus, serviceStatus) || other.serviceStatus == serviceStatus)&&(identical(other.isServiceEnabled, isServiceEnabled) || other.isServiceEnabled == isServiceEnabled)&&(identical(other.isStationary, isStationary) || other.isStationary == isStationary)&&(identical(other.isMoving, isMoving) || other.isMoving == isMoving)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.activeTrip, activeTrip) || other.activeTrip == activeTrip)&&(identical(other.currentLocation, currentLocation) || other.currentLocation == currentLocation)&&const DeepCollectionEquality().equals(other._locationHistory, _locationHistory)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.pendingDestination, pendingDestination) || other.pendingDestination == pendingDestination)&&(identical(other.lastActivity, lastActivity) || other.lastActivity == lastActivity)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,location,motion,geofence,serviceStatus,isServiceEnabled,isStationary,isMoving,isLoading,activeTrip,currentLocation,const DeepCollectionEquality().hash(_locationHistory),speedKmh,pendingDestination,lastActivity,error);

@override
String toString() {
  return 'LocationAppState(location: $location, motion: $motion, geofence: $geofence, serviceStatus: $serviceStatus, isServiceEnabled: $isServiceEnabled, isStationary: $isStationary, isMoving: $isMoving, isLoading: $isLoading, activeTrip: $activeTrip, currentLocation: $currentLocation, locationHistory: $locationHistory, speedKmh: $speedKmh, pendingDestination: $pendingDestination, lastActivity: $lastActivity, error: $error)';
}


}

/// @nodoc
abstract mixin class _$LocationAppStateCopyWith<$Res> implements $LocationAppStateCopyWith<$Res> {
  factory _$LocationAppStateCopyWith(_LocationAppState value, $Res Function(_LocationAppState) _then) = __$LocationAppStateCopyWithImpl;
@override @useResult
$Res call({
 LocationTrackingEvent? location, MotionChangeEvent? motion, GeofenceEvent? geofence, LocationServiceStatus? serviceStatus, bool isServiceEnabled, bool isStationary, bool isMoving, bool isLoading, TripState? activeTrip, LocationTrackingEvent? currentLocation, List<LocationTrackingEvent> locationHistory, double speedKmh, LocationTrackingEvent? pendingDestination, String? lastActivity, String? error
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
@override @pragma('vm:prefer-inline') $Res call({Object? location = freezed,Object? motion = freezed,Object? geofence = freezed,Object? serviceStatus = freezed,Object? isServiceEnabled = null,Object? isStationary = null,Object? isMoving = null,Object? isLoading = null,Object? activeTrip = freezed,Object? currentLocation = freezed,Object? locationHistory = null,Object? speedKmh = null,Object? pendingDestination = freezed,Object? lastActivity = freezed,Object? error = freezed,}) {
  return _then(_LocationAppState(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationTrackingEvent?,motion: freezed == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionChangeEvent?,geofence: freezed == geofence ? _self.geofence : geofence // ignore: cast_nullable_to_non_nullable
as GeofenceEvent?,serviceStatus: freezed == serviceStatus ? _self.serviceStatus : serviceStatus // ignore: cast_nullable_to_non_nullable
as LocationServiceStatus?,isServiceEnabled: null == isServiceEnabled ? _self.isServiceEnabled : isServiceEnabled // ignore: cast_nullable_to_non_nullable
as bool,isStationary: null == isStationary ? _self.isStationary : isStationary // ignore: cast_nullable_to_non_nullable
as bool,isMoving: null == isMoving ? _self.isMoving : isMoving // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,activeTrip: freezed == activeTrip ? _self.activeTrip : activeTrip // ignore: cast_nullable_to_non_nullable
as TripState?,currentLocation: freezed == currentLocation ? _self.currentLocation : currentLocation // ignore: cast_nullable_to_non_nullable
as LocationTrackingEvent?,locationHistory: null == locationHistory ? _self._locationHistory : locationHistory // ignore: cast_nullable_to_non_nullable
as List<LocationTrackingEvent>,speedKmh: null == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double,pendingDestination: freezed == pendingDestination ? _self.pendingDestination : pendingDestination // ignore: cast_nullable_to_non_nullable
as LocationTrackingEvent?,lastActivity: freezed == lastActivity ? _self.lastActivity : lastActivity // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
