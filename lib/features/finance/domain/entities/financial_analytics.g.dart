// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FinancialAnalytics _$FinancialAnalyticsFromJson(Map<String, dynamic> json) =>
    _FinancialAnalytics(
      totalInvoiced: (json['totalInvoiced'] as num).toDouble(),
      totalPaid: (json['totalPaid'] as num).toDouble(),
      totalOutstanding: (json['totalOutstanding'] as num).toDouble(),
      collectionRatePercentage: (json['collectionRatePercentage'] as num)
          .toDouble(),
      totalInvoicesCount: (json['totalInvoicesCount'] as num).toInt(),
      paidInvoicesCount: (json['paidInvoicesCount'] as num).toInt(),
      partialInvoicesCount: (json['partialInvoicesCount'] as num).toInt(),
      unpaidInvoicesCount: (json['unpaidInvoicesCount'] as num).toInt(),
      grossRevenue: (json['grossRevenue'] as num).toDouble(),
      netProfitEstimate: (json['netProfitEstimate'] as num).toDouble(),
    );

Map<String, dynamic> _$FinancialAnalyticsToJson(_FinancialAnalytics instance) =>
    <String, dynamic>{
      'totalInvoiced': instance.totalInvoiced,
      'totalPaid': instance.totalPaid,
      'totalOutstanding': instance.totalOutstanding,
      'collectionRatePercentage': instance.collectionRatePercentage,
      'totalInvoicesCount': instance.totalInvoicesCount,
      'paidInvoicesCount': instance.paidInvoicesCount,
      'partialInvoicesCount': instance.partialInvoicesCount,
      'unpaidInvoicesCount': instance.unpaidInvoicesCount,
      'grossRevenue': instance.grossRevenue,
      'netProfitEstimate': instance.netProfitEstimate,
    };
