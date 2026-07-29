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

 String get id; String get email; String get firstName; String get lastName; bool get isActive; DateTime get createdAt; DateTime get updatedAt; String? get phone; String? get avatarUrl; DateTime? get lastLoginAt; List<Role> get roles; TenantRef get tenant;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.tenant, tenant) || other.tenant == tenant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,firstName,lastName,isActive,createdAt,updatedAt,phone,avatarUrl,lastLoginAt,const DeepCollectionEquality().hash(roles),tenant);

@override
String toString() {
  return 'User(id: $id, email: $email, firstName: $firstName, lastName: $lastName, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, phone: $phone, avatarUrl: $avatarUrl, lastLoginAt: $lastLoginAt, roles: $roles, tenant: $tenant)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String email, String firstName, String lastName, bool isActive, DateTime createdAt, DateTime updatedAt, String? phone, String? avatarUrl, DateTime? lastLoginAt, List<Role> roles, TenantRef tenant
});


$TenantRefCopyWith<$Res> get tenant;

}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? firstName = null,Object? lastName = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? phone = freezed,Object? avatarUrl = freezed,Object? lastLoginAt = freezed,Object? roles = null,Object? tenant = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<Role>,tenant: null == tenant ? _self.tenant : tenant // ignore: cast_nullable_to_non_nullable
as TenantRef,
  ));
}
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TenantRefCopyWith<$Res> get tenant {
  
  return $TenantRefCopyWith<$Res>(_self.tenant, (value) {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String firstName,  String lastName,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String? phone,  String? avatarUrl,  DateTime? lastLoginAt,  List<Role> roles,  TenantRef tenant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.firstName,_that.lastName,_that.isActive,_that.createdAt,_that.updatedAt,_that.phone,_that.avatarUrl,_that.lastLoginAt,_that.roles,_that.tenant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String firstName,  String lastName,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String? phone,  String? avatarUrl,  DateTime? lastLoginAt,  List<Role> roles,  TenantRef tenant)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.email,_that.firstName,_that.lastName,_that.isActive,_that.createdAt,_that.updatedAt,_that.phone,_that.avatarUrl,_that.lastLoginAt,_that.roles,_that.tenant);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String firstName,  String lastName,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String? phone,  String? avatarUrl,  DateTime? lastLoginAt,  List<Role> roles,  TenantRef tenant)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.email,_that.firstName,_that.lastName,_that.isActive,_that.createdAt,_that.updatedAt,_that.phone,_that.avatarUrl,_that.lastLoginAt,_that.roles,_that.tenant);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User extends User {
  const _User({required this.id, required this.email, required this.firstName, required this.lastName, required this.isActive, required this.createdAt, required this.updatedAt, this.phone, this.avatarUrl, this.lastLoginAt, required final  List<Role> roles, required this.tenant}): _roles = roles,super._();
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String email;
@override final  String firstName;
@override final  String lastName;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? phone;
@override final  String? avatarUrl;
@override final  DateTime? lastLoginAt;
 final  List<Role> _roles;
@override List<Role> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override final  TenantRef tenant;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.tenant, tenant) || other.tenant == tenant));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,firstName,lastName,isActive,createdAt,updatedAt,phone,avatarUrl,lastLoginAt,const DeepCollectionEquality().hash(_roles),tenant);

@override
String toString() {
  return 'User(id: $id, email: $email, firstName: $firstName, lastName: $lastName, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, phone: $phone, avatarUrl: $avatarUrl, lastLoginAt: $lastLoginAt, roles: $roles, tenant: $tenant)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String firstName, String lastName, bool isActive, DateTime createdAt, DateTime updatedAt, String? phone, String? avatarUrl, DateTime? lastLoginAt, List<Role> roles, TenantRef tenant
});


@override $TenantRefCopyWith<$Res> get tenant;

}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? firstName = null,Object? lastName = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? phone = freezed,Object? avatarUrl = freezed,Object? lastLoginAt = freezed,Object? roles = null,Object? tenant = null,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<Role>,tenant: null == tenant ? _self.tenant : tenant // ignore: cast_nullable_to_non_nullable
as TenantRef,
  ));
}

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TenantRefCopyWith<$Res> get tenant {
  
  return $TenantRefCopyWith<$Res>(_self.tenant, (value) {
    return _then(_self.copyWith(tenant: value));
  });
}
}

// dart format on
