// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'case_financial_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaseFinancialSummary {

 String get caseId; String get caseNumber; String get clientName; double get totalInvoiced; double get totalPaid; double get outstandingBalance;@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus get paymentStatus; int get invoicesCount;
/// Create a copy of CaseFinancialSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaseFinancialSummaryCopyWith<CaseFinancialSummary> get copyWith => _$CaseFinancialSummaryCopyWithImpl<CaseFinancialSummary>(this as CaseFinancialSummary, _$identity);

  /// Serializes this CaseFinancialSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaseFinancialSummary&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.totalInvoiced, totalInvoiced) || other.totalInvoiced == totalInvoiced)&&(identical(other.totalPaid, totalPaid) || other.totalPaid == totalPaid)&&(identical(other.outstandingBalance, outstandingBalance) || other.outstandingBalance == outstandingBalance)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.invoicesCount, invoicesCount) || other.invoicesCount == invoicesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseId,caseNumber,clientName,totalInvoiced,totalPaid,outstandingBalance,paymentStatus,invoicesCount);

@override
String toString() {
  return 'CaseFinancialSummary(caseId: $caseId, caseNumber: $caseNumber, clientName: $clientName, totalInvoiced: $totalInvoiced, totalPaid: $totalPaid, outstandingBalance: $outstandingBalance, paymentStatus: $paymentStatus, invoicesCount: $invoicesCount)';
}


}

/// @nodoc
abstract mixin class $CaseFinancialSummaryCopyWith<$Res>  {
  factory $CaseFinancialSummaryCopyWith(CaseFinancialSummary value, $Res Function(CaseFinancialSummary) _then) = _$CaseFinancialSummaryCopyWithImpl;
@useResult
$Res call({
 String caseId, String caseNumber, String clientName, double totalInvoiced, double totalPaid, double outstandingBalance,@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus paymentStatus, int invoicesCount
});




}
/// @nodoc
class _$CaseFinancialSummaryCopyWithImpl<$Res>
    implements $CaseFinancialSummaryCopyWith<$Res> {
  _$CaseFinancialSummaryCopyWithImpl(this._self, this._then);

  final CaseFinancialSummary _self;
  final $Res Function(CaseFinancialSummary) _then;

/// Create a copy of CaseFinancialSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? caseId = null,Object? caseNumber = null,Object? clientName = null,Object? totalInvoiced = null,Object? totalPaid = null,Object? outstandingBalance = null,Object? paymentStatus = null,Object? invoicesCount = null,}) {
  return _then(_self.copyWith(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,totalInvoiced: null == totalInvoiced ? _self.totalInvoiced : totalInvoiced // ignore: cast_nullable_to_non_nullable
as double,totalPaid: null == totalPaid ? _self.totalPaid : totalPaid // ignore: cast_nullable_to_non_nullable
as double,outstandingBalance: null == outstandingBalance ? _self.outstandingBalance : outstandingBalance // ignore: cast_nullable_to_non_nullable
as double,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,invoicesCount: null == invoicesCount ? _self.invoicesCount : invoicesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CaseFinancialSummary].
extension CaseFinancialSummaryPatterns on CaseFinancialSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaseFinancialSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaseFinancialSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaseFinancialSummary value)  $default,){
final _that = this;
switch (_that) {
case _CaseFinancialSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaseFinancialSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CaseFinancialSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String caseId,  String caseNumber,  String clientName,  double totalInvoiced,  double totalPaid,  double outstandingBalance, @JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus paymentStatus,  int invoicesCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaseFinancialSummary() when $default != null:
return $default(_that.caseId,_that.caseNumber,_that.clientName,_that.totalInvoiced,_that.totalPaid,_that.outstandingBalance,_that.paymentStatus,_that.invoicesCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String caseId,  String caseNumber,  String clientName,  double totalInvoiced,  double totalPaid,  double outstandingBalance, @JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus paymentStatus,  int invoicesCount)  $default,) {final _that = this;
switch (_that) {
case _CaseFinancialSummary():
return $default(_that.caseId,_that.caseNumber,_that.clientName,_that.totalInvoiced,_that.totalPaid,_that.outstandingBalance,_that.paymentStatus,_that.invoicesCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String caseId,  String caseNumber,  String clientName,  double totalInvoiced,  double totalPaid,  double outstandingBalance, @JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus paymentStatus,  int invoicesCount)?  $default,) {final _that = this;
switch (_that) {
case _CaseFinancialSummary() when $default != null:
return $default(_that.caseId,_that.caseNumber,_that.clientName,_that.totalInvoiced,_that.totalPaid,_that.outstandingBalance,_that.paymentStatus,_that.invoicesCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaseFinancialSummary implements CaseFinancialSummary {
  const _CaseFinancialSummary({required this.caseId, required this.caseNumber, required this.clientName, required this.totalInvoiced, required this.totalPaid, required this.outstandingBalance, @JsonKey(unknownEnumValue: PaymentStatus.unknown) required this.paymentStatus, required this.invoicesCount});
  factory _CaseFinancialSummary.fromJson(Map<String, dynamic> json) => _$CaseFinancialSummaryFromJson(json);

@override final  String caseId;
@override final  String caseNumber;
@override final  String clientName;
@override final  double totalInvoiced;
@override final  double totalPaid;
@override final  double outstandingBalance;
@override@JsonKey(unknownEnumValue: PaymentStatus.unknown) final  PaymentStatus paymentStatus;
@override final  int invoicesCount;

/// Create a copy of CaseFinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaseFinancialSummaryCopyWith<_CaseFinancialSummary> get copyWith => __$CaseFinancialSummaryCopyWithImpl<_CaseFinancialSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaseFinancialSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaseFinancialSummary&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.totalInvoiced, totalInvoiced) || other.totalInvoiced == totalInvoiced)&&(identical(other.totalPaid, totalPaid) || other.totalPaid == totalPaid)&&(identical(other.outstandingBalance, outstandingBalance) || other.outstandingBalance == outstandingBalance)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.invoicesCount, invoicesCount) || other.invoicesCount == invoicesCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseId,caseNumber,clientName,totalInvoiced,totalPaid,outstandingBalance,paymentStatus,invoicesCount);

@override
String toString() {
  return 'CaseFinancialSummary(caseId: $caseId, caseNumber: $caseNumber, clientName: $clientName, totalInvoiced: $totalInvoiced, totalPaid: $totalPaid, outstandingBalance: $outstandingBalance, paymentStatus: $paymentStatus, invoicesCount: $invoicesCount)';
}


}

/// @nodoc
abstract mixin class _$CaseFinancialSummaryCopyWith<$Res> implements $CaseFinancialSummaryCopyWith<$Res> {
  factory _$CaseFinancialSummaryCopyWith(_CaseFinancialSummary value, $Res Function(_CaseFinancialSummary) _then) = __$CaseFinancialSummaryCopyWithImpl;
@override @useResult
$Res call({
 String caseId, String caseNumber, String clientName, double totalInvoiced, double totalPaid, double outstandingBalance,@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus paymentStatus, int invoicesCount
});




}
/// @nodoc
class __$CaseFinancialSummaryCopyWithImpl<$Res>
    implements _$CaseFinancialSummaryCopyWith<$Res> {
  __$CaseFinancialSummaryCopyWithImpl(this._self, this._then);

  final _CaseFinancialSummary _self;
  final $Res Function(_CaseFinancialSummary) _then;

/// Create a copy of CaseFinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? caseId = null,Object? caseNumber = null,Object? clientName = null,Object? totalInvoiced = null,Object? totalPaid = null,Object? outstandingBalance = null,Object? paymentStatus = null,Object? invoicesCount = null,}) {
  return _then(_CaseFinancialSummary(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,totalInvoiced: null == totalInvoiced ? _self.totalInvoiced : totalInvoiced // ignore: cast_nullable_to_non_nullable
as double,totalPaid: null == totalPaid ? _self.totalPaid : totalPaid // ignore: cast_nullable_to_non_nullable
as double,outstandingBalance: null == outstandingBalance ? _self.outstandingBalance : outstandingBalance // ignore: cast_nullable_to_non_nullable
as double,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,invoicesCount: null == invoicesCount ? _self.invoicesCount : invoicesCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
