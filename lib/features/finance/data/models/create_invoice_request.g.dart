// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_invoice_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateInvoiceRequest _$CreateInvoiceRequestFromJson(
  Map<String, dynamic> json,
) => _CreateInvoiceRequest(
  clientId: json['clientId'] as String,
  caseId: json['caseId'] as String?,
  invoiceNumber: json['invoiceNumber'] as String,
  subtotal: (json['subtotal'] as num).toDouble(),
  taxTotal: (json['taxTotal'] as num).toDouble(),
  grandTotal: (json['grandTotal'] as num).toDouble(),
  status: $enumDecodeNullable(_$InvoiceStatusEnumMap, json['status']),
  issueDate: DateTime.parse(json['issueDate'] as String),
  dueDate: DateTime.parse(json['dueDate'] as String),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$CreateInvoiceRequestToJson(
  _CreateInvoiceRequest instance,
) => <String, dynamic>{
  'clientId': instance.clientId,
  'caseId': instance.caseId,
  'invoiceNumber': instance.invoiceNumber,
  'subtotal': instance.subtotal,
  'taxTotal': instance.taxTotal,
  'grandTotal': instance.grandTotal,
  'status': _$InvoiceStatusEnumMap[instance.status],
  'issueDate': instance.issueDate.toIso8601String(),
  'dueDate': instance.dueDate.toIso8601String(),
  'notes': instance.notes,
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.draft: 'DRAFT',
  InvoiceStatus.sent: 'SENT',
  InvoiceStatus.partial: 'PARTIAL',
  InvoiceStatus.paid: 'PAID',
  InvoiceStatus.cancelled: 'CANCELLED',
  InvoiceStatus.unknown: 'unknown',
};
