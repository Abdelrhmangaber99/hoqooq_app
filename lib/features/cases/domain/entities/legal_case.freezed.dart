// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'legal_case.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LegalCase {

 String get id; String get title; String get caseNumber; String get attorneyName; String get status; String get category; int get hearingsCount; int get documentsCount; int get daysOpen;
/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LegalCaseCopyWith<LegalCase> get copyWith => _$LegalCaseCopyWithImpl<LegalCase>(this as LegalCase, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LegalCase&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.attorneyName, attorneyName) || other.attorneyName == attorneyName)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.hearingsCount, hearingsCount) || other.hearingsCount == hearingsCount)&&(identical(other.documentsCount, documentsCount) || other.documentsCount == documentsCount)&&(identical(other.daysOpen, daysOpen) || other.daysOpen == daysOpen));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,caseNumber,attorneyName,status,category,hearingsCount,documentsCount,daysOpen);

@override
String toString() {
  return 'LegalCase(id: $id, title: $title, caseNumber: $caseNumber, attorneyName: $attorneyName, status: $status, category: $category, hearingsCount: $hearingsCount, documentsCount: $documentsCount, daysOpen: $daysOpen)';
}


}

/// @nodoc
abstract mixin class $LegalCaseCopyWith<$Res>  {
  factory $LegalCaseCopyWith(LegalCase value, $Res Function(LegalCase) _then) = _$LegalCaseCopyWithImpl;
@useResult
$Res call({
 String id, String title, String caseNumber, String attorneyName, String status, String category, int hearingsCount, int documentsCount, int daysOpen
});




}
/// @nodoc
class _$LegalCaseCopyWithImpl<$Res>
    implements $LegalCaseCopyWith<$Res> {
  _$LegalCaseCopyWithImpl(this._self, this._then);

  final LegalCase _self;
  final $Res Function(LegalCase) _then;

/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? caseNumber = null,Object? attorneyName = null,Object? status = null,Object? category = null,Object? hearingsCount = null,Object? documentsCount = null,Object? daysOpen = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,attorneyName: null == attorneyName ? _self.attorneyName : attorneyName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,hearingsCount: null == hearingsCount ? _self.hearingsCount : hearingsCount // ignore: cast_nullable_to_non_nullable
as int,documentsCount: null == documentsCount ? _self.documentsCount : documentsCount // ignore: cast_nullable_to_non_nullable
as int,daysOpen: null == daysOpen ? _self.daysOpen : daysOpen // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LegalCase].
extension LegalCasePatterns on LegalCase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LegalCase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LegalCase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LegalCase value)  $default,){
final _that = this;
switch (_that) {
case _LegalCase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LegalCase value)?  $default,){
final _that = this;
switch (_that) {
case _LegalCase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String caseNumber,  String attorneyName,  String status,  String category,  int hearingsCount,  int documentsCount,  int daysOpen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LegalCase() when $default != null:
return $default(_that.id,_that.title,_that.caseNumber,_that.attorneyName,_that.status,_that.category,_that.hearingsCount,_that.documentsCount,_that.daysOpen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String caseNumber,  String attorneyName,  String status,  String category,  int hearingsCount,  int documentsCount,  int daysOpen)  $default,) {final _that = this;
switch (_that) {
case _LegalCase():
return $default(_that.id,_that.title,_that.caseNumber,_that.attorneyName,_that.status,_that.category,_that.hearingsCount,_that.documentsCount,_that.daysOpen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String caseNumber,  String attorneyName,  String status,  String category,  int hearingsCount,  int documentsCount,  int daysOpen)?  $default,) {final _that = this;
switch (_that) {
case _LegalCase() when $default != null:
return $default(_that.id,_that.title,_that.caseNumber,_that.attorneyName,_that.status,_that.category,_that.hearingsCount,_that.documentsCount,_that.daysOpen);case _:
  return null;

}
}

}

/// @nodoc


class _LegalCase extends LegalCase {
  const _LegalCase({required this.id, required this.title, required this.caseNumber, required this.attorneyName, required this.status, required this.category, required this.hearingsCount, required this.documentsCount, required this.daysOpen}): super._();
  

@override final  String id;
@override final  String title;
@override final  String caseNumber;
@override final  String attorneyName;
@override final  String status;
@override final  String category;
@override final  int hearingsCount;
@override final  int documentsCount;
@override final  int daysOpen;

/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LegalCaseCopyWith<_LegalCase> get copyWith => __$LegalCaseCopyWithImpl<_LegalCase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LegalCase&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.attorneyName, attorneyName) || other.attorneyName == attorneyName)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.hearingsCount, hearingsCount) || other.hearingsCount == hearingsCount)&&(identical(other.documentsCount, documentsCount) || other.documentsCount == documentsCount)&&(identical(other.daysOpen, daysOpen) || other.daysOpen == daysOpen));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,caseNumber,attorneyName,status,category,hearingsCount,documentsCount,daysOpen);

@override
String toString() {
  return 'LegalCase(id: $id, title: $title, caseNumber: $caseNumber, attorneyName: $attorneyName, status: $status, category: $category, hearingsCount: $hearingsCount, documentsCount: $documentsCount, daysOpen: $daysOpen)';
}


}

/// @nodoc
abstract mixin class _$LegalCaseCopyWith<$Res> implements $LegalCaseCopyWith<$Res> {
  factory _$LegalCaseCopyWith(_LegalCase value, $Res Function(_LegalCase) _then) = __$LegalCaseCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String caseNumber, String attorneyName, String status, String category, int hearingsCount, int documentsCount, int daysOpen
});




}
/// @nodoc
class __$LegalCaseCopyWithImpl<$Res>
    implements _$LegalCaseCopyWith<$Res> {
  __$LegalCaseCopyWithImpl(this._self, this._then);

  final _LegalCase _self;
  final $Res Function(_LegalCase) _then;

/// Create a copy of LegalCase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? caseNumber = null,Object? attorneyName = null,Object? status = null,Object? category = null,Object? hearingsCount = null,Object? documentsCount = null,Object? daysOpen = null,}) {
  return _then(_LegalCase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,attorneyName: null == attorneyName ? _self.attorneyName : attorneyName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,hearingsCount: null == hearingsCount ? _self.hearingsCount : hearingsCount // ignore: cast_nullable_to_non_nullable
as int,documentsCount: null == documentsCount ? _self.documentsCount : documentsCount // ignore: cast_nullable_to_non_nullable
as int,daysOpen: null == daysOpen ? _self.daysOpen : daysOpen // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
