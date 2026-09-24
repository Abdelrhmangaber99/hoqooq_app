// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_task_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateTaskRequest {

@JsonKey(includeIfNull: false) TaskStatus? get status;
/// Create a copy of UpdateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateTaskRequestCopyWith<UpdateTaskRequest> get copyWith => _$UpdateTaskRequestCopyWithImpl<UpdateTaskRequest>(this as UpdateTaskRequest, _$identity);

  /// Serializes this UpdateTaskRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateTaskRequest&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'UpdateTaskRequest(status: $status)';
}


}

/// @nodoc
abstract mixin class $UpdateTaskRequestCopyWith<$Res>  {
  factory $UpdateTaskRequestCopyWith(UpdateTaskRequest value, $Res Function(UpdateTaskRequest) _then) = _$UpdateTaskRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) TaskStatus? status
});




}
/// @nodoc
class _$UpdateTaskRequestCopyWithImpl<$Res>
    implements $UpdateTaskRequestCopyWith<$Res> {
  _$UpdateTaskRequestCopyWithImpl(this._self, this._then);

  final UpdateTaskRequest _self;
  final $Res Function(UpdateTaskRequest) _then;

/// Create a copy of UpdateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateTaskRequest].
extension UpdateTaskRequestPatterns on UpdateTaskRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateTaskRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateTaskRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateTaskRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateTaskRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateTaskRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateTaskRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  TaskStatus? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateTaskRequest() when $default != null:
return $default(_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  TaskStatus? status)  $default,) {final _that = this;
switch (_that) {
case _UpdateTaskRequest():
return $default(_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  TaskStatus? status)?  $default,) {final _that = this;
switch (_that) {
case _UpdateTaskRequest() when $default != null:
return $default(_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateTaskRequest implements UpdateTaskRequest {
  const _UpdateTaskRequest({@JsonKey(includeIfNull: false) this.status});
  factory _UpdateTaskRequest.fromJson(Map<String, dynamic> json) => _$UpdateTaskRequestFromJson(json);

@override@JsonKey(includeIfNull: false) final  TaskStatus? status;

/// Create a copy of UpdateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateTaskRequestCopyWith<_UpdateTaskRequest> get copyWith => __$UpdateTaskRequestCopyWithImpl<_UpdateTaskRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateTaskRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateTaskRequest&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'UpdateTaskRequest(status: $status)';
}


}

/// @nodoc
abstract mixin class _$UpdateTaskRequestCopyWith<$Res> implements $UpdateTaskRequestCopyWith<$Res> {
  factory _$UpdateTaskRequestCopyWith(_UpdateTaskRequest value, $Res Function(_UpdateTaskRequest) _then) = __$UpdateTaskRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) TaskStatus? status
});




}
/// @nodoc
class __$UpdateTaskRequestCopyWithImpl<$Res>
    implements _$UpdateTaskRequestCopyWith<$Res> {
  __$UpdateTaskRequestCopyWithImpl(this._self, this._then);

  final _UpdateTaskRequest _self;
  final $Res Function(_UpdateTaskRequest) _then;

/// Create a copy of UpdateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,}) {
  return _then(_UpdateTaskRequest(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus?,
  ));
}


}

// dart format on
