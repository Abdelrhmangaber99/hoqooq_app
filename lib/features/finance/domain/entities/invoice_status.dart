import 'package:json_annotation/json_annotation.dart';

/// `status` on `Invoice` per API_CONTRACT.md finding R.
///
/// Confirmed exhaustive from the actual backend source
/// (`src/modules/finance/entities/invoice.entity.ts`'s `InvoiceStatus`
/// enum).
enum InvoiceStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('SENT')
  sent,
  @JsonValue('PARTIAL')
  partial,
  @JsonValue('PAID')
  paid,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('unknown')
  unknown,
}
