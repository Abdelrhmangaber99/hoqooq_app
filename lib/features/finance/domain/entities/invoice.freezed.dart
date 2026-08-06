// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Invoice {

 String get id; String get tenantId; String get clientId; String get invoiceNumber;@JsonKey(unknownEnumValue: InvoiceStatus.unknown) InvoiceStatus get status; DateTime get issueDate; DateTime get dueDate; double get subtotal; double get taxTotal; double get grandTotal; String? get notes; DateTime get createdAt; DateTime get updatedAt; String? get caseId;@JsonKey(name: 'case') CaseSummary? get caseSummary; Client? get client; List<Payment>? get payments; List<InvoiceLineItem>? get lineItems;
/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceCopyWith<Invoice> get copyWith => _$InvoiceCopyWithImpl<Invoice>(this as Invoice, _$identity);

  /// Serializes this Invoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseSummary, caseSummary) || other.caseSummary == caseSummary)&&(identical(other.client, client) || other.client == client)&&const DeepCollectionEquality().equals(other.payments, payments)&&const DeepCollectionEquality().equals(other.lineItems, lineItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,clientId,invoiceNumber,status,issueDate,dueDate,subtotal,taxTotal,grandTotal,notes,createdAt,updatedAt,caseId,caseSummary,client,const DeepCollectionEquality().hash(payments),const DeepCollectionEquality().hash(lineItems));

@override
String toString() {
  return 'Invoice(id: $id, tenantId: $tenantId, clientId: $clientId, invoiceNumber: $invoiceNumber, status: $status, issueDate: $issueDate, dueDate: $dueDate, subtotal: $subtotal, taxTotal: $taxTotal, grandTotal: $grandTotal, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, caseId: $caseId, caseSummary: $caseSummary, client: $client, payments: $payments, lineItems: $lineItems)';
}


}

/// @nodoc
abstract mixin class $InvoiceCopyWith<$Res>  {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) _then) = _$InvoiceCopyWithImpl;
@useResult
$Res call({
 String id, String tenantId, String clientId, String invoiceNumber,@JsonKey(unknownEnumValue: InvoiceStatus.unknown) InvoiceStatus status, DateTime issueDate, DateTime dueDate, double subtotal, double taxTotal, double grandTotal, String? notes, DateTime createdAt, DateTime updatedAt, String? caseId,@JsonKey(name: 'case') CaseSummary? caseSummary, Client? client, List<Payment>? payments, List<InvoiceLineItem>? lineItems
});


$CaseSummaryCopyWith<$Res>? get caseSummary;$ClientCopyWith<$Res>? get client;

}
/// @nodoc
class _$InvoiceCopyWithImpl<$Res>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._self, this._then);

  final Invoice _self;
  final $Res Function(Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tenantId = null,Object? clientId = null,Object? invoiceNumber = null,Object? status = null,Object? issueDate = null,Object? dueDate = null,Object? subtotal = null,Object? taxTotal = null,Object? grandTotal = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,Object? caseId = freezed,Object? caseSummary = freezed,Object? client = freezed,Object? payments = freezed,Object? lineItems = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as double,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,caseSummary: freezed == caseSummary ? _self.caseSummary : caseSummary // ignore: cast_nullable_to_non_nullable
as CaseSummary?,client: freezed == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as Client?,payments: freezed == payments ? _self.payments : payments // ignore: cast_nullable_to_non_nullable
as List<Payment>?,lineItems: freezed == lineItems ? _self.lineItems : lineItems // ignore: cast_nullable_to_non_nullable
as List<InvoiceLineItem>?,
  ));
}
/// Create a copy of Invoice
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
}/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientCopyWith<$Res>? get client {
    if (_self.client == null) {
    return null;
  }

  return $ClientCopyWith<$Res>(_self.client!, (value) {
    return _then(_self.copyWith(client: value));
  });
}
}


/// Adds pattern-matching-related methods to [Invoice].
extension InvoicePatterns on Invoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invoice value)  $default,){
final _that = this;
switch (_that) {
case _Invoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invoice value)?  $default,){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tenantId,  String clientId,  String invoiceNumber, @JsonKey(unknownEnumValue: InvoiceStatus.unknown)  InvoiceStatus status,  DateTime issueDate,  DateTime dueDate,  double subtotal,  double taxTotal,  double grandTotal,  String? notes,  DateTime createdAt,  DateTime updatedAt,  String? caseId, @JsonKey(name: 'case')  CaseSummary? caseSummary,  Client? client,  List<Payment>? payments,  List<InvoiceLineItem>? lineItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.tenantId,_that.clientId,_that.invoiceNumber,_that.status,_that.issueDate,_that.dueDate,_that.subtotal,_that.taxTotal,_that.grandTotal,_that.notes,_that.createdAt,_that.updatedAt,_that.caseId,_that.caseSummary,_that.client,_that.payments,_that.lineItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tenantId,  String clientId,  String invoiceNumber, @JsonKey(unknownEnumValue: InvoiceStatus.unknown)  InvoiceStatus status,  DateTime issueDate,  DateTime dueDate,  double subtotal,  double taxTotal,  double grandTotal,  String? notes,  DateTime createdAt,  DateTime updatedAt,  String? caseId, @JsonKey(name: 'case')  CaseSummary? caseSummary,  Client? client,  List<Payment>? payments,  List<InvoiceLineItem>? lineItems)  $default,) {final _that = this;
switch (_that) {
case _Invoice():
return $default(_that.id,_that.tenantId,_that.clientId,_that.invoiceNumber,_that.status,_that.issueDate,_that.dueDate,_that.subtotal,_that.taxTotal,_that.grandTotal,_that.notes,_that.createdAt,_that.updatedAt,_that.caseId,_that.caseSummary,_that.client,_that.payments,_that.lineItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tenantId,  String clientId,  String invoiceNumber, @JsonKey(unknownEnumValue: InvoiceStatus.unknown)  InvoiceStatus status,  DateTime issueDate,  DateTime dueDate,  double subtotal,  double taxTotal,  double grandTotal,  String? notes,  DateTime createdAt,  DateTime updatedAt,  String? caseId, @JsonKey(name: 'case')  CaseSummary? caseSummary,  Client? client,  List<Payment>? payments,  List<InvoiceLineItem>? lineItems)?  $default,) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.tenantId,_that.clientId,_that.invoiceNumber,_that.status,_that.issueDate,_that.dueDate,_that.subtotal,_that.taxTotal,_that.grandTotal,_that.notes,_that.createdAt,_that.updatedAt,_that.caseId,_that.caseSummary,_that.client,_that.payments,_that.lineItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invoice implements Invoice {
  const _Invoice({required this.id, required this.tenantId, required this.clientId, required this.invoiceNumber, @JsonKey(unknownEnumValue: InvoiceStatus.unknown) required this.status, required this.issueDate, required this.dueDate, required this.subtotal, required this.taxTotal, required this.grandTotal, this.notes, required this.createdAt, required this.updatedAt, this.caseId, @JsonKey(name: 'case') this.caseSummary, this.client, final  List<Payment>? payments, final  List<InvoiceLineItem>? lineItems}): _payments = payments,_lineItems = lineItems;
  factory _Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

@override final  String id;
@override final  String tenantId;
@override final  String clientId;
@override final  String invoiceNumber;
@override@JsonKey(unknownEnumValue: InvoiceStatus.unknown) final  InvoiceStatus status;
@override final  DateTime issueDate;
@override final  DateTime dueDate;
@override final  double subtotal;
@override final  double taxTotal;
@override final  double grandTotal;
@override final  String? notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? caseId;
@override@JsonKey(name: 'case') final  CaseSummary? caseSummary;
@override final  Client? client;
 final  List<Payment>? _payments;
@override List<Payment>? get payments {
  final value = _payments;
  if (value == null) return null;
  if (_payments is EqualUnmodifiableListView) return _payments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<InvoiceLineItem>? _lineItems;
@override List<InvoiceLineItem>? get lineItems {
  final value = _lineItems;
  if (value == null) return null;
  if (_lineItems is EqualUnmodifiableListView) return _lineItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceCopyWith<_Invoice> get copyWith => __$InvoiceCopyWithImpl<_Invoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.caseId, caseId) || other.caseId == caseId)&&(identical(other.caseSummary, caseSummary) || other.caseSummary == caseSummary)&&(identical(other.client, client) || other.client == client)&&const DeepCollectionEquality().equals(other._payments, _payments)&&const DeepCollectionEquality().equals(other._lineItems, _lineItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tenantId,clientId,invoiceNumber,status,issueDate,dueDate,subtotal,taxTotal,grandTotal,notes,createdAt,updatedAt,caseId,caseSummary,client,const DeepCollectionEquality().hash(_payments),const DeepCollectionEquality().hash(_lineItems));

@override
String toString() {
  return 'Invoice(id: $id, tenantId: $tenantId, clientId: $clientId, invoiceNumber: $invoiceNumber, status: $status, issueDate: $issueDate, dueDate: $dueDate, subtotal: $subtotal, taxTotal: $taxTotal, grandTotal: $grandTotal, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, caseId: $caseId, caseSummary: $caseSummary, client: $client, payments: $payments, lineItems: $lineItems)';
}


}

/// @nodoc
abstract mixin class _$InvoiceCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$InvoiceCopyWith(_Invoice value, $Res Function(_Invoice) _then) = __$InvoiceCopyWithImpl;
@override @useResult
$Res call({
 String id, String tenantId, String clientId, String invoiceNumber,@JsonKey(unknownEnumValue: InvoiceStatus.unknown) InvoiceStatus status, DateTime issueDate, DateTime dueDate, double subtotal, double taxTotal, double grandTotal, String? notes, DateTime createdAt, DateTime updatedAt, String? caseId,@JsonKey(name: 'case') CaseSummary? caseSummary, Client? client, List<Payment>? payments, List<InvoiceLineItem>? lineItems
});


@override $CaseSummaryCopyWith<$Res>? get caseSummary;@override $ClientCopyWith<$Res>? get client;

}
/// @nodoc
class __$InvoiceCopyWithImpl<$Res>
    implements _$InvoiceCopyWith<$Res> {
  __$InvoiceCopyWithImpl(this._self, this._then);

  final _Invoice _self;
  final $Res Function(_Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tenantId = null,Object? clientId = null,Object? invoiceNumber = null,Object? status = null,Object? issueDate = null,Object? dueDate = null,Object? subtotal = null,Object? taxTotal = null,Object? grandTotal = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,Object? caseId = freezed,Object? caseSummary = freezed,Object? client = freezed,Object? payments = freezed,Object? lineItems = freezed,}) {
  return _then(_Invoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as double,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,caseId: freezed == caseId ? _self.caseId : caseId // ignore: cast_nullable_to_non_nullable
as String?,caseSummary: freezed == caseSummary ? _self.caseSummary : caseSummary // ignore: cast_nullable_to_non_nullable
as CaseSummary?,client: freezed == client ? _self.client : client // ignore: cast_nullable_to_non_nullable
as Client?,payments: freezed == payments ? _self._payments : payments // ignore: cast_nullable_to_non_nullable
as List<Payment>?,lineItems: freezed == lineItems ? _self._lineItems : lineItems // ignore: cast_nullable_to_non_nullable
as List<InvoiceLineItem>?,
  ));
}

/// Create a copy of Invoice
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
}/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClientCopyWith<$Res>? get client {
    if (_self.client == null) {
    return null;
  }

  return $ClientCopyWith<$Res>(_self.client!, (value) {
    return _then(_self.copyWith(client: value));
  });
}
}

// dart format on
