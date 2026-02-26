// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_service_manager_config_types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocationServiceManagerConfigType {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationServiceManagerConfigType);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocationServiceManagerConfigType()';
}


}

/// @nodoc
class $LocationServiceManagerConfigTypeCopyWith<$Res>  {
$LocationServiceManagerConfigTypeCopyWith(LocationServiceManagerConfigType _, $Res Function(LocationServiceManagerConfigType) __);
}


/// Adds pattern-matching-related methods to [LocationServiceManagerConfigType].
extension LocationServiceManagerConfigTypePatterns on LocationServiceManagerConfigType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Low value)?  low,TResult Function( _High value)?  high,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Low() when low != null:
return low(_that);case _High() when high != null:
return high(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Low value)  low,required TResult Function( _High value)  high,}){
final _that = this;
switch (_that) {
case _Low():
return low(_that);case _High():
return high(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Low value)?  low,TResult? Function( _High value)?  high,}){
final _that = this;
switch (_that) {
case _Low() when low != null:
return low(_that);case _High() when high != null:
return high(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  low,TResult Function( String notificationTitle,  String notificationMessage)?  high,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Low() when low != null:
return low();case _High() when high != null:
return high(_that.notificationTitle,_that.notificationMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  low,required TResult Function( String notificationTitle,  String notificationMessage)  high,}) {final _that = this;
switch (_that) {
case _Low():
return low();case _High():
return high(_that.notificationTitle,_that.notificationMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  low,TResult? Function( String notificationTitle,  String notificationMessage)?  high,}) {final _that = this;
switch (_that) {
case _Low() when low != null:
return low();case _High() when high != null:
return high(_that.notificationTitle,_that.notificationMessage);case _:
  return null;

}
}

}

/// @nodoc


class _Low extends LocationServiceManagerConfigType {
  const _Low(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Low);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocationServiceManagerConfigType.low()';
}


}




/// @nodoc


class _High extends LocationServiceManagerConfigType {
  const _High({required this.notificationTitle, required this.notificationMessage}): super._();
  

 final  String notificationTitle;
 final  String notificationMessage;

/// Create a copy of LocationServiceManagerConfigType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HighCopyWith<_High> get copyWith => __$HighCopyWithImpl<_High>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _High&&(identical(other.notificationTitle, notificationTitle) || other.notificationTitle == notificationTitle)&&(identical(other.notificationMessage, notificationMessage) || other.notificationMessage == notificationMessage));
}


@override
int get hashCode => Object.hash(runtimeType,notificationTitle,notificationMessage);

@override
String toString() {
  return 'LocationServiceManagerConfigType.high(notificationTitle: $notificationTitle, notificationMessage: $notificationMessage)';
}


}

/// @nodoc
abstract mixin class _$HighCopyWith<$Res> implements $LocationServiceManagerConfigTypeCopyWith<$Res> {
  factory _$HighCopyWith(_High value, $Res Function(_High) _then) = __$HighCopyWithImpl;
@useResult
$Res call({
 String notificationTitle, String notificationMessage
});




}
/// @nodoc
class __$HighCopyWithImpl<$Res>
    implements _$HighCopyWith<$Res> {
  __$HighCopyWithImpl(this._self, this._then);

  final _High _self;
  final $Res Function(_High) _then;

/// Create a copy of LocationServiceManagerConfigType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? notificationTitle = null,Object? notificationMessage = null,}) {
  return _then(_High(
notificationTitle: null == notificationTitle ? _self.notificationTitle : notificationTitle // ignore: cast_nullable_to_non_nullable
as String,notificationMessage: null == notificationMessage ? _self.notificationMessage : notificationMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
