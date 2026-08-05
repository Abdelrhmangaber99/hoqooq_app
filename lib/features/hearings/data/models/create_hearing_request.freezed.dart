// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_hearing_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateHearingRequest {

 String get caseId; String get courtId; String get hearingTypeId; DateTime get scheduledAt; String? get circuitId; String? get judgeName; HearingStatus? get status; String? get outcomeText; DateTime? get nextHearingAt;
/// Create a copy of CreateHearingRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateHearingRequestCopyWith<CreateHearingRequest> get copyWith => _$CreateHearingRequestCopyWithImpl<CreateHearingRequest>(this as CreateHearingRequest, _$identity);

  /// Serializes this CreateHearingRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateHearingRequest&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.courtId, courtId) || other.courtId == courtId)&&(identical(other.hearingTypeId, hearingTypeId) || other.hearingTypeId == hearingTypeId)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.circuitId, circuitId) || other.circuitId == circuitId)&&(identical(other.judgeName, judgeName) || other.judgeName == judgeName)&&(identical(other.status, status) || other.status == status)&&(identical(other.outcomeText, outcomeText) || other.outcomeText == outcomeText)&&(identical(other.nextHearingAt, nextHearingAt) || other.nextHearingAt == nextHearingAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseId,courtId,hearingTypeId,scheduledAt,circuitId,judgeName,status,outcomeText,nextHearingAt);

@override
String toString() {
  return 'CreateHearingRequest(caseId: $caseId, courtId: $courtId, hearingTypeId: $hearingTypeId, scheduledAt: $scheduledAt, circuitId: $circuitId, judgeName: $judgeName, status: $status, outcomeText: $outcomeText, nextHearingAt: $nextHearingAt)';
}


}

/// @nodoc
abstract mixin class $CreateHearingRequestCopyWith<$Res>  {
  factory $CreateHearingRequestCopyWith(CreateHearingRequest value, $Res Function(CreateHearingRequest) _then) = _$CreateHearingRequestCopyWithImpl;
@useResult
$Res call({
 String caseId, String courtId, String hearingTypeId, DateTime scheduledAt, String? circuitId, String? judgeName, HearingStatus? status, String? outcomeText, DateTime? nextHearingAt
});




}
/// @nodoc
class _$CreateHearingRequestCopyWithImpl<$Res>
    implements $CreateHearingRequestCopyWith<$Res> {
  _$CreateHearingRequestCopyWithImpl(this._self, this._then);

  final CreateHearingRequest _self;
  final $Res Function(CreateHearingRequest) _then;

/// Create a copy of CreateHearingRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? caseId = null,Object? courtId = null,Object? hearingTypeId = null,Object? scheduledAt = null,Object? circuitId = freezed,Object? judgeName = freezed,Object? status = freezed,Object? outcomeText = freezed,Object? nextHearingAt = freezed,}) {
  return _then(_self.copyWith(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,courtId: null == courtId ? _self.courtId : courtId // ignore: cast_nullable_to_non_nullable
as String,hearingTypeId: null == hearingTypeId ? _self.hearingTypeId : hearingTypeId // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,circuitId: freezed == circuitId ? _self.circuitId : circuitId // ignore: cast_nullable_to_non_nullable
as String?,judgeName: freezed == judgeName ? _self.judgeName : judgeName // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HearingStatus?,outcomeText: freezed == outcomeText ? _self.outcomeText : outcomeText // ignore: cast_nullable_to_non_nullable
as String?,nextHearingAt: freezed == nextHearingAt ? _self.nextHearingAt : nextHearingAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateHearingRequest].
extension CreateHearingRequestPatterns on CreateHearingRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateHearingRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateHearingRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateHearingRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateHearingRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateHearingRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateHearingRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String caseId,  String courtId,  String hearingTypeId,  DateTime scheduledAt,  String? circuitId,  String? judgeName,  HearingStatus? status,  String? outcomeText,  DateTime? nextHearingAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateHearingRequest() when $default != null:
return $default(_that.caseId,_that.courtId,_that.hearingTypeId,_that.scheduledAt,_that.circuitId,_that.judgeName,_that.status,_that.outcomeText,_that.nextHearingAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String caseId,  String courtId,  String hearingTypeId,  DateTime scheduledAt,  String? circuitId,  String? judgeName,  HearingStatus? status,  String? outcomeText,  DateTime? nextHearingAt)  $default,) {final _that = this;
switch (_that) {
case _CreateHearingRequest():
return $default(_that.caseId,_that.courtId,_that.hearingTypeId,_that.scheduledAt,_that.circuitId,_that.judgeName,_that.status,_that.outcomeText,_that.nextHearingAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String caseId,  String courtId,  String hearingTypeId,  DateTime scheduledAt,  String? circuitId,  String? judgeName,  HearingStatus? status,  String? outcomeText,  DateTime? nextHearingAt)?  $default,) {final _that = this;
switch (_that) {
case _CreateHearingRequest() when $default != null:
return $default(_that.caseId,_that.courtId,_that.hearingTypeId,_that.scheduledAt,_that.circuitId,_that.judgeName,_that.status,_that.outcomeText,_that.nextHearingAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateHearingRequest implements CreateHearingRequest {
  const _CreateHearingRequest({required this.caseId, required this.courtId, required this.hearingTypeId, required this.scheduledAt, this.circuitId, this.judgeName, this.status, this.outcomeText, this.nextHearingAt});
  factory _CreateHearingRequest.fromJson(Map<String, dynamic> json) => _$CreateHearingRequestFromJson(json);

@override final  String caseId;
@override final  String courtId;
@override final  String hearingTypeId;
@override final  DateTime scheduledAt;
@override final  String? circuitId;
@override final  String? judgeName;
@override final  HearingStatus? status;
@override final  String? outcomeText;
@override final  DateTime? nextHearingAt;

/// Create a copy of CreateHearingRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateHearingRequestCopyWith<_CreateHearingRequest> get copyWith => __$CreateHearingRequestCopyWithImpl<_CreateHearingRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateHearingRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateHearingRequest&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.courtId, courtId) || other.courtId == courtId)&&(identical(other.hearingTypeId, hearingTypeId) || other.hearingTypeId == hearingTypeId)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.circuitId, circuitId) || other.circuitId == circuitId)&&(identical(other.judgeName, judgeName) || other.judgeName == judgeName)&&(identical(other.status, status) || other.status == status)&&(identical(other.outcomeText, outcomeText) || other.outcomeText == outcomeText)&&(identical(other.nextHearingAt, nextHearingAt) || other.nextHearingAt == nextHearingAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseId,courtId,hearingTypeId,scheduledAt,circuitId,judgeName,status,outcomeText,nextHearingAt);

@override
String toString() {
  return 'CreateHearingRequest(caseId: $caseId, courtId: $courtId, hearingTypeId: $hearingTypeId, scheduledAt: $scheduledAt, circuitId: $circuitId, judgeName: $judgeName, status: $status, outcomeText: $outcomeText, nextHearingAt: $nextHearingAt)';
}


}

/// @nodoc
abstract mixin class _$CreateHearingRequestCopyWith<$Res> implements $CreateHearingRequestCopyWith<$Res> {
  factory _$CreateHearingRequestCopyWith(_CreateHearingRequest value, $Res Function(_CreateHearingRequest) _then) = __$CreateHearingRequestCopyWithImpl;
@override @useResult
$Res call({
 String caseId, String courtId, String hearingTypeId, DateTime scheduledAt, String? circuitId, String? judgeName, HearingStatus? status, String? outcomeText, DateTime? nextHearingAt
});




}
/// @nodoc
class __$CreateHearingRequestCopyWithImpl<$Res>
    implements _$CreateHearingRequestCopyWith<$Res> {
  __$CreateHearingRequestCopyWithImpl(this._self, this._then);

  final _CreateHearingRequest _self;
  final $Res Function(_CreateHearingRequest) _then;

/// Create a copy of CreateHearingRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? caseId = null,Object? courtId = null,Object? hearingTypeId = null,Object? scheduledAt = null,Object? circuitId = freezed,Object? judgeName = freezed,Object? status = freezed,Object? outcomeText = freezed,Object? nextHearingAt = freezed,}) {
  return _then(_CreateHearingRequest(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,courtId: null == courtId ? _self.courtId : courtId // ignore: cast_nullable_to_non_nullable
as String,hearingTypeId: null == hearingTypeId ? _self.hearingTypeId : hearingTypeId // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,circuitId: freezed == circuitId ? _self.circuitId : circuitId // ignore: cast_nullable_to_non_nullable
as String?,judgeName: freezed == judgeName ? _self.judgeName : judgeName // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HearingStatus?,outcomeText: freezed == outcomeText ? _self.outcomeText : outcomeText // ignore: cast_nullable_to_non_nullable
as String?,nextHearingAt: freezed == nextHearingAt ? _self.nextHearingAt : nextHearingAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
