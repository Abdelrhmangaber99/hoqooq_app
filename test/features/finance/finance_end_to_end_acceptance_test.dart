import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/finance/domain/entities/case_finance_status.dart';
import 'package:hqooq/features/finance/domain/entities/finance_summary.dart';
import 'package:hqooq/features/finance/domain/entities/payment_method.dart';
import 'package:hqooq/features/finance/domain/entities/payment_record.dart';
import 'package:hqooq/features/finance/domain/usecases/finance_calculator.dart';

void main() {
  group('HOQOOQ Finance v2.0 End-to-End Acceptance Test Suite', () {
    final now = DateTime.now();

    test('Business Acceptance Scenario: Case Fee 100k -> 20k + 30k -> 50k -> Reversal -> Reconciliation', () {
      final double agreedFee = 100000.0;

      // Initial state: Fee set, no payments
      var calcStep0 = FinanceCalculator.calculateCaseFinance(
        agreedFee: agreedFee,
        payments: [],
      );
      expect(calcStep0.agreedFee, 100000.0);
      expect(calcStep0.paidAmount, 0.0);
      expect(calcStep0.remainingAmount, 100000.0);
      expect(calcStep0.status, CaseFinanceStatus.unpaid);

      // Payment 1: 20,000
      final p1 = PaymentRecord(
        id: 'p1',
        caseId: 'case-100',
        amount: 20000.0,
        paidAt: now,
        method: PaymentMethod.bankTransfer,
      );

      // Payment 2: 30,000
      final p2 = PaymentRecord(
        id: 'p2',
        caseId: 'case-100',
        amount: 30000.0,
        paidAt: now,
        method: PaymentMethod.bankTransfer,
      );

      var calcStep1 = FinanceCalculator.calculateCaseFinance(
        agreedFee: agreedFee,
        payments: [p1, p2],
      );

      expect(calcStep1.agreedFee, 100000.0);
      expect(calcStep1.paidAmount, 50000.0);
      expect(calcStep1.remainingAmount, 50000.0);
      expect(calcStep1.status, CaseFinanceStatus.partial);

      // Payment 3: 50,000
      final p3 = PaymentRecord(
        id: 'p3',
        caseId: 'case-100',
        amount: 50000.0,
        paidAt: now,
        method: PaymentMethod.cash,
      );

      var calcStep2 = FinanceCalculator.calculateCaseFinance(
        agreedFee: agreedFee,
        payments: [p1, p2, p3],
      );

      expect(calcStep2.paidAmount, 100000.0);
      expect(calcStep2.remainingAmount, 0.0);
      expect(calcStep2.status, CaseFinanceStatus.paid);

      // Reversal: Payment 2 (30,000) is reversed
      final p2Reversed = PaymentRecord(
        id: 'p2',
        caseId: 'case-100',
        amount: 30000.0,
        paidAt: now,
        method: PaymentMethod.bankTransfer,
        reversedAt: now,
        reversalReason: 'Bank correction',
      );

      var calcStep3 = FinanceCalculator.calculateCaseFinance(
        agreedFee: agreedFee,
        payments: [p1, p2Reversed, p3], // 20,000 + 50,000 = 70,000
      );

      expect(calcStep3.paidAmount, 70000.0);
      expect(calcStep3.remainingAmount, 30000.0);
      expect(calcStep3.status, CaseFinanceStatus.partial);
      expect(p2Reversed.isReversed, true);
    });

    test('Firm Dashboard Reconciliation with Case Finance States', () {
      final caseRows = [
        const CaseFinanceSummaryRow(
          caseId: 'c1',
          caseNumber: 'CASE-001',
          agreedFee: 100000.0,
          paid: 100000.0,
          remaining: 0.0,
          status: CaseFinanceStatus.paid,
        ),
        const CaseFinanceSummaryRow(
          caseId: 'c2',
          caseNumber: 'CASE-002',
          agreedFee: 50000.0,
          paid: 20000.0,
          remaining: 30000.0,
          status: CaseFinanceStatus.partial,
        ),
        const CaseFinanceSummaryRow(
          caseId: 'c3',
          caseNumber: 'CASE-003',
          agreedFee: 25000.0,
          paid: 0.0,
          remaining: 25000.0,
          status: CaseFinanceStatus.unpaid,
        ),
      ];

      final summary = FinanceCalculator.calculateFirmSummary(caseRows);

      expect(summary.totalCaseValue, 175000.0);
      expect(summary.totalCollected, 120000.0);
      expect(summary.totalOutstanding, 55000.0);
      expect(summary.paidCases, 1);
      expect(summary.partialCases, 1);
      expect(summary.unpaidCases, 1);
      expect(summary.cases, hasLength(3));
    });
  });
}
