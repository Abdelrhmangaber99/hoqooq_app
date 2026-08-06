import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/invoice_status.dart';

part 'create_invoice_request.freezed.dart';
part 'create_invoice_request.g.dart';

/// Request body for `POST /finance/invoices` per `CreateInvoiceDto`
/// (`Hoqooq-main/src/modules/finance/dtos/create-invoice.dto.ts`).
///
/// No `tenantId` field, and none needs injecting at the repository layer
/// either — unlike Cases/Clients, `CreateInvoiceDto` doesn't declare a
/// `tenantId` property at all; `FinanceController.createInvoice` sources it
/// straight from the JWT (`user.tenantId`), never from the request body.
@freezed
abstract class CreateInvoiceRequest with _$CreateInvoiceRequest {
  const factory CreateInvoiceRequest({
    required String clientId,
    String? caseId,
    required String invoiceNumber,
    required double subtotal,
    required double taxTotal,
    required double grandTotal,
    InvoiceStatus? status,
    required DateTime issueDate,
    required DateTime dueDate,
    String? notes,
  }) = _CreateInvoiceRequest;

  factory CreateInvoiceRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateInvoiceRequestFromJson(json);
}
