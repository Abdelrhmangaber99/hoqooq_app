// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hearing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Hearing {

 String get id; String get caseId;@JsonKey(name: 'case') CaseSummary? get caseSummary; String get courtId; Court? get court; String? get circuitId; String get hearingTypeId; DateTime get scheduledAt; String? get judgeName;@JsonKey(unknownEnumValue: HearingStatus.unknown) HearingStatus get status; String? get outcomeText; DateTime? get nextHearingAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Hearing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HearingCopyWith<Hearing> get copyWith => _$HearingCopyWithImpl<Hearing>(this as Hearing, _$identity);

  /// Serializes this Hearing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Hearing&&(identical(other.id, id) || other.id == id)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseSummary, caseSummary) || other.caseSummary == caseSummary)&&(identical(other.courtId, courtId) || other.courtId == courtId)&&(identical(other.court, court) || other.court == court)&&(identical(other.circuitId, circuitId) || other.circuitId == circuitId)&&(identical(other.hearingTypeId, hearingTypeId) || other.hearingTypeId == hearingTypeId)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.judgeName, judgeName) || other.judgeName == judgeName)&&(identical(other.status, status) || other.status == status)&&(identical(other.outcomeText, outcomeText) || other.outcomeText == outcomeText)&&(identical(other.nextHearingAt, nextHearingAt) || other.nextHearingAt == nextHearingAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,caseId,caseSummary,courtId,court,circuitId,hearingTypeId,scheduledAt,judgeName,status,outcomeText,nextHearingAt,createdAt,updatedAt);

@override
String toString() {
  return 'Hearing(id: $id, caseId: $caseId, caseSummary: $caseSummary, courtId: $courtId, court: $court, circuitId: $circuitId, hearingTypeId: $hearingTypeId, scheduledAt: $scheduledAt, judgeName: $judgeName, status: $status, outcomeText: $outcomeText, nextHearingAt: $nextHearingAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $HearingCopyWith<$Res>  {
  factory $HearingCopyWith(Hearing value, $Res Function(Hearing) _then) = _$HearingCopyWithImpl;
@useResult
$Res call({
 String id, String caseId,@JsonKey(name: 'case') CaseSummary? caseSummary, String courtId, Court? court, String? circuitId, String hearingTypeId, DateTime scheduledAt, String? judgeName,@JsonKey(unknownEnumValue: HearingStatus.unknown) HearingStatus status, String? outcomeText, DateTime? nextHearingAt, DateTime createdAt, DateTime updatedAt
});


$CaseSummaryCopyWith<$Res>? get caseSummary;$CourtCopyWith<$Res>? get court;

}
/// @nodoc
class _$HearingCopyWithImpl<$Res>
    implements $HearingCopyWith<$Res> {
  _$HearingCopyWithImpl(this._self, this._then);

  final Hearing _self;
  final $Res Function(Hearing) _then;

/// Create a copy of Hearing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? caseId = null,Object? caseSummary = freezed,Object? courtId = null,Object? court = freezed,Object? circuitId = freezed,Object? hearingTypeId = null,Object? scheduledAt = null,Object? judgeName = freezed,Object? status = null,Object? outcomeText = freezed,Object? nextHearingAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,caseSummary: freezed == caseSummary ? _self.caseSummary : caseSummary // ignore: cast_nullable_to_non_nullable
as CaseSummary?,courtId: null == courtId ? _self.courtId : courtId // ignore: cast_nullable_to_non_nullable
as String,court: freezed == court ? _self.court : court // ignore: cast_nullable_to_non_nullable
as Court?,circuitId: freezed == circuitId ? _self.circuitId : circuitId // ignore: cast_nullable_to_non_nullable
as String?,hearingTypeId: null == hearingTypeId ? _self.hearingTypeId : hearingTypeId // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,judgeName: freezed == judgeName ? _self.judgeName : judgeName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HearingStatus,outcomeText: freezed == outcomeText ? _self.outcomeText : outcomeText // ignore: cast_nullable_to_non_nullable
as String?,nextHearingAt: freezed == nextHearingAt ? _self.nextHearingAt : nextHearingAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Hearing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseSummaryCopyWith<$Res>? get caseSummary {
    if (_self.caseSummary == null) {
    return null;
  }

  return $CaseSummaryCopyWith<$Res>(_self.caseSummary!, (value) {
    return _then(_self.copyWith(caseSummary: value));
  });
}/// Create a copy of Hearing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CourtCopyWith<$Res>? get court {
    if (_self.court == null) {
    return null;
  }

  return $CourtCopyWith<$Res>(_self.court!, (value) {
    return _then(_self.copyWith(court: value));
  });
}
}


/// Adds pattern-matching-related methods to [Hearing].
extension HearingPatterns on Hearing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Hearing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Hearing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Hearing value)  $default,){
final _that = this;
switch (_that) {
case _Hearing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Hearing value)?  $default,){
final _that = this;
switch (_that) {
case _Hearing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String caseId, @JsonKey(name: 'case')  CaseSummary? caseSummary,  String courtId,  Court? court,  String? circuitId,  String hearingTypeId,  DateTime scheduledAt,  String? judgeName, @JsonKey(unknownEnumValue: HearingStatus.unknown)  HearingStatus status,  String? outcomeText,  DateTime? nextHearingAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Hearing() when $default != null:
return $default(_that.id,_that.caseId,_that.caseSummary,_that.courtId,_that.court,_that.circuitId,_that.hearingTypeId,_that.scheduledAt,_that.judgeName,_that.status,_that.outcomeText,_that.nextHearingAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String caseId, @JsonKey(name: 'case')  CaseSummary? caseSummary,  String courtId,  Court? court,  String? circuitId,  String hearingTypeId,  DateTime scheduledAt,  String? judgeName, @JsonKey(unknownEnumValue: HearingStatus.unknown)  HearingStatus status,  String? outcomeText,  DateTime? nextHearingAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Hearing():
return $default(_that.id,_that.caseId,_that.caseSummary,_that.courtId,_that.court,_that.circuitId,_that.hearingTypeId,_that.scheduledAt,_that.judgeName,_that.status,_that.outcomeText,_that.nextHearingAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String caseId, @JsonKey(name: 'case')  CaseSummary? caseSummary,  String courtId,  Court? court,  String? circuitId,  String hearingTypeId,  DateTime scheduledAt,  String? judgeName, @JsonKey(unknownEnumValue: HearingStatus.unknown)  HearingStatus status,  String? outcomeText,  DateTime? nextHearingAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Hearing() when $default != null:
return $default(_that.id,_that.caseId,_that.caseSummary,_that.courtId,_that.court,_that.circuitId,_that.hearingTypeId,_that.scheduledAt,_that.judgeName,_that.status,_that.outcomeText,_that.nextHearingAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Hearing implements Hearing {
  const _Hearing({required this.id, required this.caseId, @JsonKey(name: 'case') this.caseSummary, required this.courtId, this.court, this.circuitId, required this.hearingTypeId, required this.scheduledAt, this.judgeName, @JsonKey(unknownEnumValue: HearingStatus.unknown) required this.status, this.outcomeText, this.nextHearingAt, required this.createdAt, required this.updatedAt});
  factory _Hearing.fromJson(Map<String, dynamic> json) => _$HearingFromJson(json);

@override final  String id;
@override final  String caseId;
@override@JsonKey(name: 'case') final  CaseSummary? caseSummary;
@override final  String courtId;
@override final  Court? court;
@override final  String? circuitId;
@override final  String hearingTypeId;
@override final  DateTime scheduledAt;
@override final  String? judgeName;
@override@JsonKey(unknownEnumValue: HearingStatus.unknown) final  HearingStatus status;
@override final  String? outcomeText;
@override final  DateTime? nextHearingAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Hearing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HearingCopyWith<_Hearing> get copyWith => __$HearingCopyWithImpl<_Hearing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HearingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Hearing&&(identical(other.id, id) || other.id == id)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseSummary, caseSummary) || other.caseSummary == caseSummary)&&(identical(other.courtId, courtId) || other.courtId == courtId)&&(identical(other.court, court) || other.court == court)&&(identical(other.circuitId, circuitId) || other.circuitId == circuitId)&&(identical(other.hearingTypeId, hearingTypeId) || other.hearingTypeId == hearingTypeId)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.judgeName, judgeName) || other.judgeName == judgeName)&&(identical(other.status, status) || other.status == status)&&(identical(other.outcomeText, outcomeText) || other.outcomeText == outcomeText)&&(identical(other.nextHearingAt, nextHearingAt) || other.nextHearingAt == nextHearingAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,caseId,caseSummary,courtId,court,circuitId,hearingTypeId,scheduledAt,judgeName,status,outcomeText,nextHearingAt,createdAt,updatedAt);

@override
String toString() {
  return 'Hearing(id: $id, caseId: $caseId, caseSummary: $caseSummary, courtId: $courtId, court: $court, circuitId: $circuitId, hearingTypeId: $hearingTypeId, scheduledAt: $scheduledAt, judgeName: $judgeName, status: $status, outcomeText: $outcomeText, nextHearingAt: $nextHearingAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$HearingCopyWith<$Res> implements $HearingCopyWith<$Res> {
  factory _$HearingCopyWith(_Hearing value, $Res Function(_Hearing) _then) = __$HearingCopyWithImpl;
@override @useResult
$Res call({
 String id, String caseId,@JsonKey(name: 'case') CaseSummary? caseSummary, String courtId, Court? court, String? circuitId, String hearingTypeId, DateTime scheduledAt, String? judgeName,@JsonKey(unknownEnumValue: HearingStatus.unknown) HearingStatus status, String? outcomeText, DateTime? nextHearingAt, DateTime createdAt, DateTime updatedAt
});


@override $CaseSummaryCopyWith<$Res>? get caseSummary;@override $CourtCopyWith<$Res>? get court;

}
/// @nodoc
class __$HearingCopyWithImpl<$Res>
    implements _$HearingCopyWith<$Res> {
  __$HearingCopyWithImpl(this._self, this._then);

  final _Hearing _self;
  final $Res Function(_Hearing) _then;

/// Create a copy of Hearing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? caseId = null,Object? caseSummary = freezed,Object? courtId = null,Object? court = freezed,Object? circuitId = freezed,Object? hearingTypeId = null,Object? scheduledAt = null,Object? judgeName = freezed,Object? status = null,Object? outcomeText = freezed,Object? nextHearingAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Hearing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,caseSummary: freezed == caseSummary ? _self.caseSummary : caseSummary // ignore: cast_nullable_to_non_nullable
as CaseSummary?,courtId: null == courtId ? _self.courtId : courtId // ignore: cast_nullable_to_non_nullable
as String,court: freezed == court ? _self.court : court // ignore: cast_nullable_to_non_nullable
as Court?,circuitId: freezed == circuitId ? _self.circuitId : circuitId // ignore: cast_nullable_to_non_nullable
as String?,hearingTypeId: null == hearingTypeId ? _self.hearingTypeId : hearingTypeId // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,judgeName: freezed == judgeName ? _self.judgeName : judgeName // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HearingStatus,outcomeText: freezed == outcomeText ? _self.outcomeText : outcomeText // ignore: cast_nullable_to_non_nullable
as String?,nextHearingAt: freezed == nextHearingAt ? _self.nextHearingAt : nextHearingAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Hearing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CaseSummaryCopyWith<$Res>? get caseSummary {
    if (_self.caseSummary == null) {
    return null;
  }

  return $CaseSummaryCopyWith<$Res>(_self.caseSummary!, (value) {
    return _then(_self.copyWith(caseSummary: value));
  });
}/// Create a copy of Hearing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CourtCopyWith<$Res>? get court {
    if (_self.court == null) {
    return null;
  }

  return $CourtCopyWith<$Res>(_self.court!, (value) {
    return _then(_self.copyWith(court: value));
  });
}
}

// dart format on
