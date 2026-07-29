// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'role.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Role {

 String get id; String get name; String get displayNameEn; String get displayNameAr; List<Permission> get permissions;
/// Create a copy of Role
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleCopyWith<Role> get copyWith => _$RoleCopyWithImpl<Role>(this as Role, _$identity);

  /// Serializes this Role to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Role&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayNameEn, displayNameEn) || other.displayNameEn == displayNameEn)&&(identical(other.displayNameAr, displayNameAr) || other.displayNameAr == displayNameAr)&&const DeepCollectionEquality().equals(other.permissions, permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,displayNameEn,displayNameAr,const DeepCollectionEquality().hash(permissions));

@override
String toString() {
  return 'Role(id: $id, name: $name, displayNameEn: $displayNameEn, displayNameAr: $displayNameAr, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class $RoleCopyWith<$Res>  {
  factory $RoleCopyWith(Role value, $Res Function(Role) _then) = _$RoleCopyWithImpl;
@useResult
$Res call({
 String id, String name, String displayNameEn, String displayNameAr, List<Permission> permissions
});




}
/// @nodoc
class _$RoleCopyWithImpl<$Res>
    implements $RoleCopyWith<$Res> {
  _$RoleCopyWithImpl(this._self, this._then);

  final Role _self;
  final $Res Function(Role) _then;

/// Create a copy of Role
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? displayNameEn = null,Object? displayNameAr = null,Object? permissions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayNameEn: null == displayNameEn ? _self.displayNameEn : displayNameEn // ignore: cast_nullable_to_non_nullable
as String,displayNameAr: null == displayNameAr ? _self.displayNameAr : displayNameAr // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<Permission>,
  ));
}

}


/// Adds pattern-matching-related methods to [Role].
extension RolePatterns on Role {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Role value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Role() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Role value)  $default,){
final _that = this;
switch (_that) {
case _Role():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Role value)?  $default,){
final _that = this;
switch (_that) {
case _Role() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String displayNameEn,  String displayNameAr,  List<Permission> permissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Role() when $default != null:
return $default(_that.id,_that.name,_that.displayNameEn,_that.displayNameAr,_that.permissions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String displayNameEn,  String displayNameAr,  List<Permission> permissions)  $default,) {final _that = this;
switch (_that) {
case _Role():
return $default(_that.id,_that.name,_that.displayNameEn,_that.displayNameAr,_that.permissions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String displayNameEn,  String displayNameAr,  List<Permission> permissions)?  $default,) {final _that = this;
switch (_that) {
case _Role() when $default != null:
return $default(_that.id,_that.name,_that.displayNameEn,_that.displayNameAr,_that.permissions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Role implements Role {
  const _Role({required this.id, required this.name, required this.displayNameEn, required this.displayNameAr, required final  List<Permission> permissions}): _permissions = permissions;
  factory _Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

@override final  String id;
@override final  String name;
@override final  String displayNameEn;
@override final  String displayNameAr;
 final  List<Permission> _permissions;
@override List<Permission> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}


/// Create a copy of Role
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleCopyWith<_Role> get copyWith => __$RoleCopyWithImpl<_Role>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Role&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayNameEn, displayNameEn) || other.displayNameEn == displayNameEn)&&(identical(other.displayNameAr, displayNameAr) || other.displayNameAr == displayNameAr)&&const DeepCollectionEquality().equals(other._permissions, _permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,displayNameEn,displayNameAr,const DeepCollectionEquality().hash(_permissions));

@override
String toString() {
  return 'Role(id: $id, name: $name, displayNameEn: $displayNameEn, displayNameAr: $displayNameAr, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class _$RoleCopyWith<$Res> implements $RoleCopyWith<$Res> {
  factory _$RoleCopyWith(_Role value, $Res Function(_Role) _then) = __$RoleCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String displayNameEn, String displayNameAr, List<Permission> permissions
});




}
/// @nodoc
class __$RoleCopyWithImpl<$Res>
    implements _$RoleCopyWith<$Res> {
  __$RoleCopyWithImpl(this._self, this._then);

  final _Role _self;
  final $Res Function(_Role) _then;

/// Create a copy of Role
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? displayNameEn = null,Object? displayNameAr = null,Object? permissions = null,}) {
  return _then(_Role(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayNameEn: null == displayNameEn ? _self.displayNameEn : displayNameEn // ignore: cast_nullable_to_non_nullable
as String,displayNameAr: null == displayNameAr ? _self.displayNameAr : displayNameAr // ignore: cast_nullable_to_non_nullable
as String,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<Permission>,
  ));
}


}

// dart format on
