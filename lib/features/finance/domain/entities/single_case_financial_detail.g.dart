// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_case_financial_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SingleCaseFinancialDetail _$SingleCaseFinancialDetailFromJson(
  Map<String, dynamic> json,
) => _SingleCaseFinancialDetail(
  caseId: json['caseId'] as String,
  caseNumber: json['caseNumber'] as String,
  clientName: json['clientName'] as String,
  totalInvoiced: (json['totalInvoiced'] as num).toDouble(),
  totalPaid: (json['totalPaid'] as num).toDouble(),
  outstandingBalance: (json['outstandingBalance'] as num).toDouble(),
  paymentStatus: $enumDecode(
    _$PaymentStatusEnumMap,
    json['paymentStatus'],
    unknownValue: PaymentStatus.unknown,
  ),
  invoices: (json['invoices'] as List<dynamic>)
      .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SingleCaseFinancialDetailToJson(
  _SingleCaseFinancialDetail instance,
) => <String, dynamic>{
  'caseId': instance.caseId,
  'caseNumber': instance.caseNumber,
  'clientName': instance.clientName,
  'totalInvoiced': instance.totalInvoiced,
  'totalPaid': instance.totalPaid,
  'outstandingBalance': instance.outstandingBalance,
  'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
  'invoices': instance.invoices,
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 'PAID',
  PaymentStatus.partial: 'PARTIAL',
  PaymentStatus.unpaid: 'UNPAID',
  PaymentStatus.noInvoice: 'NO_INVOICE',
  PaymentStatus.unknown: 'unknown',
};
