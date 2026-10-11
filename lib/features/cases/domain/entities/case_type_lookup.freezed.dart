// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_type_lookup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaseTypeLookup {

 String get id; String get name; String get labelEn; String get labelAr;
/// Create a copy of CaseTypeLookup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseTypeLookupCopyWith<CaseTypeLookup> get copyWith => _$CaseTypeLookupCopyWithImpl<CaseTypeLookup>(this as CaseTypeLookup, _$identity);

  /// Serializes this CaseTypeLookup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseTypeLookup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&(identical(other.labelAr, labelAr) || other.labelAr == labelAr));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,labelEn,labelAr);

@override
String toString() {
  return 'CaseTypeLookup(id: $id, name: $name, labelEn: $labelEn, labelAr: $labelAr)';
}


}

/// @nodoc
abstract mixin class $CaseTypeLookupCopyWith<$Res>  {
  factory $CaseTypeLookupCopyWith(CaseTypeLookup value, $Res Function(CaseTypeLookup) _then) = _$CaseTypeLookupCopyWithImpl;
@useResult
$Res call({
 String id, String name, String labelEn, String labelAr
});




}
/// @nodoc
class _$CaseTypeLookupCopyWithImpl<$Res>
    implements $CaseTypeLookupCopyWith<$Res> {
  _$CaseTypeLookupCopyWithImpl(this._self, this._then);

  final CaseTypeLookup _self;
  final $Res Function(CaseTypeLookup) _then;

/// Create a copy of CaseTypeLookup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? labelEn = null,Object? labelAr = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,labelAr: null == labelAr ? _self.labelAr : labelAr // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CaseTypeLookup].
extension CaseTypeLookupPatterns on CaseTypeLookup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseTypeLookup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseTypeLookup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseTypeLookup value)  $default,){
final _that = this;
switch (_that) {
case _CaseTypeLookup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseTypeLookup value)?  $default,){
final _that = this;
switch (_that) {
case _CaseTypeLookup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String labelEn,  String labelAr)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseTypeLookup() when $default != null:
return $default(_that.id,_that.name,_that.labelEn,_that.labelAr);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String labelEn,  String labelAr)  $default,) {final _that = this;
switch (_that) {
case _CaseTypeLookup():
return $default(_that.id,_that.name,_that.labelEn,_that.labelAr);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String labelEn,  String labelAr)?  $default,) {final _that = this;
switch (_that) {
case _CaseTypeLookup() when $default != null:
return $default(_that.id,_that.name,_that.labelEn,_that.labelAr);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseTypeLookup extends CaseTypeLookup {
  const _CaseTypeLookup({required this.id, required this.name, this.labelEn = '', this.labelAr = ''}): super._();
  factory _CaseTypeLookup.fromJson(Map<String, dynamic> json) => _$CaseTypeLookupFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String labelEn;
@override@JsonKey() final  String labelAr;

/// Create a copy of CaseTypeLookup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseTypeLookupCopyWith<_CaseTypeLookup> get copyWith => __$CaseTypeLookupCopyWithImpl<_CaseTypeLookup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseTypeLookupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseTypeLookup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.labelEn, labelEn) || other.labelEn == labelEn)&&(identical(other.labelAr, labelAr) || other.labelAr == labelAr));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,labelEn,labelAr);

@override
String toString() {
  return 'CaseTypeLookup(id: $id, name: $name, labelEn: $labelEn, labelAr: $labelAr)';
}


}

/// @nodoc
abstract mixin class _$CaseTypeLookupCopyWith<$Res> implements $CaseTypeLookupCopyWith<$Res> {
  factory _$CaseTypeLookupCopyWith(_CaseTypeLookup value, $Res Function(_CaseTypeLookup) _then) = __$CaseTypeLookupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String labelEn, String labelAr
});




}
/// @nodoc
class __$CaseTypeLookupCopyWithImpl<$Res>
    implements _$CaseTypeLookupCopyWith<$Res> {
  __$CaseTypeLookupCopyWithImpl(this._self, this._then);

  final _CaseTypeLookup _self;
  final $Res Function(_CaseTypeLookup) _then;

/// Create a copy of CaseTypeLookup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? labelEn = null,Object? labelAr = null,}) {
  return _then(_CaseTypeLookup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,labelEn: null == labelEn ? _self.labelEn : labelEn // ignore: cast_nullable_to_non_nullable
as String,labelAr: null == labelAr ? _self.labelAr : labelAr // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
