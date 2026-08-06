import 'package:freezed_annotation/freezed_annotation.dart';
import 'payment_status.dart';

part 'case_financial_summary.freezed.dart';
part 'case_financial_summary.g.dart';

/// Wire shape for one entry of `GET /finance/cases-summary` per
/// API_CONTRACT.md finding R — hand-built by
/// `FinanceService.getCasesFinancialSummary`, reliable (not a raw entity).
@freezed
abstract class CaseFinancialSummary with _$CaseFinancialSummary {
  const factory CaseFinancialSummary({
    required String caseId,
    required String caseNumber,
    required String clientName,
    required double totalInvoiced,
    required double totalPaid,
    required double outstandingBalance,
    @JsonKey(unknownEnumValue: PaymentStatus.unknown)
    required PaymentStatus paymentStatus,
    required int invoicesCount,
  }) = _CaseFinancialSummary;

  factory CaseFinancialSummary.fromJson(Map<String, dynamic> json) =>
      _$CaseFinancialSummaryFromJson(json);
}
