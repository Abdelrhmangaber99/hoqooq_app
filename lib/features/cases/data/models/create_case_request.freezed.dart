// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_case_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateCaseRequest {

 String get caseNumber; String get clientId; String get caseTypeId; String? get defaultCourtId; CaseStatus? get status; DateTime? get openingDate; DateTime? get closingDate; String? get outcomeSummary; double? get agreedFee; CasePriority? get priority;
/// Create a copy of CreateCaseRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateCaseRequestCopyWith<CreateCaseRequest> get copyWith => _$CreateCaseRequestCopyWithImpl<CreateCaseRequest>(this as CreateCaseRequest, _$identity);

  /// Serializes this CreateCaseRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateCaseRequest&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.caseTypeId, caseTypeId) || other.caseTypeId == caseTypeId)&&(identical(other.defaultCourtId, defaultCourtId) || other.defaultCourtId == defaultCourtId)&&(identical(other.status, status) || other.status == status)&&(identical(other.openingDate, openingDate) || other.openingDate == openingDate)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate)&&(identical(other.outcomeSummary, outcomeSummary) || other.outcomeSummary == outcomeSummary)&&(identical(other.agreedFee, agreedFee) || other.agreedFee == agreedFee)&&(identical(other.priority, priority) || other.priority == priority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseNumber,clientId,caseTypeId,defaultCourtId,status,openingDate,closingDate,outcomeSummary,agreedFee,priority);

@override
String toString() {
  return 'CreateCaseRequest(caseNumber: $caseNumber, clientId: $clientId, caseTypeId: $caseTypeId, defaultCourtId: $defaultCourtId, status: $status, openingDate: $openingDate, closingDate: $closingDate, outcomeSummary: $outcomeSummary, agreedFee: $agreedFee, priority: $priority)';
}


}

/// @nodoc
abstract mixin class $CreateCaseRequestCopyWith<$Res>  {
  factory $CreateCaseRequestCopyWith(CreateCaseRequest value, $Res Function(CreateCaseRequest) _then) = _$CreateCaseRequestCopyWithImpl;
@useResult
$Res call({
 String caseNumber, String clientId, String caseTypeId, String? defaultCourtId, CaseStatus? status, DateTime? openingDate, DateTime? closingDate, String? outcomeSummary, double? agreedFee, CasePriority? priority
});




}
/// @nodoc
class _$CreateCaseRequestCopyWithImpl<$Res>
    implements $CreateCaseRequestCopyWith<$Res> {
  _$CreateCaseRequestCopyWithImpl(this._self, this._then);

  final CreateCaseRequest _self;
  final $Res Function(CreateCaseRequest) _then;

/// Create a copy of CreateCaseRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? caseNumber = null,Object? clientId = null,Object? caseTypeId = null,Object? defaultCourtId = freezed,Object? status = freezed,Object? openingDate = freezed,Object? closingDate = freezed,Object? outcomeSummary = freezed,Object? agreedFee = freezed,Object? priority = freezed,}) {
  return _then(_self.copyWith(
caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,caseTypeId: null == caseTypeId ? _self.caseTypeId : caseTypeId // ignore: cast_nullable_to_non_nullable
as String,defaultCourtId: freezed == defaultCourtId ? _self.defaultCourtId : defaultCourtId // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CaseStatus?,openingDate: freezed == openingDate ? _self.openingDate : openingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,closingDate: freezed == closingDate ? _self.closingDate : closingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,outcomeSummary: freezed == outcomeSummary ? _self.outcomeSummary : outcomeSummary // ignore: cast_nullable_to_non_nullable
as String?,agreedFee: freezed == agreedFee ? _self.agreedFee : agreedFee // ignore: cast_nullable_to_non_nullable
as double?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as CasePriority?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateCaseRequest].
extension CreateCaseRequestPatterns on CreateCaseRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateCaseRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateCaseRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateCaseRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateCaseRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateCaseRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateCaseRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String caseNumber,  String clientId,  String caseTypeId,  String? defaultCourtId,  CaseStatus? status,  DateTime? openingDate,  DateTime? closingDate,  String? outcomeSummary,  double? agreedFee,  CasePriority? priority)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateCaseRequest() when $default != null:
return $default(_that.caseNumber,_that.clientId,_that.caseTypeId,_that.defaultCourtId,_that.status,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.agreedFee,_that.priority);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String caseNumber,  String clientId,  String caseTypeId,  String? defaultCourtId,  CaseStatus? status,  DateTime? openingDate,  DateTime? closingDate,  String? outcomeSummary,  double? agreedFee,  CasePriority? priority)  $default,) {final _that = this;
switch (_that) {
case _CreateCaseRequest():
return $default(_that.caseNumber,_that.clientId,_that.caseTypeId,_that.defaultCourtId,_that.status,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.agreedFee,_that.priority);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String caseNumber,  String clientId,  String caseTypeId,  String? defaultCourtId,  CaseStatus? status,  DateTime? openingDate,  DateTime? closingDate,  String? outcomeSummary,  double? agreedFee,  CasePriority? priority)?  $default,) {final _that = this;
switch (_that) {
case _CreateCaseRequest() when $default != null:
return $default(_that.caseNumber,_that.clientId,_that.caseTypeId,_that.defaultCourtId,_that.status,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.agreedFee,_that.priority);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateCaseRequest implements CreateCaseRequest {
  const _CreateCaseRequest({required this.caseNumber, required this.clientId, required this.caseTypeId, this.defaultCourtId, this.status, this.openingDate, this.closingDate, this.outcomeSummary, this.agreedFee, this.priority});
  factory _CreateCaseRequest.fromJson(Map<String, dynamic> json) => _$CreateCaseRequestFromJson(json);

@override final  String caseNumber;
@override final  String clientId;
@override final  String caseTypeId;
@override final  String? defaultCourtId;
@override final  CaseStatus? status;
@override final  DateTime? openingDate;
@override final  DateTime? closingDate;
@override final  String? outcomeSummary;
@override final  double? agreedFee;
@override final  CasePriority? priority;

/// Create a copy of CreateCaseRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateCaseRequestCopyWith<_CreateCaseRequest> get copyWith => __$CreateCaseRequestCopyWithImpl<_CreateCaseRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateCaseRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateCaseRequest&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.caseTypeId, caseTypeId) || other.caseTypeId == caseTypeId)&&(identical(other.defaultCourtId, defaultCourtId) || other.defaultCourtId == defaultCourtId)&&(identical(other.status, status) || other.status == status)&&(identical(other.openingDate, openingDate) || other.openingDate == openingDate)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate)&&(identical(other.outcomeSummary, outcomeSummary) || other.outcomeSummary == outcomeSummary)&&(identical(other.agreedFee, agreedFee) || other.agreedFee == agreedFee)&&(identical(other.priority, priority) || other.priority == priority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseNumber,clientId,caseTypeId,defaultCourtId,status,openingDate,closingDate,outcomeSummary,agreedFee,priority);

@override
String toString() {
  return 'CreateCaseRequest(caseNumber: $caseNumber, clientId: $clientId, caseTypeId: $caseTypeId, defaultCourtId: $defaultCourtId, status: $status, openingDate: $openingDate, closingDate: $closingDate, outcomeSummary: $outcomeSummary, agreedFee: $agreedFee, priority: $priority)';
}


}

/// @nodoc
abstract mixin class _$CreateCaseRequestCopyWith<$Res> implements $CreateCaseRequestCopyWith<$Res> {
  factory _$CreateCaseRequestCopyWith(_CreateCaseRequest value, $Res Function(_CreateCaseRequest) _then) = __$CreateCaseRequestCopyWithImpl;
@override @useResult
$Res call({
 String caseNumber, String clientId, String caseTypeId, String? defaultCourtId, CaseStatus? status, DateTime? openingDate, DateTime? closingDate, String? outcomeSummary, double? agreedFee, CasePriority? priority
});




}
/// @nodoc
class __$CreateCaseRequestCopyWithImpl<$Res>
    implements _$CreateCaseRequestCopyWith<$Res> {
  __$CreateCaseRequestCopyWithImpl(this._self, this._then);

  final _CreateCaseRequest _self;
  final $Res Function(_CreateCaseRequest) _then;

/// Create a copy of CreateCaseRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? caseNumber = null,Object? clientId = null,Object? caseTypeId = null,Object? defaultCourtId = freezed,Object? status = freezed,Object? openingDate = freezed,Object? closingDate = freezed,Object? outcomeSummary = freezed,Object? agreedFee = freezed,Object? priority = freezed,}) {
  return _then(_CreateCaseRequest(
caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,caseTypeId: null == caseTypeId ? _self.caseTypeId : caseTypeId // ignore: cast_nullable_to_non_nullable
as String,defaultCourtId: freezed == defaultCourtId ? _self.defaultCourtId : defaultCourtId // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CaseStatus?,openingDate: freezed == openingDate ? _self.openingDate : openingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,closingDate: freezed == closingDate ? _self.closingDate : closingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,outcomeSummary: freezed == outcomeSummary ? _self.outcomeSummary : outcomeSummary // ignore: cast_nullable_to_non_nullable
as String?,agreedFee: freezed == agreedFee ? _self.agreedFee : agreedFee // ignore: cast_nullable_to_non_nullable
as double?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as CasePriority?,
  ));
}


}

// dart format on
