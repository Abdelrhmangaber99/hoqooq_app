import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/payment_method.dart';

part 'create_payment_request.freezed.dart';
part 'create_payment_request.g.dart';

/// Request body for `POST /finance/payments` per `CreatePaymentDto`
/// (`Hoqooq-main/src/modules/finance/dtos/create-payment.dto.ts`).
///
/// No update/delete request models — `FinanceController` has no `PATCH
/// /finance/payments/{id}` at all (a payment can be created or deleted,
/// never edited), and delete is out of scope for this milestone (see
/// API_CONTRACT.md finding R — Finance hard-deletes, contradicting
/// BR-028/BR-029).
///
/// The field is `method` here (matches the DTO exactly), not
/// `paymentMethod` — that's the `Payment` *entity*'s column name, returned
/// on read, not what's accepted on write. Two different names for the same
/// concept depending on which side of the request you're on, confirmed
/// from source, not a typo.
@freezed
abstract class CreatePaymentRequest with _$CreatePaymentRequest {
  const factory CreatePaymentRequest({
    required String invoiceId,
    required double amount,
    required DateTime paymentDate,
    @JsonKey(unknownEnumValue: PaymentMethod.unknown)
    required PaymentMethod method,
    String? referenceNumber,
  }) = _CreatePaymentRequest;

  factory CreatePaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentRequestFromJson(json);
}
