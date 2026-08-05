// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assign_case_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssignCaseRequest {

 String get userId; CaseAccessLevel get accessLevel;
/// Create a copy of AssignCaseRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignCaseRequestCopyWith<AssignCaseRequest> get copyWith => _$AssignCaseRequestCopyWithImpl<AssignCaseRequest>(this as AssignCaseRequest, _$identity);

  /// Serializes this AssignCaseRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignCaseRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.accessLevel, accessLevel) || other.accessLevel == accessLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,accessLevel);

@override
String toString() {
  return 'AssignCaseRequest(userId: $userId, accessLevel: $accessLevel)';
}


}

/// @nodoc
abstract mixin class $AssignCaseRequestCopyWith<$Res>  {
  factory $AssignCaseRequestCopyWith(AssignCaseRequest value, $Res Function(AssignCaseRequest) _then) = _$AssignCaseRequestCopyWithImpl;
@useResult
$Res call({
 String userId, CaseAccessLevel accessLevel
});




}
/// @nodoc
class _$AssignCaseRequestCopyWithImpl<$Res>
    implements $AssignCaseRequestCopyWith<$Res> {
  _$AssignCaseRequestCopyWithImpl(this._self, this._then);

  final AssignCaseRequest _self;
  final $Res Function(AssignCaseRequest) _then;

/// Create a copy of AssignCaseRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? accessLevel = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,accessLevel: null == accessLevel ? _self.accessLevel : accessLevel // ignore: cast_nullable_to_non_nullable
as CaseAccessLevel,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignCaseRequest].
extension AssignCaseRequestPatterns on AssignCaseRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignCaseRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignCaseRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignCaseRequest value)  $default,){
final _that = this;
switch (_that) {
case _AssignCaseRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignCaseRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AssignCaseRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  CaseAccessLevel accessLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignCaseRequest() when $default != null:
return $default(_that.userId,_that.accessLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  CaseAccessLevel accessLevel)  $default,) {final _that = this;
switch (_that) {
case _AssignCaseRequest():
return $default(_that.userId,_that.accessLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  CaseAccessLevel accessLevel)?  $default,) {final _that = this;
switch (_that) {
case _AssignCaseRequest() when $default != null:
return $default(_that.userId,_that.accessLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssignCaseRequest implements AssignCaseRequest {
  const _AssignCaseRequest({required this.userId, required this.accessLevel});
  factory _AssignCaseRequest.fromJson(Map<String, dynamic> json) => _$AssignCaseRequestFromJson(json);

@override final  String userId;
@override final  CaseAccessLevel accessLevel;

/// Create a copy of AssignCaseRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignCaseRequestCopyWith<_AssignCaseRequest> get copyWith => __$AssignCaseRequestCopyWithImpl<_AssignCaseRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignCaseRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignCaseRequest&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.accessLevel, accessLevel) || other.accessLevel == accessLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,accessLevel);

@override
String toString() {
  return 'AssignCaseRequest(userId: $userId, accessLevel: $accessLevel)';
}


}

/// @nodoc
abstract mixin class _$AssignCaseRequestCopyWith<$Res> implements $AssignCaseRequestCopyWith<$Res> {
  factory _$AssignCaseRequestCopyWith(_AssignCaseRequest value, $Res Function(_AssignCaseRequest) _then) = __$AssignCaseRequestCopyWithImpl;
@override @useResult
$Res call({
 String userId, CaseAccessLevel accessLevel
});




}
/// @nodoc
class __$AssignCaseRequestCopyWithImpl<$Res>
    implements _$AssignCaseRequestCopyWith<$Res> {
  __$AssignCaseRequestCopyWithImpl(this._self, this._then);

  final _AssignCaseRequest _self;
  final $Res Function(_AssignCaseRequest) _then;

/// Create a copy of AssignCaseRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? accessLevel = null,}) {
  return _then(_AssignCaseRequest(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,accessLevel: null == accessLevel ? _self.accessLevel : accessLevel // ignore: cast_nullable_to_non_nullable
as CaseAccessLevel,
  ));
}


}

// dart format on
