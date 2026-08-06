// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String get email; String get fullName; bool get isSuperAdmin; String get status; bool get mfaEnabled; DateTime get createdAt; DateTime get updatedAt; String? get avatarUrl; DateTime? get lastLoginAt; List<Role> get roles; TenantRef? get tenant;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.isSuperAdmin, isSuperAdmin) || other.isSuperAdmin == isSuperAdmin)&&(identical(other.status, status) || other.status == status)&&(identical(other.mfaEnabled, mfaEnabled) || other.mfaEnabled == mfaEnabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.tenant, tenant) || other.tenant == tenant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,fullName,isSuperAdmin,status,mfaEnabled,createdAt,updatedAt,avatarUrl,lastLoginAt,const DeepCollectionEquality().hash(roles),tenant);

@override
String toString() {
  return 'User(id: $id, email: $email, fullName: $fullName, isSuperAdmin: $isSuperAdmin, status: $status, mfaEnabled: $mfaEnabled, createdAt: $createdAt, updatedAt: $updatedAt, avatarUrl: $avatarUrl, lastLoginAt: $lastLoginAt, roles: $roles, tenant: $tenant)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String email, String fullName, bool isSuperAdmin, String status, bool mfaEnabled, DateTime createdAt, DateTime updatedAt, String? avatarUrl, DateTime? lastLoginAt, List<Role> roles, TenantRef? tenant
});


$TenantRefCopyWith<$Res>? get tenant;

}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? fullName = null,Object? isSuperAdmin = null,Object? status = null,Object? mfaEnabled = null,Object? createdAt = null,Object? updatedAt = null,Object? avatarUrl = freezed,Object? lastLoginAt = freezed,Object? roles = null,Object? tenant = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,isSuperAdmin: null == isSuperAdmin ? _self.isSuperAdmin : isSuperAdmin // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,mfaEnabled: null == mfaEnabled ? _self.mfaEnabled : mfaEnabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<Role>,tenant: freezed == tenant ? _self.tenant : tenant // ignore: cast_nullable_to_non_nullable
as TenantRef?,
  ));
}
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TenantRefCopyWith<$Res>? get tenant {
    if (_self.tenant == null) {
    return null;
  }

  return $TenantRefCopyWith<$Res>(_self.tenant!, (value) {
    return _then(_self.copyWith(tenant: value));
  });
}
}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String fullName,  bool isSuperAdmin,  String status,  bool mfaEnabled,  DateTime createdAt,  DateTime updatedAt,  String? avatarUrl,  DateTime? lastLoginAt,  List<Role> roles,  TenantRef? tenant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.fullName,_that.isSuperAdmin,_that.status,_that.mfaEnabled,_that.createdAt,_that.updatedAt,_that.avatarUrl,_that.lastLoginAt,_that.roles,_that.tenant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String fullName,  bool isSuperAdmin,  String status,  bool mfaEnabled,  DateTime createdAt,  DateTime updatedAt,  String? avatarUrl,  DateTime? lastLoginAt,  List<Role> roles,  TenantRef? tenant)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.email,_that.fullName,_that.isSuperAdmin,_that.status,_that.mfaEnabled,_that.createdAt,_that.updatedAt,_that.avatarUrl,_that.lastLoginAt,_that.roles,_that.tenant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String fullName,  bool isSuperAdmin,  String status,  bool mfaEnabled,  DateTime createdAt,  DateTime updatedAt,  String? avatarUrl,  DateTime? lastLoginAt,  List<Role> roles,  TenantRef? tenant)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.fullName,_that.isSuperAdmin,_that.status,_that.mfaEnabled,_that.createdAt,_that.updatedAt,_that.avatarUrl,_that.lastLoginAt,_that.roles,_that.tenant);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User extends User {
  const _User({required this.id, required this.email, required this.fullName, required this.isSuperAdmin, required this.status, required this.mfaEnabled, required this.createdAt, required this.updatedAt, this.avatarUrl, this.lastLoginAt, required final  List<Role> roles, this.tenant}): _roles = roles,super._();
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String email;
@override final  String fullName;
@override final  bool isSuperAdmin;
@override final  String status;
@override final  bool mfaEnabled;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? avatarUrl;
@override final  DateTime? lastLoginAt;
 final  List<Role> _roles;
@override List<Role> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override final  TenantRef? tenant;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.isSuperAdmin, isSuperAdmin) || other.isSuperAdmin == isSuperAdmin)&&(identical(other.status, status) || other.status == status)&&(identical(other.mfaEnabled, mfaEnabled) || other.mfaEnabled == mfaEnabled)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.tenant, tenant) || other.tenant == tenant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,fullName,isSuperAdmin,status,mfaEnabled,createdAt,updatedAt,avatarUrl,lastLoginAt,const DeepCollectionEquality().hash(_roles),tenant);

@override
String toString() {
  return 'User(id: $id, email: $email, fullName: $fullName, isSuperAdmin: $isSuperAdmin, status: $status, mfaEnabled: $mfaEnabled, createdAt: $createdAt, updatedAt: $updatedAt, avatarUrl: $avatarUrl, lastLoginAt: $lastLoginAt, roles: $roles, tenant: $tenant)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String fullName, bool isSuperAdmin, String status, bool mfaEnabled, DateTime createdAt, DateTime updatedAt, String? avatarUrl, DateTime? lastLoginAt, List<Role> roles, TenantRef? tenant
});


@override $TenantRefCopyWith<$Res>? get tenant;

}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? fullName = null,Object? isSuperAdmin = null,Object? status = null,Object? mfaEnabled = null,Object? createdAt = null,Object? updatedAt = null,Object? avatarUrl = freezed,Object? lastLoginAt = freezed,Object? roles = null,Object? tenant = freezed,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,isSuperAdmin: null == isSuperAdmin ? _self.isSuperAdmin : isSuperAdmin // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,mfaEnabled: null == mfaEnabled ? _self.mfaEnabled : mfaEnabled // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<Role>,tenant: freezed == tenant ? _self.tenant : tenant // ignore: cast_nullable_to_non_nullable
as TenantRef?,
  ));
}

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TenantRefCopyWith<$Res>? get tenant {
    if (_self.tenant == null) {
    return null;
  }

  return $TenantRefCopyWith<$Res>(_self.tenant!, (value) {
    return _then(_self.copyWith(tenant: value));
  });
}
}

// dart format on
