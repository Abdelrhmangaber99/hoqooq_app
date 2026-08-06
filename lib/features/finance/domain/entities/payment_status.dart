import 'package:json_annotation/json_annotation.dart';

/// `paymentStatus` on `CaseFinancialSummaryDto`/`SingleCaseFinancialDetailDto`
/// per API_CONTRACT.md finding R — a hand-computed aggregate over an
/// invoice's (or a case's) payments, distinct from `InvoiceStatus` (which is
/// a column on a single invoice, settable directly).
enum PaymentStatus {
  @JsonValue('PAID')
  paid,
  @JsonValue('PARTIAL')
  partial,
  @JsonValue('UNPAID')
  unpaid,
  @JsonValue('NO_INVOICE')
  noInvoice,
  @JsonValue('unknown')
  unknown,
}
