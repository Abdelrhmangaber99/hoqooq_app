import 'package:freezed_annotation/freezed_annotation.dart';
import 'invoice.dart';
import 'payment_method.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

/// Wire shape for `GET/POST /finance/payments` per API_CONTRACT.md finding R.
///
/// Same "relations differ by call site, so every relation field is
/// nullable" reasoning as `Invoice` — see that entity's doc comment.
/// `findAllPayments`/`findOnePayment` load `relations: ['invoice']`, so
/// `invoice` is populated there; when a `Payment` appears nested inside
/// `Invoice.payments[]`, that back-reference isn't requested, so `invoice`
/// is `null` in that context instead. Note the request DTO's field is
/// `method`, not `paymentMethod` — the entity's own column (returned here)
/// is `paymentMethod`; these are two different names for the same concept
/// on the write side vs. the read side, not a typo.
@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String tenantId,
    required String invoiceId,
    required double amount,
    required DateTime paymentDate,
    @JsonKey(name: 'paymentMethod', unknownEnumValue: PaymentMethod.unknown)
    required PaymentMethod method,
    String? referenceNumber,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    Invoice? invoice,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
