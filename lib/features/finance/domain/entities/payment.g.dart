// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: json['id'] as String,
  tenantId: json['tenantId'] as String,
  invoiceId: json['invoiceId'] as String,
  amount: (json['amount'] as num).toDouble(),
  paymentDate: DateTime.parse(json['paymentDate'] as String),
  method: $enumDecode(
    _$PaymentMethodEnumMap,
    json['paymentMethod'],
    unknownValue: PaymentMethod.unknown,
  ),
  referenceNumber: json['referenceNumber'] as String?,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  invoice: json['invoice'] == null
      ? null
      : Invoice.fromJson(json['invoice'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'id': instance.id,
  'tenantId': instance.tenantId,
  'invoiceId': instance.invoiceId,
  'amount': instance.amount,
  'paymentDate': instance.paymentDate.toIso8601String(),
  'paymentMethod': _$PaymentMethodEnumMap[instance.method]!,
  'referenceNumber': instance.referenceNumber,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'invoice': instance.invoice,
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'CASH',
  PaymentMethod.bankTransfer: 'BANK_TRANSFER',
  PaymentMethod.cheque: 'CHEQUE',
  PaymentMethod.online: 'ONLINE',
  PaymentMethod.unknown: 'unknown',
};
