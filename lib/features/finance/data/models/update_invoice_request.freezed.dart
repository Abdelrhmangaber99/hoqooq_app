// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_invoice_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateInvoiceRequest {

@JsonKey(includeIfNull: false) String? get clientId;@JsonKey(includeIfNull: false) String? get caseId;@JsonKey(includeIfNull: false) String? get invoiceNumber;@JsonKey(includeIfNull: false) double? get subtotal;@JsonKey(includeIfNull: false) double? get taxTotal;@JsonKey(includeIfNull: false) double? get grandTotal;@JsonKey(includeIfNull: false) InvoiceStatus? get status;@JsonKey(includeIfNull: false) DateTime? get issueDate;@JsonKey(includeIfNull: false) DateTime? get dueDate;@JsonKey(includeIfNull: false) String? get notes;
/// Create a copy of UpdateInvoiceRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateInvoiceRequestCopyWith<UpdateInvoiceRequest> get copyWith => _$UpdateInvoiceRequestCopyWithImpl<UpdateInvoiceRequest>(this as UpdateInvoiceRequest, _$identity);

  /// Serializes this UpdateInvoiceRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateInvoiceRequest&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.status, status) || other.status == status)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,caseId,invoiceNumber,subtotal,taxTotal,grandTotal,status,issueDate,dueDate,notes);

@override
String toString() {
  return 'UpdateInvoiceRequest(clientId: $clientId, caseId: $caseId, invoiceNumber: $invoiceNumber, subtotal: $subtotal, taxTotal: $taxTotal, grandTotal: $grandTotal, status: $status, issueDate: $issueDate, dueDate: $dueDate, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $UpdateInvoiceRequestCopyWith<$Res>  {
  factory $UpdateInvoiceRequestCopyWith(UpdateInvoiceRequest value, $Res Function(UpdateInvoiceRequest) _then) = _$UpdateInvoiceRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) String? clientId,@JsonKey(includeIfNull: false) String? caseId,@JsonKey(includeIfNull: false) String? invoiceNumber,@JsonKey(includeIfNull: false) double? subtotal,@JsonKey(includeIfNull: false) double? taxTotal,@JsonKey(includeIfNull: false) double? grandTotal,@JsonKey(includeIfNull: false) InvoiceStatus? status,@JsonKey(includeIfNull: false) DateTime? issueDate,@JsonKey(includeIfNull: false) DateTime? dueDate,@JsonKey(includeIfNull: false) String? notes
});




}
/// @nodoc
class _$UpdateInvoiceRequestCopyWithImpl<$Res>
    implements $UpdateInvoiceRequestCopyWith<$Res> {
  _$UpdateInvoiceRequestCopyWithImpl(this._self, this._then);

  final UpdateInvoiceRequest _self;
  final $Res Function(UpdateInvoiceRequest) _then;

/// Create a copy of UpdateInvoiceRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientId = freezed,Object? caseId = freezed,Object? invoiceNumber = freezed,Object? subtotal = freezed,Object? taxTotal = freezed,Object? grandTotal = freezed,Object? status = freezed,Object? issueDate = freezed,Object? dueDate = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: freezed == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,subtotal: freezed == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double?,taxTotal: freezed == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as double?,grandTotal: freezed == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus?,issueDate: freezed == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateInvoiceRequest].
extension UpdateInvoiceRequestPatterns on UpdateInvoiceRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateInvoiceRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateInvoiceRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateInvoiceRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateInvoiceRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateInvoiceRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateInvoiceRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? clientId, @JsonKey(includeIfNull: false)  String? caseId, @JsonKey(includeIfNull: false)  String? invoiceNumber, @JsonKey(includeIfNull: false)  double? subtotal, @JsonKey(includeIfNull: false)  double? taxTotal, @JsonKey(includeIfNull: false)  double? grandTotal, @JsonKey(includeIfNull: false)  InvoiceStatus? status, @JsonKey(includeIfNull: false)  DateTime? issueDate, @JsonKey(includeIfNull: false)  DateTime? dueDate, @JsonKey(includeIfNull: false)  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateInvoiceRequest() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  String? clientId, @JsonKey(includeIfNull: false)  String? caseId, @JsonKey(includeIfNull: false)  String? invoiceNumber, @JsonKey(includeIfNull: false)  double? subtotal, @JsonKey(includeIfNull: false)  double? taxTotal, @JsonKey(includeIfNull: false)  double? grandTotal, @JsonKey(includeIfNull: false)  InvoiceStatus? status, @JsonKey(includeIfNull: false)  DateTime? issueDate, @JsonKey(includeIfNull: false)  DateTime? dueDate, @JsonKey(includeIfNull: false)  String? notes)  $default,) {final _that = this;
switch (_that) {
case _UpdateInvoiceRequest():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  String? clientId, @JsonKey(includeIfNull: false)  String? caseId, @JsonKey(includeIfNull: false)  String? invoiceNumber, @JsonKey(includeIfNull: false)  double? subtotal, @JsonKey(includeIfNull: false)  double? taxTotal, @JsonKey(includeIfNull: false)  double? grandTotal, @JsonKey(includeIfNull: false)  InvoiceStatus? status, @JsonKey(includeIfNull: false)  DateTime? issueDate, @JsonKey(includeIfNull: false)  DateTime? dueDate, @JsonKey(includeIfNull: false)  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _UpdateInvoiceRequest() when $default != null:
return $default(_that.clientId,_that.caseId,_that.invoiceNumber,_that.subtotal,_that.taxTotal,_that.grandTotal,_that.status,_that.issueDate,_that.dueDate,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateInvoiceRequest implements UpdateInvoiceRequest {
  const _UpdateInvoiceRequest({@JsonKey(includeIfNull: false) this.clientId, @JsonKey(includeIfNull: false) this.caseId, @JsonKey(includeIfNull: false) this.invoiceNumber, @JsonKey(includeIfNull: false) this.subtotal, @JsonKey(includeIfNull: false) this.taxTotal, @JsonKey(includeIfNull: false) this.grandTotal, @JsonKey(includeIfNull: false) this.status, @JsonKey(includeIfNull: false) this.issueDate, @JsonKey(includeIfNull: false) this.dueDate, @JsonKey(includeIfNull: false) this.notes});
  factory _UpdateInvoiceRequest.fromJson(Map<String, dynamic> json) => _$UpdateInvoiceRequestFromJson(json);

@override@JsonKey(includeIfNull: false) final  String? clientId;
@override@JsonKey(includeIfNull: false) final  String? caseId;
@override@JsonKey(includeIfNull: false) final  String? invoiceNumber;
@override@JsonKey(includeIfNull: false) final  double? subtotal;
@override@JsonKey(includeIfNull: false) final  double? taxTotal;
@override@JsonKey(includeIfNull: false) final  double? grandTotal;
@override@JsonKey(includeIfNull: false) final  InvoiceStatus? status;
@override@JsonKey(includeIfNull: false) final  DateTime? issueDate;
@override@JsonKey(includeIfNull: false) final  DateTime? dueDate;
@override@JsonKey(includeIfNull: false) final  String? notes;

/// Create a copy of UpdateInvoiceRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateInvoiceRequestCopyWith<_UpdateInvoiceRequest> get copyWith => __$UpdateInvoiceRequestCopyWithImpl<_UpdateInvoiceRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateInvoiceRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateInvoiceRequest&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.status, status) || other.status == status)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientId,caseId,invoiceNumber,subtotal,taxTotal,grandTotal,status,issueDate,dueDate,notes);

@override
String toString() {
  return 'UpdateInvoiceRequest(clientId: $clientId, caseId: $caseId, invoiceNumber: $invoiceNumber, subtotal: $subtotal, taxTotal: $taxTotal, grandTotal: $grandTotal, status: $status, issueDate: $issueDate, dueDate: $dueDate, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$UpdateInvoiceRequestCopyWith<$Res> implements $UpdateInvoiceRequestCopyWith<$Res> {
  factory _$UpdateInvoiceRequestCopyWith(_UpdateInvoiceRequest value, $Res Function(_UpdateInvoiceRequest) _then) = __$UpdateInvoiceRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) String? clientId,@JsonKey(includeIfNull: false) String? caseId,@JsonKey(includeIfNull: false) String? invoiceNumber,@JsonKey(includeIfNull: false) double? subtotal,@JsonKey(includeIfNull: false) double? taxTotal,@JsonKey(includeIfNull: false) double? grandTotal,@JsonKey(includeIfNull: false) InvoiceStatus? status,@JsonKey(includeIfNull: false) DateTime? issueDate,@JsonKey(includeIfNull: false) DateTime? dueDate,@JsonKey(includeIfNull: false) String? notes
});




}
/// @nodoc
class __$UpdateInvoiceRequestCopyWithImpl<$Res>
    implements _$UpdateInvoiceRequestCopyWith<$Res> {
  __$UpdateInvoiceRequestCopyWithImpl(this._self, this._then);

  final _UpdateInvoiceRequest _self;
  final $Res Function(_UpdateInvoiceRequest) _then;

/// Create a copy of UpdateInvoiceRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientId = freezed,Object? caseId = freezed,Object? invoiceNumber = freezed,Object? subtotal = freezed,Object? taxTotal = freezed,Object? grandTotal = freezed,Object? status = freezed,Object? issueDate = freezed,Object? dueDate = freezed,Object? notes = freezed,}) {
  return _then(_UpdateInvoiceRequest(
clientId: freezed == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String?,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: freezed == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,subtotal: freezed == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double?,taxTotal: freezed == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as double?,grandTotal: freezed == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus?,issueDate: freezed == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
