import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/invoice_status.dart';

part 'update_invoice_request.freezed.dart';
part 'update_invoice_request.g.dart';

/// Request body for `PATCH /finance/invoices/{id}` per `UpdateInvoiceDto`
/// (`PartialType(CreateInvoiceDto)` server-side — every field optional,
/// same shape as create otherwise). `clientId`/`caseId`/`invoiceNumber`
/// stay editable per the DTO (unlike Cases, nothing here is locked to
/// create-only) — this app doesn't restrict them further, matching the
/// backend's own contract exactly rather than guessing a business rule it
/// doesn't state.
///
/// Every field is `@JsonKey(includeIfNull: false)` — `FinanceService.
/// updateInvoice` does a TypeORM `merge()`, which would null out untouched
/// columns if the key were present at all, same reasoning as
/// `UpdateCaseRequest`/`UpdateClientRequest`.
@freezed
abstract class UpdateInvoiceRequest with _$UpdateInvoiceRequest {
  const factory UpdateInvoiceRequest({
    @JsonKey(includeIfNull: false) String? clientId,
    @JsonKey(includeIfNull: false) String? caseId,
    @JsonKey(includeIfNull: false) String? invoiceNumber,
    @JsonKey(includeIfNull: false) double? subtotal,
    @JsonKey(includeIfNull: false) double? taxTotal,
    @JsonKey(includeIfNull: false) double? grandTotal,
    @JsonKey(includeIfNull: false) InvoiceStatus? status,
    @JsonKey(includeIfNull: false) DateTime? issueDate,
    @JsonKey(includeIfNull: false) DateTime? dueDate,
    @JsonKey(includeIfNull: false) String? notes,
  }) = _UpdateInvoiceRequest;

  factory UpdateInvoiceRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateInvoiceRequestFromJson(json);
}
