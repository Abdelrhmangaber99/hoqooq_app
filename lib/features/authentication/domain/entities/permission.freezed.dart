// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'permission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Permission {

 String get id; String get code;
/// Create a copy of Permission
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PermissionCopyWith<Permission> get copyWith => _$PermissionCopyWithImpl<Permission>(this as Permission, _$identity);

  /// Serializes this Permission to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Permission&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code);

@override
String toString() {
  return 'Permission(id: $id, code: $code)';
}


}

/// @nodoc
abstract mixin class $PermissionCopyWith<$Res>  {
  factory $PermissionCopyWith(Permission value, $Res Function(Permission) _then) = _$PermissionCopyWithImpl;
@useResult
$Res call({
 String id, String code
});




}
/// @nodoc
class _$PermissionCopyWithImpl<$Res>
    implements $PermissionCopyWith<$Res> {
  _$PermissionCopyWithImpl(this._self, this._then);

  final Permission _self;
  final $Res Function(Permission) _then;

/// Create a copy of Permission
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Permission].
extension PermissionPatterns on Permission {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Permission value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Permission() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Permission value)  $default,){
final _that = this;
switch (_that) {
case _Permission():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Permission value)?  $default,){
final _that = this;
switch (_that) {
case _Permission() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Permission() when $default != null:
return $default(_that.id,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code)  $default,) {final _that = this;
switch (_that) {
case _Permission():
return $default(_that.id,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code)?  $default,) {final _that = this;
switch (_that) {
case _Permission() when $default != null:
return $default(_that.id,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Permission implements Permission {
  const _Permission({required this.id, required this.code});
  factory _Permission.fromJson(Map<String, dynamic> json) => _$PermissionFromJson(json);

@override final  String id;
@override final  String code;

/// Create a copy of Permission
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PermissionCopyWith<_Permission> get copyWith => __$PermissionCopyWithImpl<_Permission>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PermissionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Permission&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code);

@override
String toString() {
  return 'Permission(id: $id, code: $code)';
}


}

/// @nodoc
abstract mixin class _$PermissionCopyWith<$Res> implements $PermissionCopyWith<$Res> {
  factory _$PermissionCopyWith(_Permission value, $Res Function(_Permission) _then) = __$PermissionCopyWithImpl;
@override @useResult
$Res call({
 String id, String code
});




}
/// @nodoc
class __$PermissionCopyWithImpl<$Res>
    implements _$PermissionCopyWith<$Res> {
  __$PermissionCopyWithImpl(this._self, this._then);

  final _Permission _self;
  final $Res Function(_Permission) _then;

/// Create a copy of Permission
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,}) {
  return _then(_Permission(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
