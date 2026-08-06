import 'package:freezed_annotation/freezed_annotation.dart';
import 'invoice.dart';
import 'payment_status.dart';

part 'single_case_financial_detail.freezed.dart';
part 'single_case_financial_detail.g.dart';

/// Wire shape for `GET /finance/cases/:caseId/summary` per API_CONTRACT.md
/// finding R — powers `CaseDetailsPage`'s Financials section. Hand-built
/// by `FinanceService.getCaseFinancialSummary` (the wrapper fields are
/// reliable); `invoices[]` nests real `Invoice` entities, but only with
/// `relations: ['payments']` loaded — no `client`/`case`/`lineItems` on
/// any of them, which `Invoice`'s all-nullable relation fields already
/// account for (see that entity's doc comment).
@freezed
abstract class SingleCaseFinancialDetail with _$SingleCaseFinancialDetail {
  const factory SingleCaseFinancialDetail({
    required String caseId,
    required String caseNumber,
    required String clientName,
    required double totalInvoiced,
    required double totalPaid,
    required double outstandingBalance,
    @JsonKey(unknownEnumValue: PaymentStatus.unknown)
    required PaymentStatus paymentStatus,
    required List<Invoice> invoices,
  }) = _SingleCaseFinancialDetail;

  factory SingleCaseFinancialDetail.fromJson(Map<String, dynamic> json) =>
      _$SingleCaseFinancialDetailFromJson(json);
}
