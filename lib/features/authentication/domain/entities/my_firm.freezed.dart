// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_firm.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyFirm {

 String get id; String get name; String get ownerUserId;
/// Create a copy of MyFirm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyFirmCopyWith<MyFirm> get copyWith => _$MyFirmCopyWithImpl<MyFirm>(this as MyFirm, _$identity);

  /// Serializes this MyFirm to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyFirm&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerUserId, ownerUserId) || other.ownerUserId == ownerUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerUserId);

@override
String toString() {
  return 'MyFirm(id: $id, name: $name, ownerUserId: $ownerUserId)';
}


}

/// @nodoc
abstract mixin class $MyFirmCopyWith<$Res>  {
  factory $MyFirmCopyWith(MyFirm value, $Res Function(MyFirm) _then) = _$MyFirmCopyWithImpl;
@useResult
$Res call({
 String id, String name, String ownerUserId
});




}
/// @nodoc
class _$MyFirmCopyWithImpl<$Res>
    implements $MyFirmCopyWith<$Res> {
  _$MyFirmCopyWithImpl(this._self, this._then);

  final MyFirm _self;
  final $Res Function(MyFirm) _then;

/// Create a copy of MyFirm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerUserId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerUserId: null == ownerUserId ? _self.ownerUserId : ownerUserId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MyFirm].
extension MyFirmPatterns on MyFirm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyFirm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyFirm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyFirm value)  $default,){
final _that = this;
switch (_that) {
case _MyFirm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyFirm value)?  $default,){
final _that = this;
switch (_that) {
case _MyFirm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String ownerUserId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyFirm() when $default != null:
return $default(_that.id,_that.name,_that.ownerUserId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String ownerUserId)  $default,) {final _that = this;
switch (_that) {
case _MyFirm():
return $default(_that.id,_that.name,_that.ownerUserId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String ownerUserId)?  $default,) {final _that = this;
switch (_that) {
case _MyFirm() when $default != null:
return $default(_that.id,_that.name,_that.ownerUserId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MyFirm implements MyFirm {
  const _MyFirm({required this.id, required this.name, required this.ownerUserId});
  factory _MyFirm.fromJson(Map<String, dynamic> json) => _$MyFirmFromJson(json);

@override final  String id;
@override final  String name;
@override final  String ownerUserId;

/// Create a copy of MyFirm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyFirmCopyWith<_MyFirm> get copyWith => __$MyFirmCopyWithImpl<_MyFirm>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MyFirmToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyFirm&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerUserId, ownerUserId) || other.ownerUserId == ownerUserId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerUserId);

@override
String toString() {
  return 'MyFirm(id: $id, name: $name, ownerUserId: $ownerUserId)';
}


}

/// @nodoc
abstract mixin class _$MyFirmCopyWith<$Res> implements $MyFirmCopyWith<$Res> {
  factory _$MyFirmCopyWith(_MyFirm value, $Res Function(_MyFirm) _then) = __$MyFirmCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String ownerUserId
});




}
/// @nodoc
class __$MyFirmCopyWithImpl<$Res>
    implements _$MyFirmCopyWith<$Res> {
  __$MyFirmCopyWithImpl(this._self, this._then);

  final _MyFirm _self;
  final $Res Function(_MyFirm) _then;

/// Create a copy of MyFirm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerUserId = null,}) {
  return _then(_MyFirm(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerUserId: null == ownerUserId ? _self.ownerUserId : ownerUserId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
