// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_financial_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaseFinancialSummary _$CaseFinancialSummaryFromJson(
  Map<String, dynamic> json,
) => _CaseFinancialSummary(
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
  invoicesCount: (json['invoicesCount'] as num).toInt(),
);

Map<String, dynamic> _$CaseFinancialSummaryToJson(
  _CaseFinancialSummary instance,
) => <String, dynamic>{
  'caseId': instance.caseId,
  'caseNumber': instance.caseNumber,
  'clientName': instance.clientName,
  'totalInvoiced': instance.totalInvoiced,
  'totalPaid': instance.totalPaid,
  'outstandingBalance': instance.outstandingBalance,
  'paymentStatus': _$PaymentStatusEnumMap[instance.paymentStatus]!,
  'invoicesCount': instance.invoicesCount,
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.paid: 'PAID',
  PaymentStatus.partial: 'PARTIAL',
  PaymentStatus.unpaid: 'UNPAID',
  PaymentStatus.noInvoice: 'NO_INVOICE',
  PaymentStatus.unknown: 'unknown',
};
