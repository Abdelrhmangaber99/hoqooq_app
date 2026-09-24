import '../../../../core/network/api_result.dart';
import '../../data/models/create_payment_request.dart';
import '../entities/case_finance_detail.dart';
import '../entities/finance_summary.dart';
import '../entities/payment_record.dart';

abstract class IFinanceRepository {
  /// Firm-wide aggregates (`GET /finance/summary`). Computed by the backend
  /// over the authenticated user's authorized case scope — never filtered
  /// or summed client-side. [queryParameters] carries PRD filters (date
  /// range, case type, lawyer, court, payment status) where the API
  /// supports them; omitted keys mean "unfiltered".
  ApiResult<FinanceSummary> getSummary({Map<String, dynamic>? queryParameters});
  ApiResult<CaseFinanceDetail> getCaseFinance(String caseId);

  /// Records a Case payment. The backend requires the Case to already have
  /// an agreed fee (`Set the Case agreed fee before recording payments`)
  /// and rejects any amount that would push total paid past it — so the
  /// agreed fee is written through the Cases module, never here.
  ApiResult<PaymentRecord> recordPayment(
    String caseId,
    CreatePaymentRequest request,
  );
  ApiResult<PaymentRecord> reversePayment(String paymentId, String reason);
}
