// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Invoice _$InvoiceFromJson(Map<String, dynamic> json) => _Invoice(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  clientId: json['clientId'] as String,
  invoiceNumber: json['invoiceNumber'] as String,
  status: $enumDecode(
    _$InvoiceStatusEnumMap,
    json['status'],
    unknownValue: InvoiceStatus.unknown,
  ),
  issueDate: DateTime.parse(json['issueDate'] as String),
  dueDate: DateTime.parse(json['dueDate'] as String),
  subtotal: (json['subtotal'] as num).toDouble(),
  taxTotal: (json['taxTotal'] as num).toDouble(),
  grandTotal: (json['grandTotal'] as num).toDouble(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  caseId: json['caseId'] as String?,
  caseSummary: json['case'] == null
      ? null
      : CaseSummary.fromJson(json['case'] as Map<String, dynamic>),
  client: json['client'] == null
      ? null
      : Client.fromJson(json['client'] as Map<String, dynamic>),
  payments: (json['payments'] as List<dynamic>?)
      ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
      .toList(),
  lineItems: (json['lineItems'] as List<dynamic>?)
      ?.map((e) => InvoiceLineItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$InvoiceToJson(_Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'clientId': instance.clientId,
  'invoiceNumber': instance.invoiceNumber,
  'status': _$InvoiceStatusEnumMap[instance.status]!,
  'issueDate': instance.issueDate.toIso8601String(),
  'dueDate': instance.dueDate.toIso8601String(),
  'subtotal': instance.subtotal,
  'taxTotal': instance.taxTotal,
  'grandTotal': instance.grandTotal,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'caseId': instance.caseId,
  'case': instance.caseSummary,
  'client': instance.client,
  'payments': instance.payments,
  'lineItems': instance.lineItems,
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.draft: 'DRAFT',
  InvoiceStatus.sent: 'SENT',
  InvoiceStatus.partial: 'PARTIAL',
  InvoiceStatus.paid: 'PAID',
  InvoiceStatus.cancelled: 'CANCELLED',
  InvoiceStatus.unknown: 'unknown',
};
