// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_hearing_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateHearingRequest {

@JsonKey(includeIfNull: false) String? get courtId;@JsonKey(includeIfNull: false) DateTime? get scheduledAt;@JsonKey(includeIfNull: false) String? get judgeName;@JsonKey(includeIfNull: false) HearingStatus? get status;@JsonKey(includeIfNull: false) String? get outcomeText;@JsonKey(includeIfNull: false) DateTime? get nextHearingAt;
/// Create a copy of UpdateHearingRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateHearingRequestCopyWith<UpdateHearingRequest> get copyWith => _$UpdateHearingRequestCopyWithImpl<UpdateHearingRequest>(this as UpdateHearingRequest, _$identity);

  /// Serializes this UpdateHearingRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateHearingRequest&&(identical(other.courtId, courtId) || other.courtId == courtId)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.judgeName, judgeName) || other.judgeName == judgeName)&&(identical(other.status, status) || other.status == status)&&(identical(other.outcomeText, outcomeText) || other.outcomeText == outcomeText)&&(identical(other.nextHearingAt, nextHearingAt) || other.nextHearingAt == nextHearingAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,courtId,scheduledAt,judgeName,status,outcomeText,nextHearingAt);

@override
String toString() {
  return 'UpdateHearingRequest(courtId: $courtId, scheduledAt: $scheduledAt, judgeName: $judgeName, status: $status, outcomeText: $outcomeText, nextHearingAt: $nextHearingAt)';
}


}

/// @nodoc
abstract mixin class $UpdateHearingRequestCopyWith<$Res>  {
  factory $UpdateHearingRequestCopyWith(UpdateHearingRequest value, $Res Function(UpdateHearingRequest) _then) = _$UpdateHearingRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? courtId,@JsonKey(includeIfNull: false) DateTime? scheduledAt,@JsonKey(includeIfNull: false) String? judgeName,@JsonKey(includeIfNull: false) HearingStatus? status,@JsonKey(includeIfNull: false) String? outcomeText,@JsonKey(includeIfNull: false) DateTime? nextHearingAt
});




}
/// @nodoc
class _$UpdateHearingRequestCopyWithImpl<$Res>
    implements $UpdateHearingRequestCopyWith<$Res> {
  _$UpdateHearingRequestCopyWithImpl(this._self, this._then);

  final UpdateHearingRequest _self;
  final $Res Function(UpdateHearingRequest) _then;

/// Create a copy of UpdateHearingRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? courtId = freezed,Object? scheduledAt = freezed,Object? judgeName = freezed,Object? status = freezed,Object? outcomeText = freezed,Object? nextHearingAt = freezed,}) {
  return _then(_self.copyWith(
courtId: freezed == courtId ? _self.courtId : courtId // ignore: cast_nullable_to_non_nullable
as String?,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,judgeName: freezed == judgeName ? _self.judgeName : judgeName // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HearingStatus?,outcomeText: freezed == outcomeText ? _self.outcomeText : outcomeText // ignore: cast_nullable_to_non_nullable
as String?,nextHearingAt: freezed == nextHearingAt ? _self.nextHearingAt : nextHearingAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateHearingRequest].
extension UpdateHearingRequestPatterns on UpdateHearingRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateHearingRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateHearingRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateHearingRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateHearingRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateHearingRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateHearingRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? courtId, @JsonKey(includeIfNull: false)  DateTime? scheduledAt, @JsonKey(includeIfNull: false)  String? judgeName, @JsonKey(includeIfNull: false)  HearingStatus? status, @JsonKey(includeIfNull: false)  String? outcomeText, @JsonKey(includeIfNull: false)  DateTime? nextHearingAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateHearingRequest() when $default != null:
return $default(_that.courtId,_that.scheduledAt,_that.judgeName,_that.status,_that.outcomeText,_that.nextHearingAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? courtId, @JsonKey(includeIfNull: false)  DateTime? scheduledAt, @JsonKey(includeIfNull: false)  String? judgeName, @JsonKey(includeIfNull: false)  HearingStatus? status, @JsonKey(includeIfNull: false)  String? outcomeText, @JsonKey(includeIfNull: false)  DateTime? nextHearingAt)  $default,) {final _that = this;
switch (_that) {
case _UpdateHearingRequest():
return $default(_that.courtId,_that.scheduledAt,_that.judgeName,_that.status,_that.outcomeText,_that.nextHearingAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? courtId, @JsonKey(includeIfNull: false)  DateTime? scheduledAt, @JsonKey(includeIfNull: false)  String? judgeName, @JsonKey(includeIfNull: false)  HearingStatus? status, @JsonKey(includeIfNull: false)  String? outcomeText, @JsonKey(includeIfNull: false)  DateTime? nextHearingAt)?  $default,) {final _that = this;
switch (_that) {
case _UpdateHearingRequest() when $default != null:
return $default(_that.courtId,_that.scheduledAt,_that.judgeName,_that.status,_that.outcomeText,_that.nextHearingAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateHearingRequest implements UpdateHearingRequest {
  const _UpdateHearingRequest({@JsonKey(includeIfNull: false) this.courtId, @JsonKey(includeIfNull: false) this.scheduledAt, @JsonKey(includeIfNull: false) this.judgeName, @JsonKey(includeIfNull: false) this.status, @JsonKey(includeIfNull: false) this.outcomeText, @JsonKey(includeIfNull: false) this.nextHearingAt});
  factory _UpdateHearingRequest.fromJson(Map<String, dynamic> json) => _$UpdateHearingRequestFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? courtId;
@override@JsonKey(includeIfNull: false) final  DateTime? scheduledAt;
@override@JsonKey(includeIfNull: false) final  String? judgeName;
@override@JsonKey(includeIfNull: false) final  HearingStatus? status;
@override@JsonKey(includeIfNull: false) final  String? outcomeText;
@override@JsonKey(includeIfNull: false) final  DateTime? nextHearingAt;

/// Create a copy of UpdateHearingRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateHearingRequestCopyWith<_UpdateHearingRequest> get copyWith => __$UpdateHearingRequestCopyWithImpl<_UpdateHearingRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateHearingRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateHearingRequest&&(identical(other.courtId, courtId) || other.courtId == courtId)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.judgeName, judgeName) || other.judgeName == judgeName)&&(identical(other.status, status) || other.status == status)&&(identical(other.outcomeText, outcomeText) || other.outcomeText == outcomeText)&&(identical(other.nextHearingAt, nextHearingAt) || other.nextHearingAt == nextHearingAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,courtId,scheduledAt,judgeName,status,outcomeText,nextHearingAt);

@override
String toString() {
  return 'UpdateHearingRequest(courtId: $courtId, scheduledAt: $scheduledAt, judgeName: $judgeName, status: $status, outcomeText: $outcomeText, nextHearingAt: $nextHearingAt)';
}


}

/// @nodoc
abstract mixin class _$UpdateHearingRequestCopyWith<$Res> implements $UpdateHearingRequestCopyWith<$Res> {
  factory _$UpdateHearingRequestCopyWith(_UpdateHearingRequest value, $Res Function(_UpdateHearingRequest) _then) = __$UpdateHearingRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? courtId,@JsonKey(includeIfNull: false) DateTime? scheduledAt,@JsonKey(includeIfNull: false) String? judgeName,@JsonKey(includeIfNull: false) HearingStatus? status,@JsonKey(includeIfNull: false) String? outcomeText,@JsonKey(includeIfNull: false) DateTime? nextHearingAt
});




}
/// @nodoc
class __$UpdateHearingRequestCopyWithImpl<$Res>
    implements _$UpdateHearingRequestCopyWith<$Res> {
  __$UpdateHearingRequestCopyWithImpl(this._self, this._then);

  final _UpdateHearingRequest _self;
  final $Res Function(_UpdateHearingRequest) _then;

/// Create a copy of UpdateHearingRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? courtId = freezed,Object? scheduledAt = freezed,Object? judgeName = freezed,Object? status = freezed,Object? outcomeText = freezed,Object? nextHearingAt = freezed,}) {
  return _then(_UpdateHearingRequest(
courtId: freezed == courtId ? _self.courtId : courtId // ignore: cast_nullable_to_non_nullable
as String?,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,judgeName: freezed == judgeName ? _self.judgeName : judgeName // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HearingStatus?,outcomeText: freezed == outcomeText ? _self.outcomeText : outcomeText // ignore: cast_nullable_to_non_nullable
as String?,nextHearingAt: freezed == nextHearingAt ? _self.nextHearingAt : nextHearingAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
