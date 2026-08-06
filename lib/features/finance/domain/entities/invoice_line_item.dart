import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_line_item.freezed.dart';
part 'invoice_line_item.g.dart';

/// Nested inside `Invoice.lineItems` (`GET /finance/invoices/{id}` only —
/// see `Invoice`'s doc comment) per API_CONTRACT.md finding R. Read-only:
/// no CRUD endpoint exists for line items despite the entity/relation being
/// present — `Invoice.subtotal`/`taxTotal`/`grandTotal` stay flat,
/// client-entered numbers, not derived from these.
///
/// **`taxRate`'s real JSON key is `tax_rate` (snake_case)** — the only
/// non-camelCase field found anywhere in this API. Confirmed from the
/// backend source directly: `invoice-line-item.entity.ts` declares the TS
/// property itself as `tax_rate` (not `taxRate` with a `name:` override,
/// the pattern every other snake_case-in-the-DB column in this codebase
/// uses) — since `FinanceController` never applies `plainToInstance`, the
/// wire JSON reflects that property name verbatim.
@freezed
abstract class InvoiceLineItem with _$InvoiceLineItem {
  const factory InvoiceLineItem({
    required String id,
    required String invoiceId,
    required String description,
    required double quantity,
    required double unitPrice,
    @JsonKey(name: 'tax_rate') required double taxRate,
    required double total,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _InvoiceLineItem;

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceLineItemFromJson(json);
}
