import '../entities/case_finance_status.dart';
import '../entities/finance_summary.dart';
import '../entities/payment_record.dart';

class CaseFinanceCalculation {
  final double agreedFee;
  final double paidAmount;
  final double remainingAmount;
  final CaseFinanceStatus status;

  const CaseFinanceCalculation({
    required this.agreedFee,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
  });
}

class FinanceValidationResult {
  final bool isValid;
  final String? errorMessage;

  const FinanceValidationResult.valid()
      : isValid = true,
        errorMessage = null;

  const FinanceValidationResult.invalid(this.errorMessage)
      : isValid = false;
}

/// Pure domain calculation and validation logic for HOQOOQ Finance (PRD v2.0).
class FinanceCalculator {
  FinanceCalculator._();

  /// Round monetary value to 2 decimal places to avoid floating-point precision issues.
  static double roundMoney(double value) {
    return (value * 100).roundToDouble() / 100;
  }

  /// Calculate total valid paid amount from source payment records (excluding reversed ones).
  static double calculatePaidAmount(List<PaymentRecord> payments) {
    final validPaymentsSum = payments
        .where((p) => !p.isReversed)
        .fold<double>(0.0, (sum, p) => sum + p.amount);
    return roundMoney(validPaymentsSum);
  }

  /// Calculate remaining amount: max(agreed_fee - paid_amount, 0).
  static double calculateRemainingAmount(double? agreedFee, double paidAmount) {
    final fee = agreedFee ?? 0.0;
    final remaining = fee - paidAmount;
    return roundMoney(remaining > 0 ? remaining : 0.0);
  }

  /// Derive payment status from agreed fee and valid paid amount.
  static CaseFinanceStatus deriveStatus(double? agreedFee, double paidAmount) {
    final fee = agreedFee ?? 0.0;
    if (fee <= 0) {
      return CaseFinanceStatus.unpaid;
    }
    if (paidAmount >= fee) {
      return CaseFinanceStatus.paid;
    }
    if (paidAmount > 0) {
      return CaseFinanceStatus.partial;
    }
    return CaseFinanceStatus.unpaid;
  }

  /// Calculate complete Case finance figures from source data.
  static CaseFinanceCalculation calculateCaseFinance({
    required double? agreedFee,
    required List<PaymentRecord> payments,
  }) {
    final fee = agreedFee != null && agreedFee > 0 ? roundMoney(agreedFee) : 0.0;
    final paid = calculatePaidAmount(payments);
    final remaining = calculateRemainingAmount(fee, paid);
    final status = deriveStatus(fee, paid);

    return CaseFinanceCalculation(
      agreedFee: fee,
      paidAmount: paid,
      remainingAmount: remaining,
      status: status,
    );
  }

  /// Validate payment creation rules according to PRD v2.0.
  static FinanceValidationResult validatePaymentCreation({
    required double amount,
    required double? agreedFee,
    required List<PaymentRecord> existingPayments,
    required String? caseTenantId,
    required String? userTenantId,
  }) {
    if (amount <= 0) {
      return const FinanceValidationResult.invalid('Payment amount must be greater than 0.');
    }

    if (caseTenantId != null && userTenantId != null && caseTenantId != userTenantId) {
      return const FinanceValidationResult.invalid('Cross-tenant access prohibited.');
    }

    if (agreedFee != null && agreedFee > 0) {
      final currentPaid = calculatePaidAmount(existingPayments);
      final remaining = calculateRemainingAmount(agreedFee, currentPaid);

      if (roundMoney(amount) > roundMoney(remaining)) {
        return FinanceValidationResult.invalid(
          'Payment amount ($amount) exceeds remaining balance ($remaining).',
        );
      }
    }

    return const FinanceValidationResult.valid();
  }

  /// Calculate firm-wide financial aggregates from case summaries.
  static FinanceSummary calculateFirmSummary(List<CaseFinanceSummaryRow> caseRows) {
    double totalCaseValue = 0.0;
    double totalCollected = 0.0;
    double totalOutstanding = 0.0;
    int paidCases = 0;
    int partialCases = 0;
    int unpaidCases = 0;

    for (final row in caseRows) {
      totalCaseValue += row.agreedFee;
      totalCollected += row.paid;
      totalOutstanding += row.remaining;

      switch (row.status) {
        case CaseFinanceStatus.paid:
          paidCases++;
          break;
        case CaseFinanceStatus.partial:
          partialCases++;
          break;
        case CaseFinanceStatus.unpaid:
          unpaidCases++;
          break;
      }
    }

    return FinanceSummary(
      totalCaseValue: roundMoney(totalCaseValue),
      totalCollected: roundMoney(totalCollected),
      totalOutstanding: roundMoney(totalOutstanding),
      paidCases: paidCases,
      partialCases: partialCases,
      unpaidCases: unpaidCases,
      cases: caseRows,
    );
  }
}
