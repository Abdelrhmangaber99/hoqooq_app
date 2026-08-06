// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_invoice_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateInvoiceRequest {

 String get clientId; String? get caseId; String get invoiceNumber; double get subtotal; double get taxTotal; double get grandTotal; InvoiceStatus? get status; DateTime get issueDate; DateTime get dueDate; String? get notes;
/// Create a copy of CreateInvoiceRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateInvoiceRequestCopyWith<CreateInvoiceRequest> get copyWith => _$CreateInvoiceRequestCopyWithImpl<CreateInvoiceRequest>(this as CreateInvoiceRequest, _$identity);

  /// Serializes this CreateInvoiceRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateInvoiceRequest&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.status, status) || other.status == status)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,caseId,invoiceNumber,subtotal,taxTotal,grandTotal,status,issueDate,dueDate,notes);

@override
String toString() {
  return 'CreateInvoiceRequest(clientId: $clientId, caseId: $caseId, invoiceNumber: $invoiceNumber, subtotal: $subtotal, taxTotal: $taxTotal, grandTotal: $grandTotal, status: $status, issueDate: $issueDate, dueDate: $dueDate, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $CreateInvoiceRequestCopyWith<$Res>  {
  factory $CreateInvoiceRequestCopyWith(CreateInvoiceRequest value, $Res Function(CreateInvoiceRequest) _then) = _$CreateInvoiceRequestCopyWithImpl;
@useResult
$Res call({
 String clientId, String? caseId, String invoiceNumber, double subtotal, double taxTotal, double grandTotal, InvoiceStatus? status, DateTime issueDate, DateTime dueDate, String? notes
});




}
/// @nodoc
class _$CreateInvoiceRequestCopyWithImpl<$Res>
    implements $CreateInvoiceRequestCopyWith<$Res> {
  _$CreateInvoiceRequestCopyWithImpl(this._self, this._then);

  final CreateInvoiceRequest _self;
  final $Res Function(CreateInvoiceRequest) _then;

/// Create a copy of CreateInvoiceRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientId = null,Object? caseId = freezed,Object? invoiceNumber = null,Object? subtotal = null,Object? taxTotal = null,Object? grandTotal = null,Object? status = freezed,Object? issueDate = null,Object? dueDate = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as double,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus?,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateInvoiceRequest].
extension CreateInvoiceRequestPatterns on CreateInvoiceRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateInvoiceRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateInvoiceRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateInvoiceRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateInvoiceRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateInvoiceRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateInvoiceRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clientId,  String? caseId,  String invoiceNumber,  double subtotal,  double taxTotal,  double grandTotal,  InvoiceStatus? status,  DateTime issueDate,  DateTime dueDate,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateInvoiceRequest() when $default != null:
return $default(_that.clientId,_that.caseId,_that.invoiceNumber,_that.subtotal,_that.taxTotal,_that.grandTotal,_that.status,_that.issueDate,_that.dueDate,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clientId,  String? caseId,  String invoiceNumber,  double subtotal,  double taxTotal,  double grandTotal,  InvoiceStatus? status,  DateTime issueDate,  DateTime dueDate,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _CreateInvoiceRequest():
return $default(_that.clientId,_that.caseId,_that.invoiceNumber,_that.subtotal,_that.taxTotal,_that.grandTotal,_that.status,_that.issueDate,_that.dueDate,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clientId,  String? caseId,  String invoiceNumber,  double subtotal,  double taxTotal,  double grandTotal,  InvoiceStatus? status,  DateTime issueDate,  DateTime dueDate,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _CreateInvoiceRequest() when $default != null:
return $default(_that.clientId,_that.caseId,_that.invoiceNumber,_that.subtotal,_that.taxTotal,_that.grandTotal,_that.status,_that.issueDate,_that.dueDate,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateInvoiceRequest implements CreateInvoiceRequest {
  const _CreateInvoiceRequest({required this.clientId, this.caseId, required this.invoiceNumber, required this.subtotal, required this.taxTotal, required this.grandTotal, this.status, required this.issueDate, required this.dueDate, this.notes});
  factory _CreateInvoiceRequest.fromJson(Map<String, dynamic> json) => _$CreateInvoiceRequestFromJson(json);

@override final  String clientId;
@override final  String? caseId;
@override final  String invoiceNumber;
@override final  double subtotal;
@override final  double taxTotal;
@override final  double grandTotal;
@override final  InvoiceStatus? status;
@override final  DateTime issueDate;
@override final  DateTime dueDate;
@override final  String? notes;

/// Create a copy of CreateInvoiceRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateInvoiceRequestCopyWith<_CreateInvoiceRequest> get copyWith => __$CreateInvoiceRequestCopyWithImpl<_CreateInvoiceRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateInvoiceRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateInvoiceRequest&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.status, status) || other.status == status)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,caseId,invoiceNumber,subtotal,taxTotal,grandTotal,status,issueDate,dueDate,notes);

@override
String toString() {
  return 'CreateInvoiceRequest(clientId: $clientId, caseId: $caseId, invoiceNumber: $invoiceNumber, subtotal: $subtotal, taxTotal: $taxTotal, grandTotal: $grandTotal, status: $status, issueDate: $issueDate, dueDate: $dueDate, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$CreateInvoiceRequestCopyWith<$Res> implements $CreateInvoiceRequestCopyWith<$Res> {
  factory _$CreateInvoiceRequestCopyWith(_CreateInvoiceRequest value, $Res Function(_CreateInvoiceRequest) _then) = __$CreateInvoiceRequestCopyWithImpl;
@override @useResult
$Res call({
 String clientId, String? caseId, String invoiceNumber, double subtotal, double taxTotal, double grandTotal, InvoiceStatus? status, DateTime issueDate, DateTime dueDate, String? notes
});




}
/// @nodoc
class __$CreateInvoiceRequestCopyWithImpl<$Res>
    implements _$CreateInvoiceRequestCopyWith<$Res> {
  __$CreateInvoiceRequestCopyWithImpl(this._self, this._then);

  final _CreateInvoiceRequest _self;
  final $Res Function(_CreateInvoiceRequest) _then;

/// Create a copy of CreateInvoiceRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientId = null,Object? caseId = freezed,Object? invoiceNumber = null,Object? subtotal = null,Object? taxTotal = null,Object? grandTotal = null,Object? status = freezed,Object? issueDate = null,Object? dueDate = null,Object? notes = freezed,}) {
  return _then(_CreateInvoiceRequest(
clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as double,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus?,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
