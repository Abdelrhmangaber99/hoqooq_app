import '../../../../core/network/api_result.dart';
import '../../data/models/create_invoice_request.dart';
import '../../data/models/create_payment_request.dart';
import '../../data/models/update_invoice_request.dart';
import '../entities/case_financial_summary.dart';
import '../entities/financial_analytics.dart';
import '../entities/invoice.dart';
import '../entities/payment.dart';
import '../entities/single_case_financial_detail.dart';

/// Mirrors API_CONTRACT.md finding R (Finance). No `deleteInvoice`/
/// `deletePayment` — `FinanceService.removeInvoice`/`.removePayment` are
/// confirmed hard deletes (`.remove()`, not `.softRemove()`), the one
/// place in the API where BR-028/BR-029 (financial records, no hard
/// delete) are actually contradicted by a real endpoint. Deliberately
/// deferred, per the approved M6 plan, not omitted by oversight.
///
/// No `getPaymentDetails`/`GET /finance/payments/{id}` — nothing in this
/// milestone's scope needs a standalone payment-detail fetch; payments are
/// shown inline on `Invoice.payments` and created against a known invoice.
/// No update method for payments either — `FinanceController` has no
/// `PATCH /finance/payments/{id}` at all.
abstract class IFinanceRepository {
  ApiResult<List<Invoice>> getInvoices();
  ApiResult<Invoice> getInvoiceDetails(String id);
  ApiResult<Invoice> createInvoice(CreateInvoiceRequest request);
  ApiResult<Invoice> updateInvoice(String id, UpdateInvoiceRequest request);
  ApiResult<List<Payment>> getPayments();
  ApiResult<Payment> createPayment(CreatePaymentRequest request);
  ApiResult<FinancialAnalytics> getFinancialAnalytics();
  ApiResult<List<CaseFinancialSummary>> getCasesFinancialSummary();
  ApiResult<SingleCaseFinancialDetail> getCaseFinancialSummary(String caseId);
}
