import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../cases/domain/entities/case_summary.dart';
import '../../../clients/domain/entities/client.dart';
import 'invoice_line_item.dart';
import 'invoice_status.dart';
import 'payment.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

/// Wire shape for `GET/POST/PATCH /finance/invoices` per API_CONTRACT.md
/// finding R.
///
/// `FinanceController` never applies `plainToInstance` — the real response
/// is the raw entity as loaded by `FinanceService`'s relations, which
/// **differ by call site**, not just by list-vs-detail like every other
/// module documented so far:
/// - `findAllInvoices` (`GET /finance/invoices`): `relations: ['client',
///   'case', 'payments']` — no `lineItems`.
/// - `findOneInvoice` (`GET /finance/invoices/{id}`): adds `lineItems`.
/// - `getCaseFinancialSummary`'s internal invoice fetch (nested inside
///   `SingleCaseFinancialDetail.invoices`): `relations: ['payments']`
///   only — no `client`, no `case`, no `lineItems`.
///
/// Every relation field is therefore nullable here (`client`/`caseSummary`/
/// `payments`/`lineItems`), populated only when the endpoint that produced
/// a given response actually requested it — reusing one `Invoice` type
/// across all three shapes is safe specifically because none of them are
/// declared `required`, unlike the M2 `LegalCase` regression this pattern
/// is named after. `id`/`tenantId`/`clientId`/`invoiceNumber`/`status`/
/// dates/totals are the entity's own columns, always present regardless of
/// `relations`.
@freezed
abstract class Invoice with _$Invoice {
  const factory Invoice({
    required String id,
    required String tenantId,
    required String clientId,
    required String invoiceNumber,
    @JsonKey(unknownEnumValue: InvoiceStatus.unknown)
    required InvoiceStatus status,
    required DateTime issueDate,
    required DateTime dueDate,
    required double subtotal,
    required double taxTotal,
    required double grandTotal,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? caseId,
    @JsonKey(name: 'case') CaseSummary? caseSummary,
    Client? client,
    List<Payment>? payments,
    List<InvoiceLineItem>? lineItems,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
}
