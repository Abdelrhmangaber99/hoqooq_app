// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreatePaymentRequest _$CreatePaymentRequestFromJson(
  Map<String, dynamic> json,
) => _CreatePaymentRequest(
  invoiceId: json['invoiceId'] as String,
  amount: (json['amount'] as num).toDouble(),
  paymentDate: DateTime.parse(json['paymentDate'] as String),
  method: $enumDecode(
    _$PaymentMethodEnumMap,
    json['method'],
    unknownValue: PaymentMethod.unknown,
  ),
  referenceNumber: json['referenceNumber'] as String?,
);

Map<String, dynamic> _$CreatePaymentRequestToJson(
  _CreatePaymentRequest instance,
) => <String, dynamic>{
  'invoiceId': instance.invoiceId,
  'amount': instance.amount,
  'paymentDate': instance.paymentDate.toIso8601String(),
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'referenceNumber': instance.referenceNumber,
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'CASH',
  PaymentMethod.bankTransfer: 'BANK_TRANSFER',
  PaymentMethod.cheque: 'CHEQUE',
  PaymentMethod.online: 'ONLINE',
  PaymentMethod.unknown: 'unknown',
};
