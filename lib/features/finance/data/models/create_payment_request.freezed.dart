// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_payment_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatePaymentRequest {

 String get invoiceId; double get amount; DateTime get paymentDate;@JsonKey(unknownEnumValue: PaymentMethod.unknown) PaymentMethod get method; String? get referenceNumber;
/// Create a copy of CreatePaymentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePaymentRequestCopyWith<CreatePaymentRequest> get copyWith => _$CreatePaymentRequestCopyWithImpl<CreatePaymentRequest>(this as CreatePaymentRequest, _$identity);

  /// Serializes this CreatePaymentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePaymentRequest&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.method, method) || other.method == method)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invoiceId,amount,paymentDate,method,referenceNumber);

@override
String toString() {
  return 'CreatePaymentRequest(invoiceId: $invoiceId, amount: $amount, paymentDate: $paymentDate, method: $method, referenceNumber: $referenceNumber)';
}


}

/// @nodoc
abstract mixin class $CreatePaymentRequestCopyWith<$Res>  {
  factory $CreatePaymentRequestCopyWith(CreatePaymentRequest value, $Res Function(CreatePaymentRequest) _then) = _$CreatePaymentRequestCopyWithImpl;
@useResult
$Res call({
 String invoiceId, double amount, DateTime paymentDate,@JsonKey(unknownEnumValue: PaymentMethod.unknown) PaymentMethod method, String? referenceNumber
});




}
/// @nodoc
class _$CreatePaymentRequestCopyWithImpl<$Res>
    implements $CreatePaymentRequestCopyWith<$Res> {
  _$CreatePaymentRequestCopyWithImpl(this._self, this._then);

  final CreatePaymentRequest _self;
  final $Res Function(CreatePaymentRequest) _then;

/// Create a copy of CreatePaymentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? invoiceId = null,Object? amount = null,Object? paymentDate = null,Object? method = null,Object? referenceNumber = freezed,}) {
  return _then(_self.copyWith(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,referenceNumber: freezed == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatePaymentRequest].
extension CreatePaymentRequestPatterns on CreatePaymentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePaymentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePaymentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePaymentRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreatePaymentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePaymentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePaymentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String invoiceId,  double amount,  DateTime paymentDate, @JsonKey(unknownEnumValue: PaymentMethod.unknown)  PaymentMethod method,  String? referenceNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePaymentRequest() when $default != null:
return $default(_that.invoiceId,_that.amount,_that.paymentDate,_that.method,_that.referenceNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String invoiceId,  double amount,  DateTime paymentDate, @JsonKey(unknownEnumValue: PaymentMethod.unknown)  PaymentMethod method,  String? referenceNumber)  $default,) {final _that = this;
switch (_that) {
case _CreatePaymentRequest():
return $default(_that.invoiceId,_that.amount,_that.paymentDate,_that.method,_that.referenceNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String invoiceId,  double amount,  DateTime paymentDate, @JsonKey(unknownEnumValue: PaymentMethod.unknown)  PaymentMethod method,  String? referenceNumber)?  $default,) {final _that = this;
switch (_that) {
case _CreatePaymentRequest() when $default != null:
return $default(_that.invoiceId,_that.amount,_that.paymentDate,_that.method,_that.referenceNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreatePaymentRequest implements CreatePaymentRequest {
  const _CreatePaymentRequest({required this.invoiceId, required this.amount, required this.paymentDate, @JsonKey(unknownEnumValue: PaymentMethod.unknown) required this.method, this.referenceNumber});
  factory _CreatePaymentRequest.fromJson(Map<String, dynamic> json) => _$CreatePaymentRequestFromJson(json);

@override final  String invoiceId;
@override final  double amount;
@override final  DateTime paymentDate;
@override@JsonKey(unknownEnumValue: PaymentMethod.unknown) final  PaymentMethod method;
@override final  String? referenceNumber;

/// Create a copy of CreatePaymentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePaymentRequestCopyWith<_CreatePaymentRequest> get copyWith => __$CreatePaymentRequestCopyWithImpl<_CreatePaymentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreatePaymentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePaymentRequest&&(identical(other.invoiceId, invoiceId) || other.invoiceId == invoiceId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.method, method) || other.method == method)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,invoiceId,amount,paymentDate,method,referenceNumber);

@override
String toString() {
  return 'CreatePaymentRequest(invoiceId: $invoiceId, amount: $amount, paymentDate: $paymentDate, method: $method, referenceNumber: $referenceNumber)';
}


}

/// @nodoc
abstract mixin class _$CreatePaymentRequestCopyWith<$Res> implements $CreatePaymentRequestCopyWith<$Res> {
  factory _$CreatePaymentRequestCopyWith(_CreatePaymentRequest value, $Res Function(_CreatePaymentRequest) _then) = __$CreatePaymentRequestCopyWithImpl;
@override @useResult
$Res call({
 String invoiceId, double amount, DateTime paymentDate,@JsonKey(unknownEnumValue: PaymentMethod.unknown) PaymentMethod method, String? referenceNumber
});




}
/// @nodoc
class __$CreatePaymentRequestCopyWithImpl<$Res>
    implements _$CreatePaymentRequestCopyWith<$Res> {
  __$CreatePaymentRequestCopyWithImpl(this._self, this._then);

  final _CreatePaymentRequest _self;
  final $Res Function(_CreatePaymentRequest) _then;

/// Create a copy of CreatePaymentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? invoiceId = null,Object? amount = null,Object? paymentDate = null,Object? method = null,Object? referenceNumber = freezed,}) {
  return _then(_CreatePaymentRequest(
invoiceId: null == invoiceId ? _self.invoiceId : invoiceId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,referenceNumber: freezed == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
