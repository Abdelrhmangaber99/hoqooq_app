// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_case_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateCaseRequest {

@JsonKey(includeIfNull: false) String? get defaultCourtId;@JsonKey(includeIfNull: false) CaseStatus? get status;@JsonKey(includeIfNull: false) DateTime? get openingDate;@JsonKey(includeIfNull: false) DateTime? get closingDate;@JsonKey(includeIfNull: false) String? get outcomeSummary;@JsonKey(includeIfNull: false) double? get agreedFee;@JsonKey(includeIfNull: false) CasePriority? get priority;
/// Create a copy of UpdateCaseRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateCaseRequestCopyWith<UpdateCaseRequest> get copyWith => _$UpdateCaseRequestCopyWithImpl<UpdateCaseRequest>(this as UpdateCaseRequest, _$identity);

  /// Serializes this UpdateCaseRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateCaseRequest&&(identical(other.defaultCourtId, defaultCourtId) || other.defaultCourtId == defaultCourtId)&&(identical(other.status, status) || other.status == status)&&(identical(other.openingDate, openingDate) || other.openingDate == openingDate)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate)&&(identical(other.outcomeSummary, outcomeSummary) || other.outcomeSummary == outcomeSummary)&&(identical(other.agreedFee, agreedFee) || other.agreedFee == agreedFee)&&(identical(other.priority, priority) || other.priority == priority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultCourtId,status,openingDate,closingDate,outcomeSummary,agreedFee,priority);

@override
String toString() {
  return 'UpdateCaseRequest(defaultCourtId: $defaultCourtId, status: $status, openingDate: $openingDate, closingDate: $closingDate, outcomeSummary: $outcomeSummary, agreedFee: $agreedFee, priority: $priority)';
}


}

/// @nodoc
abstract mixin class $UpdateCaseRequestCopyWith<$Res>  {
  factory $UpdateCaseRequestCopyWith(UpdateCaseRequest value, $Res Function(UpdateCaseRequest) _then) = _$UpdateCaseRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? defaultCourtId,@JsonKey(includeIfNull: false) CaseStatus? status,@JsonKey(includeIfNull: false) DateTime? openingDate,@JsonKey(includeIfNull: false) DateTime? closingDate,@JsonKey(includeIfNull: false) String? outcomeSummary,@JsonKey(includeIfNull: false) double? agreedFee,@JsonKey(includeIfNull: false) CasePriority? priority
});




}
/// @nodoc
class _$UpdateCaseRequestCopyWithImpl<$Res>
    implements $UpdateCaseRequestCopyWith<$Res> {
  _$UpdateCaseRequestCopyWithImpl(this._self, this._then);

  final UpdateCaseRequest _self;
  final $Res Function(UpdateCaseRequest) _then;

/// Create a copy of UpdateCaseRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultCourtId = freezed,Object? status = freezed,Object? openingDate = freezed,Object? closingDate = freezed,Object? outcomeSummary = freezed,Object? agreedFee = freezed,Object? priority = freezed,}) {
  return _then(_self.copyWith(
defaultCourtId: freezed == defaultCourtId ? _self.defaultCourtId : defaultCourtId // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [UpdateCaseRequest].
extension UpdateCaseRequestPatterns on UpdateCaseRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateCaseRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateCaseRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateCaseRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateCaseRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateCaseRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateCaseRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? defaultCourtId, @JsonKey(includeIfNull: false)  CaseStatus? status, @JsonKey(includeIfNull: false)  DateTime? openingDate, @JsonKey(includeIfNull: false)  DateTime? closingDate, @JsonKey(includeIfNull: false)  String? outcomeSummary, @JsonKey(includeIfNull: false)  double? agreedFee, @JsonKey(includeIfNull: false)  CasePriority? priority)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateCaseRequest() when $default != null:
return $default(_that.defaultCourtId,_that.status,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.agreedFee,_that.priority);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? defaultCourtId, @JsonKey(includeIfNull: false)  CaseStatus? status, @JsonKey(includeIfNull: false)  DateTime? openingDate, @JsonKey(includeIfNull: false)  DateTime? closingDate, @JsonKey(includeIfNull: false)  String? outcomeSummary, @JsonKey(includeIfNull: false)  double? agreedFee, @JsonKey(includeIfNull: false)  CasePriority? priority)  $default,) {final _that = this;
switch (_that) {
case _UpdateCaseRequest():
return $default(_that.defaultCourtId,_that.status,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.agreedFee,_that.priority);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? defaultCourtId, @JsonKey(includeIfNull: false)  CaseStatus? status, @JsonKey(includeIfNull: false)  DateTime? openingDate, @JsonKey(includeIfNull: false)  DateTime? closingDate, @JsonKey(includeIfNull: false)  String? outcomeSummary, @JsonKey(includeIfNull: false)  double? agreedFee, @JsonKey(includeIfNull: false)  CasePriority? priority)?  $default,) {final _that = this;
switch (_that) {
case _UpdateCaseRequest() when $default != null:
return $default(_that.defaultCourtId,_that.status,_that.openingDate,_that.closingDate,_that.outcomeSummary,_that.agreedFee,_that.priority);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateCaseRequest implements UpdateCaseRequest {
  const _UpdateCaseRequest({@JsonKey(includeIfNull: false) this.defaultCourtId, @JsonKey(includeIfNull: false) this.status, @JsonKey(includeIfNull: false) this.openingDate, @JsonKey(includeIfNull: false) this.closingDate, @JsonKey(includeIfNull: false) this.outcomeSummary, @JsonKey(includeIfNull: false) this.agreedFee, @JsonKey(includeIfNull: false) this.priority});
  factory _UpdateCaseRequest.fromJson(Map<String, dynamic> json) => _$UpdateCaseRequestFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? defaultCourtId;
@override@JsonKey(includeIfNull: false) final  CaseStatus? status;
@override@JsonKey(includeIfNull: false) final  DateTime? openingDate;
@override@JsonKey(includeIfNull: false) final  DateTime? closingDate;
@override@JsonKey(includeIfNull: false) final  String? outcomeSummary;
@override@JsonKey(includeIfNull: false) final  double? agreedFee;
@override@JsonKey(includeIfNull: false) final  CasePriority? priority;

/// Create a copy of UpdateCaseRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateCaseRequestCopyWith<_UpdateCaseRequest> get copyWith => __$UpdateCaseRequestCopyWithImpl<_UpdateCaseRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateCaseRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateCaseRequest&&(identical(other.defaultCourtId, defaultCourtId) || other.defaultCourtId == defaultCourtId)&&(identical(other.status, status) || other.status == status)&&(identical(other.openingDate, openingDate) || other.openingDate == openingDate)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate)&&(identical(other.outcomeSummary, outcomeSummary) || other.outcomeSummary == outcomeSummary)&&(identical(other.agreedFee, agreedFee) || other.agreedFee == agreedFee)&&(identical(other.priority, priority) || other.priority == priority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultCourtId,status,openingDate,closingDate,outcomeSummary,agreedFee,priority);

@override
String toString() {
  return 'UpdateCaseRequest(defaultCourtId: $defaultCourtId, status: $status, openingDate: $openingDate, closingDate: $closingDate, outcomeSummary: $outcomeSummary, agreedFee: $agreedFee, priority: $priority)';
}


}

/// @nodoc
abstract mixin class _$UpdateCaseRequestCopyWith<$Res> implements $UpdateCaseRequestCopyWith<$Res> {
  factory _$UpdateCaseRequestCopyWith(_UpdateCaseRequest value, $Res Function(_UpdateCaseRequest) _then) = __$UpdateCaseRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? defaultCourtId,@JsonKey(includeIfNull: false) CaseStatus? status,@JsonKey(includeIfNull: false) DateTime? openingDate,@JsonKey(includeIfNull: false) DateTime? closingDate,@JsonKey(includeIfNull: false) String? outcomeSummary,@JsonKey(includeIfNull: false) double? agreedFee,@JsonKey(includeIfNull: false) CasePriority? priority
});




}
/// @nodoc
class __$UpdateCaseRequestCopyWithImpl<$Res>
    implements _$UpdateCaseRequestCopyWith<$Res> {
  __$UpdateCaseRequestCopyWithImpl(this._self, this._then);

  final _UpdateCaseRequest _self;
  final $Res Function(_UpdateCaseRequest) _then;

/// Create a copy of UpdateCaseRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultCourtId = freezed,Object? status = freezed,Object? openingDate = freezed,Object? closingDate = freezed,Object? outcomeSummary = freezed,Object? agreedFee = freezed,Object? priority = freezed,}) {
  return _then(_UpdateCaseRequest(
defaultCourtId: freezed == defaultCourtId ? _self.defaultCourtId : defaultCourtId // ignore: cast_nullable_to_non_nullable
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
