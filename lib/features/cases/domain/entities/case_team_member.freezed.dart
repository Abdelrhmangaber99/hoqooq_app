// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_team_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaseTeamMember {

 String get id; String get role; User get user;
/// Create a copy of CaseTeamMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseTeamMemberCopyWith<CaseTeamMember> get copyWith => _$CaseTeamMemberCopyWithImpl<CaseTeamMember>(this as CaseTeamMember, _$identity);

  /// Serializes this CaseTeamMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseTeamMember&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,role,user);

@override
String toString() {
  return 'CaseTeamMember(id: $id, role: $role, user: $user)';
}


}

/// @nodoc
abstract mixin class $CaseTeamMemberCopyWith<$Res>  {
  factory $CaseTeamMemberCopyWith(CaseTeamMember value, $Res Function(CaseTeamMember) _then) = _$CaseTeamMemberCopyWithImpl;
@useResult
$Res call({
 String id, String role, User user
});


$UserCopyWith<$Res> get user;

}
/// @nodoc
class _$CaseTeamMemberCopyWithImpl<$Res>
    implements $CaseTeamMemberCopyWith<$Res> {
  _$CaseTeamMemberCopyWithImpl(this._self, this._then);

  final CaseTeamMember _self;
  final $Res Function(CaseTeamMember) _then;

/// Create a copy of CaseTeamMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? role = null,Object? user = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,
  ));
}
/// Create a copy of CaseTeamMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [CaseTeamMember].
extension CaseTeamMemberPatterns on CaseTeamMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseTeamMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseTeamMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseTeamMember value)  $default,){
final _that = this;
switch (_that) {
case _CaseTeamMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseTeamMember value)?  $default,){
final _that = this;
switch (_that) {
case _CaseTeamMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String role,  User user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseTeamMember() when $default != null:
return $default(_that.id,_that.role,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String role,  User user)  $default,) {final _that = this;
switch (_that) {
case _CaseTeamMember():
return $default(_that.id,_that.role,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String role,  User user)?  $default,) {final _that = this;
switch (_that) {
case _CaseTeamMember() when $default != null:
return $default(_that.id,_that.role,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseTeamMember implements CaseTeamMember {
  const _CaseTeamMember({required this.id, required this.role, required this.user});
  factory _CaseTeamMember.fromJson(Map<String, dynamic> json) => _$CaseTeamMemberFromJson(json);

@override final  String id;
@override final  String role;
@override final  User user;

/// Create a copy of CaseTeamMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseTeamMemberCopyWith<_CaseTeamMember> get copyWith => __$CaseTeamMemberCopyWithImpl<_CaseTeamMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseTeamMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseTeamMember&&(identical(other.id, id) || other.id == id)&&(identical(other.role, role) || other.role == role)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,role,user);

@override
String toString() {
  return 'CaseTeamMember(id: $id, role: $role, user: $user)';
}


}

/// @nodoc
abstract mixin class _$CaseTeamMemberCopyWith<$Res> implements $CaseTeamMemberCopyWith<$Res> {
  factory _$CaseTeamMemberCopyWith(_CaseTeamMember value, $Res Function(_CaseTeamMember) _then) = __$CaseTeamMemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String role, User user
});


@override $UserCopyWith<$Res> get user;

}
/// @nodoc
class __$CaseTeamMemberCopyWithImpl<$Res>
    implements _$CaseTeamMemberCopyWith<$Res> {
  __$CaseTeamMemberCopyWithImpl(this._self, this._then);

  final _CaseTeamMember _self;
  final $Res Function(_CaseTeamMember) _then;

/// Create a copy of CaseTeamMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? role = null,Object? user = null,}) {
  return _then(_CaseTeamMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,
  ));
}

/// Create a copy of CaseTeamMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
