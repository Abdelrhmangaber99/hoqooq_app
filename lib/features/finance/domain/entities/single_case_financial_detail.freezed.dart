// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'single_case_financial_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SingleCaseFinancialDetail {

 String get caseId; String get caseNumber; String get clientName; double get totalInvoiced; double get totalPaid; double get outstandingBalance;@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus get paymentStatus; List<Invoice> get invoices;
/// Create a copy of SingleCaseFinancialDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SingleCaseFinancialDetailCopyWith<SingleCaseFinancialDetail> get copyWith => _$SingleCaseFinancialDetailCopyWithImpl<SingleCaseFinancialDetail>(this as SingleCaseFinancialDetail, _$identity);

  /// Serializes this SingleCaseFinancialDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SingleCaseFinancialDetail&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.totalInvoiced, totalInvoiced) || other.totalInvoiced == totalInvoiced)&&(identical(other.totalPaid, totalPaid) || other.totalPaid == totalPaid)&&(identical(other.outstandingBalance, outstandingBalance) || other.outstandingBalance == outstandingBalance)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&const DeepCollectionEquality().equals(other.invoices, invoices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseId,caseNumber,clientName,totalInvoiced,totalPaid,outstandingBalance,paymentStatus,const DeepCollectionEquality().hash(invoices));

@override
String toString() {
  return 'SingleCaseFinancialDetail(caseId: $caseId, caseNumber: $caseNumber, clientName: $clientName, totalInvoiced: $totalInvoiced, totalPaid: $totalPaid, outstandingBalance: $outstandingBalance, paymentStatus: $paymentStatus, invoices: $invoices)';
}


}

/// @nodoc
abstract mixin class $SingleCaseFinancialDetailCopyWith<$Res>  {
  factory $SingleCaseFinancialDetailCopyWith(SingleCaseFinancialDetail value, $Res Function(SingleCaseFinancialDetail) _then) = _$SingleCaseFinancialDetailCopyWithImpl;
@useResult
$Res call({
 String caseId, String caseNumber, String clientName, double totalInvoiced, double totalPaid, double outstandingBalance,@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus paymentStatus, List<Invoice> invoices
});




}
/// @nodoc
class _$SingleCaseFinancialDetailCopyWithImpl<$Res>
    implements $SingleCaseFinancialDetailCopyWith<$Res> {
  _$SingleCaseFinancialDetailCopyWithImpl(this._self, this._then);

  final SingleCaseFinancialDetail _self;
  final $Res Function(SingleCaseFinancialDetail) _then;

/// Create a copy of SingleCaseFinancialDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? caseId = null,Object? caseNumber = null,Object? clientName = null,Object? totalInvoiced = null,Object? totalPaid = null,Object? outstandingBalance = null,Object? paymentStatus = null,Object? invoices = null,}) {
  return _then(_self.copyWith(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,totalInvoiced: null == totalInvoiced ? _self.totalInvoiced : totalInvoiced // ignore: cast_nullable_to_non_nullable
as double,totalPaid: null == totalPaid ? _self.totalPaid : totalPaid // ignore: cast_nullable_to_non_nullable
as double,outstandingBalance: null == outstandingBalance ? _self.outstandingBalance : outstandingBalance // ignore: cast_nullable_to_non_nullable
as double,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,invoices: null == invoices ? _self.invoices : invoices // ignore: cast_nullable_to_non_nullable
as List<Invoice>,
  ));
}

}


/// Adds pattern-matching-related methods to [SingleCaseFinancialDetail].
extension SingleCaseFinancialDetailPatterns on SingleCaseFinancialDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SingleCaseFinancialDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SingleCaseFinancialDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SingleCaseFinancialDetail value)  $default,){
final _that = this;
switch (_that) {
case _SingleCaseFinancialDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SingleCaseFinancialDetail value)?  $default,){
final _that = this;
switch (_that) {
case _SingleCaseFinancialDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String caseId,  String caseNumber,  String clientName,  double totalInvoiced,  double totalPaid,  double outstandingBalance, @JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus paymentStatus,  List<Invoice> invoices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SingleCaseFinancialDetail() when $default != null:
return $default(_that.caseId,_that.caseNumber,_that.clientName,_that.totalInvoiced,_that.totalPaid,_that.outstandingBalance,_that.paymentStatus,_that.invoices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String caseId,  String caseNumber,  String clientName,  double totalInvoiced,  double totalPaid,  double outstandingBalance, @JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus paymentStatus,  List<Invoice> invoices)  $default,) {final _that = this;
switch (_that) {
case _SingleCaseFinancialDetail():
return $default(_that.caseId,_that.caseNumber,_that.clientName,_that.totalInvoiced,_that.totalPaid,_that.outstandingBalance,_that.paymentStatus,_that.invoices);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String caseId,  String caseNumber,  String clientName,  double totalInvoiced,  double totalPaid,  double outstandingBalance, @JsonKey(unknownEnumValue: PaymentStatus.unknown)  PaymentStatus paymentStatus,  List<Invoice> invoices)?  $default,) {final _that = this;
switch (_that) {
case _SingleCaseFinancialDetail() when $default != null:
return $default(_that.caseId,_that.caseNumber,_that.clientName,_that.totalInvoiced,_that.totalPaid,_that.outstandingBalance,_that.paymentStatus,_that.invoices);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SingleCaseFinancialDetail implements SingleCaseFinancialDetail {
  const _SingleCaseFinancialDetail({required this.caseId, required this.caseNumber, required this.clientName, required this.totalInvoiced, required this.totalPaid, required this.outstandingBalance, @JsonKey(unknownEnumValue: PaymentStatus.unknown) required this.paymentStatus, required final  List<Invoice> invoices}): _invoices = invoices;
  factory _SingleCaseFinancialDetail.fromJson(Map<String, dynamic> json) => _$SingleCaseFinancialDetailFromJson(json);

@override final  String caseId;
@override final  String caseNumber;
@override final  String clientName;
@override final  double totalInvoiced;
@override final  double totalPaid;
@override final  double outstandingBalance;
@override@JsonKey(unknownEnumValue: PaymentStatus.unknown) final  PaymentStatus paymentStatus;
 final  List<Invoice> _invoices;
@override List<Invoice> get invoices {
  if (_invoices is EqualUnmodifiableListView) return _invoices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invoices);
}


/// Create a copy of SingleCaseFinancialDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SingleCaseFinancialDetailCopyWith<_SingleCaseFinancialDetail> get copyWith => __$SingleCaseFinancialDetailCopyWithImpl<_SingleCaseFinancialDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SingleCaseFinancialDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SingleCaseFinancialDetail&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseNumber, caseNumber) || other.caseNumber == caseNumber)&&(identical(other.clientName, clientName) || other.clientName == clientName)&&(identical(other.totalInvoiced, totalInvoiced) || other.totalInvoiced == totalInvoiced)&&(identical(other.totalPaid, totalPaid) || other.totalPaid == totalPaid)&&(identical(other.outstandingBalance, outstandingBalance) || other.outstandingBalance == outstandingBalance)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&const DeepCollectionEquality().equals(other._invoices, _invoices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,caseId,caseNumber,clientName,totalInvoiced,totalPaid,outstandingBalance,paymentStatus,const DeepCollectionEquality().hash(_invoices));

@override
String toString() {
  return 'SingleCaseFinancialDetail(caseId: $caseId, caseNumber: $caseNumber, clientName: $clientName, totalInvoiced: $totalInvoiced, totalPaid: $totalPaid, outstandingBalance: $outstandingBalance, paymentStatus: $paymentStatus, invoices: $invoices)';
}


}

/// @nodoc
abstract mixin class _$SingleCaseFinancialDetailCopyWith<$Res> implements $SingleCaseFinancialDetailCopyWith<$Res> {
  factory _$SingleCaseFinancialDetailCopyWith(_SingleCaseFinancialDetail value, $Res Function(_SingleCaseFinancialDetail) _then) = __$SingleCaseFinancialDetailCopyWithImpl;
@override @useResult
$Res call({
 String caseId, String caseNumber, String clientName, double totalInvoiced, double totalPaid, double outstandingBalance,@JsonKey(unknownEnumValue: PaymentStatus.unknown) PaymentStatus paymentStatus, List<Invoice> invoices
});




}
/// @nodoc
class __$SingleCaseFinancialDetailCopyWithImpl<$Res>
    implements _$SingleCaseFinancialDetailCopyWith<$Res> {
  __$SingleCaseFinancialDetailCopyWithImpl(this._self, this._then);

  final _SingleCaseFinancialDetail _self;
  final $Res Function(_SingleCaseFinancialDetail) _then;

/// Create a copy of SingleCaseFinancialDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? caseId = null,Object? caseNumber = null,Object? clientName = null,Object? totalInvoiced = null,Object? totalPaid = null,Object? outstandingBalance = null,Object? paymentStatus = null,Object? invoices = null,}) {
  return _then(_SingleCaseFinancialDetail(
caseId: null == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String,caseNumber: null == caseNumber ? _self.caseNumber : caseNumber // ignore: cast_nullable_to_non_nullable
as String,clientName: null == clientName ? _self.clientName : clientName // ignore: cast_nullable_to_non_nullable
as String,totalInvoiced: null == totalInvoiced ? _self.totalInvoiced : totalInvoiced // ignore: cast_nullable_to_non_nullable
as double,totalPaid: null == totalPaid ? _self.totalPaid : totalPaid // ignore: cast_nullable_to_non_nullable
as double,outstandingBalance: null == outstandingBalance ? _self.outstandingBalance : outstandingBalance // ignore: cast_nullable_to_non_nullable
as double,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,invoices: null == invoices ? _self._invoices : invoices // ignore: cast_nullable_to_non_nullable
as List<Invoice>,
  ));
}


}

// dart format on
