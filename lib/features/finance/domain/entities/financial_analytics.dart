import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_analytics.freezed.dart';
part 'financial_analytics.g.dart';

/// Wire shape for `GET /finance/analytics` per API_CONTRACT.md finding R.
///
/// Hand-built by `FinanceService.getFinancialAnalytics` (not a raw
/// entity) — unlike `Invoice`/`Payment`, this response shape is reliable,
/// no relations-vary-by-call-site caveat applies here.
@freezed
abstract class FinancialAnalytics with _$FinancialAnalytics {
  const factory FinancialAnalytics({
    required double totalInvoiced,
    required double totalPaid,
    required double totalOutstanding,
    required double collectionRatePercentage,
    required int totalInvoicesCount,
    required int paidInvoicesCount,
    required int partialInvoicesCount,
    required int unpaidInvoicesCount,
    required double grossRevenue,
    required double netProfitEstimate,
  }) = _FinancialAnalytics;

  factory FinancialAnalytics.fromJson(Map<String, dynamic> json) =>
      _$FinancialAnalyticsFromJson(json);
}
