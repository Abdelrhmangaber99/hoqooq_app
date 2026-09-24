// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaseSummary {

 String get id; String get tenantId; String get caseNumber;@JsonKey(unknownEnumValue: CaseStatus.unknown) CaseStatus get status; String get clientId; String get caseTypeId; String? get courtName;@JsonKey(unknownEnumValue: CasePriority.unknown) CasePriority get priority; DateTime? get openingDate; DateTime? get closingDate; String? get outcomeSummary; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of CaseSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseSummaryCopyWith<CaseSummary> get copyWith => _$CaseSummaryCopyWithImpl<CaseSummary>(this as CaseSummary, _$identity);

  /// Serializes this CaseSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.caseTypeId, caseTypeId) || other.caseTypeId == caseTypeId)&&(identical(other.courtName, courtName) || other.courtName == courtName)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.openingDate, openingDate) || other.openingDate == openingDate)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate)&&(identical(other.outcomeSummary, outcomeSummary) || other.outcomeSummary == outcomeSummary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,caseNumber,status,clientId,caseTypeId,courtName,priority,openingDate,closingDate,outcomeSummary,createdAt,updatedAt);

@override
String toString() {
  return 'CaseSummary(id: $id, tenantId: $tenantId, caseNumber: $caseNumber, status: $status, clientId: $clientId, caseTypeId: $caseTypeId, courtName: $courtName, priority: $priority, openingDate: $openingDate, closingDate: $closingDate, outcomeSummary: $outcomeSummary, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CaseSummaryCopyWith<$Res>  {
  factory $CaseSummaryCopyWith(CaseSummary value, $Res Function(CaseSummary) _then) = _$CaseSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String tenantId, String caseNumber,@JsonKey(unknownEnumValue: CaseStatus.unknown) CaseStatus status, String clientId, String caseTypeId, String? courtName,@JsonKey(unknownEnumValue: CasePriority.unknown) CasePriority priority, DateTime? openingDate, DateTime? closingDate, String? outcomeSummary, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$CaseSummaryCopyWithImpl<$Res>
    implements $CaseSummaryCopyWith<$Res> {
  _$CaseSummaryCopyWithImpl(this._self, this._then);

  final CaseSummary _self;
  final $Res Function(CaseSummary) _then;

/// Create a copy of CaseSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? caseNumber = null,Object? status = null,Object? clientId = null,Object? caseTypeId = null,Object? courtName = freezed,Object? priority = null,Object? openingDate = freezed,Object? closingDate = freezed,Object? outcomeSummary = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CaseStatus,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,caseTypeId: null == caseTypeId ? _self.caseTypeId : caseTypeId // ignore: cast_nullable_to_non_nullable
as String,courtName: freezed == courtName ? _self.courtName : courtName // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as CasePriority,openingDate: freezed == openingDate ? _self.openingDate : openingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,closingDate: freezed == closingDate ? _self.closingDate : closingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,outcomeSummary: freezed == outcomeSummary ? _self.outcomeSummary : outcomeSummary // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CaseSummary].
extension CaseSummaryPatterns on CaseSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseSummary value)  $default,){
final _that = this;
switch (_that) {
case _CaseSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CaseSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenantId,  String caseNumber, @JsonKey(unknownEnumValue: CaseStatus.unknown)  CaseStatus status,  String clientId,  String caseTypeId,  String? courtName, @JsonKey(unknownEnumValue: CasePriority.unknown)  CasePriority priority,  DateTime? openingDate,  DateTime? closingDate,  String? outcomeSummary,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseSummary() when $default != null:
return $default(_that.id,_that.tenantId,_that.caseNumber,_that.status,_that.clientId,_that.caseTypeId,_that.courtName,_that.priority,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenantId,  String caseNumber, @JsonKey(unknownEnumValue: CaseStatus.unknown)  CaseStatus status,  String clientId,  String caseTypeId,  String? courtName, @JsonKey(unknownEnumValue: CasePriority.unknown)  CasePriority priority,  DateTime? openingDate,  DateTime? closingDate,  String? outcomeSummary,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CaseSummary():
return $default(_that.id,_that.tenantId,_that.caseNumber,_that.status,_that.clientId,_that.caseTypeId,_that.courtName,_that.priority,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenantId,  String caseNumber, @JsonKey(unknownEnumValue: CaseStatus.unknown)  CaseStatus status,  String clientId,  String caseTypeId,  String? courtName, @JsonKey(unknownEnumValue: CasePriority.unknown)  CasePriority priority,  DateTime? openingDate,  DateTime? closingDate,  String? outcomeSummary,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CaseSummary() when $default != null:
return $default(_that.id,_that.tenantId,_that.caseNumber,_that.status,_that.clientId,_that.caseTypeId,_that.courtName,_that.priority,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseSummary implements CaseSummary {
  const _CaseSummary({required this.id, required this.tenantId, required this.caseNumber, @JsonKey(unknownEnumValue: CaseStatus.unknown) required this.status, required this.clientId, required this.caseTypeId, this.courtName, @JsonKey(unknownEnumValue: CasePriority.unknown) required this.priority, this.openingDate, this.closingDate, this.outcomeSummary, required this.createdAt, required this.updatedAt});
  factory _CaseSummary.fromJson(Map<String, dynamic> json) => _$CaseSummaryFromJson(json);

@override final  String id;
@override final  String tenantId;
@override final  String caseNumber;
@override@JsonKey(unknownEnumValue: CaseStatus.unknown) final  CaseStatus status;
@override final  String clientId;
@override final  String caseTypeId;
@override final  String? courtName;
@override@JsonKey(unknownEnumValue: CasePriority.unknown) final  CasePriority priority;
@override final  DateTime? openingDate;
@override final  DateTime? closingDate;
@override final  String? outcomeSummary;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of CaseSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseSummaryCopyWith<_CaseSummary> get copyWith => __$CaseSummaryCopyWithImpl<_CaseSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.caseTypeId, caseTypeId) || other.caseTypeId == caseTypeId)&&(identical(other.courtName, courtName) || other.courtName == courtName)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.openingDate, openingDate) || other.openingDate == openingDate)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate)&&(identical(other.outcomeSummary, outcomeSummary) || other.outcomeSummary == outcomeSummary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,caseNumber,status,clientId,caseTypeId,courtName,priority,openingDate,closingDate,outcomeSummary,createdAt,updatedAt);

@override
String toString() {
  return 'CaseSummary(id: $id, tenantId: $tenantId, caseNumber: $caseNumber, status: $status, clientId: $clientId, caseTypeId: $caseTypeId, courtName: $courtName, priority: $priority, openingDate: $openingDate, closingDate: $closingDate, outcomeSummary: $outcomeSummary, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CaseSummaryCopyWith<$Res> implements $CaseSummaryCopyWith<$Res> {
  factory _$CaseSummaryCopyWith(_CaseSummary value, $Res Function(_CaseSummary) _then) = __$CaseSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenantId, String caseNumber,@JsonKey(unknownEnumValue: CaseStatus.unknown) CaseStatus status, String clientId, String caseTypeId, String? courtName,@JsonKey(unknownEnumValue: CasePriority.unknown) CasePriority priority, DateTime? openingDate, DateTime? closingDate, String? outcomeSummary, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$CaseSummaryCopyWithImpl<$Res>
    implements _$CaseSummaryCopyWith<$Res> {
  __$CaseSummaryCopyWithImpl(this._self, this._then);

  final _CaseSummary _self;
  final $Res Function(_CaseSummary) _then;

/// Create a copy of CaseSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? caseNumber = null,Object? status = null,Object? clientId = null,Object? caseTypeId = null,Object? courtName = freezed,Object? priority = null,Object? openingDate = freezed,Object? closingDate = freezed,Object? outcomeSummary = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CaseSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CaseStatus,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,caseTypeId: null == caseTypeId ? _self.caseTypeId : caseTypeId // ignore: cast_nullable_to_non_nullable
as String,courtName: freezed == courtName ? _self.courtName : courtName // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as CasePriority,openingDate: freezed == openingDate ? _self.openingDate : openingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,closingDate: freezed == closingDate ? _self.closingDate : closingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,outcomeSummary: freezed == outcomeSummary ? _self.outcomeSummary : outcomeSummary // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
