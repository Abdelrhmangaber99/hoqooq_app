// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lookup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Lookup {

 String get id; String? get tenantId;@JsonKey(unknownEnumValue: LookupKind.unknown) LookupKind get kind; String get labelEn; String get labelAr; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Lookup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LookupCopyWith<Lookup> get copyWith => _$LookupCopyWithImpl<Lookup>(this as Lookup, _$identity);

  /// Serializes this Lookup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lookup&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&(identical(other.labelAr, labelAr) || other.labelAr == labelAr)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,kind,labelEn,labelAr,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Lookup(id: $id, tenantId: $tenantId, kind: $kind, labelEn: $labelEn, labelAr: $labelAr, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $LookupCopyWith<$Res>  {
  factory $LookupCopyWith(Lookup value, $Res Function(Lookup) _then) = _$LookupCopyWithImpl;
@useResult
$Res call({
 String id, String? tenantId,@JsonKey(unknownEnumValue: LookupKind.unknown) LookupKind kind, String labelEn, String labelAr, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$LookupCopyWithImpl<$Res>
    implements $LookupCopyWith<$Res> {
  _$LookupCopyWithImpl(this._self, this._then);

  final Lookup _self;
  final $Res Function(Lookup) _then;

/// Create a copy of Lookup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = freezed,Object? kind = null,Object? labelEn = null,Object? labelAr = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: freezed == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as LookupKind,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,labelAr: null == labelAr ? _self.labelAr : labelAr // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Lookup].
extension LookupPatterns on Lookup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lookup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lookup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lookup value)  $default,){
final _that = this;
switch (_that) {
case _Lookup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lookup value)?  $default,){
final _that = this;
switch (_that) {
case _Lookup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? tenantId, @JsonKey(unknownEnumValue: LookupKind.unknown)  LookupKind kind,  String labelEn,  String labelAr,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lookup() when $default != null:
return $default(_that.id,_that.tenantId,_that.kind,_that.labelEn,_that.labelAr,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? tenantId, @JsonKey(unknownEnumValue: LookupKind.unknown)  LookupKind kind,  String labelEn,  String labelAr,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Lookup():
return $default(_that.id,_that.tenantId,_that.kind,_that.labelEn,_that.labelAr,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? tenantId, @JsonKey(unknownEnumValue: LookupKind.unknown)  LookupKind kind,  String labelEn,  String labelAr,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Lookup() when $default != null:
return $default(_that.id,_that.tenantId,_that.kind,_that.labelEn,_that.labelAr,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Lookup extends Lookup {
  const _Lookup({required this.id, this.tenantId, @JsonKey(unknownEnumValue: LookupKind.unknown) required this.kind, required this.labelEn, required this.labelAr, required this.isActive, required this.createdAt, required this.updatedAt}): super._();
  factory _Lookup.fromJson(Map<String, dynamic> json) => _$LookupFromJson(json);

@override final  String id;
@override final  String? tenantId;
@override@JsonKey(unknownEnumValue: LookupKind.unknown) final  LookupKind kind;
@override final  String labelEn;
@override final  String labelAr;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Lookup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LookupCopyWith<_Lookup> get copyWith => __$LookupCopyWithImpl<_Lookup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LookupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lookup&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&(identical(other.labelAr, labelAr) || other.labelAr == labelAr)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,kind,labelEn,labelAr,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'Lookup(id: $id, tenantId: $tenantId, kind: $kind, labelEn: $labelEn, labelAr: $labelAr, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$LookupCopyWith<$Res> implements $LookupCopyWith<$Res> {
  factory _$LookupCopyWith(_Lookup value, $Res Function(_Lookup) _then) = __$LookupCopyWithImpl;
@override @useResult
$Res call({
 String id, String? tenantId,@JsonKey(unknownEnumValue: LookupKind.unknown) LookupKind kind, String labelEn, String labelAr, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$LookupCopyWithImpl<$Res>
    implements _$LookupCopyWith<$Res> {
  __$LookupCopyWithImpl(this._self, this._then);

  final _Lookup _self;
  final $Res Function(_Lookup) _then;

/// Create a copy of Lookup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = freezed,Object? kind = null,Object? labelEn = null,Object? labelAr = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Lookup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: freezed == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as LookupKind,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,labelAr: null == labelAr ? _self.labelAr : labelAr // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
