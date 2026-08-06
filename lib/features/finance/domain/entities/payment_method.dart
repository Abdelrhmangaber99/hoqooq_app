import 'package:json_annotation/json_annotation.dart';

/// `method` on `CreatePaymentDto` / `paymentMethod` on the `Payment` entity
/// per API_CONTRACT.md finding R.
///
/// **Deliberately modeled from `CreatePaymentDto`'s enum
/// (`src/modules/finance/enums/payment-method.enum.ts`:
/// `CASH|BANK_TRANSFER|CHEQUE|ONLINE`), not the `Payment` entity's own
/// inline-declared enum (`payment.entity.ts`:
/// `CASH|BANK_TRANSFER|CREDIT_CARD|CHECK`)** — a real backend
/// inconsistency, two separately-declared enums with the same name and
/// different values. The DTO's enum is what `class-validator` actually
/// enforces on write, so that's the value set this app sends; `unknown`
/// covers a value the entity's enum might have used instead (`CREDIT_CARD`/
/// `CHECK`) showing up on a read.
enum PaymentMethod {
  @JsonValue('CASH')
  cash,
  @JsonValue('BANK_TRANSFER')
  bankTransfer,
  @JsonValue('CHEQUE')
  cheque,
  @JsonValue('ONLINE')
  online,
  @JsonValue('unknown')
  unknown,
}
