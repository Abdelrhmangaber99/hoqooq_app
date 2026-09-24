import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/finance/domain/entities/case_finance_status.dart';
import 'package:hqooq/features/finance/domain/entities/finance_summary.dart';
import 'package:hqooq/features/finance/domain/entities/payment_method.dart';
import 'package:hqooq/features/finance/domain/entities/payment_record.dart';
import 'package:hqooq/features/finance/domain/usecases/finance_calculator.dart';

void main() {
  group('FinanceCalculator PRD v2.0 Rule Verification Tests', () {
    final now = DateTime.now();

    PaymentRecord createPayment({
      required String id,
      required double amount,
      bool isReversed = false,
    }) {
      return PaymentRecord(
        id: id,
        caseId: 'case-123',
        amount: amount,
        paidAt: now,
        method: PaymentMethod.cash,
        reversedAt: isReversed ? now : null,
        reversalReason: isReversed ? 'Cancelled' : null,
      );
    }

    // Scenario 1: No fee + no payments
    test('Scenario 1: No fee + no payments', () {
      final calc = FinanceCalculator.calculateCaseFinance(
        agreedFee: null,
        payments: [],
      );

      expect(calc.agreedFee, 0.0);
      expect(calc.paidAmount, 0.0);
      expect(calc.remainingAmount, 0.0);
      expect(calc.status, CaseFinanceStatus.unpaid);
    });

    // Scenario 2: Fee + no payments
    test('Scenario 2: Fee + no payments', () {
      final calc = FinanceCalculator.calculateCaseFinance(
        agreedFee: 1000.0,
        payments: [],
      );

      expect(calc.agreedFee, 1000.0);
      expect(calc.paidAmount, 0.0);
      expect(calc.remainingAmount, 1000.0);
      expect(calc.status, CaseFinanceStatus.unpaid);
    });

    // Scenario 3: Fee + one payment
    test('Scenario 3: Fee + one payment', () {
      final payments = [createPayment(id: 'p1', amount: 400.0)];
      final calc = FinanceCalculator.calculateCaseFinance(
        agreedFee: 1000.0,
        payments: payments,
      );

      expect(calc.agreedFee, 1000.0);
      expect(calc.paidAmount, 400.0);
      expect(calc.remainingAmount, 600.0);
      expect(calc.status, CaseFinanceStatus.partial);
    });

    // Scenario 4: Fee + multiple payments
    test('Scenario 4: Fee + multiple payments', () {
      final payments = [
        createPayment(id: 'p1', amount: 300.0),
        createPayment(id: 'p2', amount: 400.0),
      ];
      final calc = FinanceCalculator.calculateCaseFinance(
        agreedFee: 1000.0,
        payments: payments,
      );

      expect(calc.agreedFee, 1000.0);
      expect(calc.paidAmount, 700.0);
      expect(calc.remainingAmount, 300.0);
      expect(calc.status, CaseFinanceStatus.partial);
    });

    // Scenario 5: Fully paid case
    test('Scenario 5: Fully paid case', () {
      final payments = [
        createPayment(id: 'p1', amount: 600.0),
        createPayment(id: 'p2', amount: 400.0),
      ];
      final calc = FinanceCalculator.calculateCaseFinance(
        agreedFee: 1000.0,
        payments: payments,
      );

      expect(calc.agreedFee, 1000.0);
      expect(calc.paidAmount, 1000.0);
      expect(calc.remainingAmount, 0.0);
      expect(calc.status, CaseFinanceStatus.paid);
    });

    // Scenario 6: Reversed payment excluded
    test('Scenario 6: Reversed payment excluded from paid amount', () {
      final payments = [
        createPayment(id: 'p1', amount: 500.0),
        createPayment(id: 'p2', amount: 300.0, isReversed: true),
      ];
      final calc = FinanceCalculator.calculateCaseFinance(
        agreedFee: 1000.0,
        payments: payments,
      );

      expect(calc.paidAmount, 500.0);
      expect(calc.remainingAmount, 500.0);
      expect(calc.status, CaseFinanceStatus.partial);
    });

    // Scenario 7: Attempted invalid payment amount
    test('Scenario 7: Attempted invalid payment amount (<= 0)', () {
      final validation1 = FinanceCalculator.validatePaymentCreation(
        amount: 0.0,
        agreedFee: 1000.0,
        existingPayments: [],
        caseTenantId: 't1',
        userTenantId: 't1',
      );

      final validation2 = FinanceCalculator.validatePaymentCreation(
        amount: -50.0,
        agreedFee: 1000.0,
        existingPayments: [],
        caseTenantId: 't1',
        userTenantId: 't1',
      );

      expect(validation1.isValid, false);
      expect(validation1.errorMessage, contains('greater than 0'));
      expect(validation2.isValid, false);
      expect(validation2.errorMessage, contains('greater than 0'));
    });

    // Scenario 8: Attempted overpayment
    test('Scenario 8: Attempted overpayment rejected', () {
      final payments = [createPayment(id: 'p1', amount: 700.0)];

      final validation = FinanceCalculator.validatePaymentCreation(
        amount: 400.0, // 700 + 400 = 1100 > 1000
        agreedFee: 1000.0,
        existingPayments: payments,
        caseTenantId: 't1',
        userTenantId: 't1',
      );

      expect(validation.isValid, false);
      expect(validation.errorMessage, contains('exceeds remaining balance'));
    });

    // Scenario 9: Cross-tenant payment access
    test('Scenario 9: Cross-tenant payment access prohibited', () {
      final validation = FinanceCalculator.validatePaymentCreation(
        amount: 100.0,
        agreedFee: 1000.0,
        existingPayments: [],
        caseTenantId: 'tenant-A',
        userTenantId: 'tenant-B',
      );

      expect(validation.isValid, false);
      expect(validation.errorMessage, contains('Cross-tenant access prohibited'));
    });

    // Scenario 10: Aggregate calculations
    test('Scenario 10: Aggregate calculations across cases', () {
      const caseRows = [
        CaseFinanceSummaryRow(
          caseId: 'c1',
          caseNumber: '1',
          agreedFee: 5000.0,
          paid: 5000.0,
          remaining: 0.0,
          status: CaseFinanceStatus.paid,
        ),
        CaseFinanceSummaryRow(
          caseId: 'c2',
          caseNumber: '2',
          agreedFee: 10000.0,
          paid: 4000.0,
          remaining: 6000.0,
          status: CaseFinanceStatus.partial,
        ),
        CaseFinanceSummaryRow(
          caseId: 'c3',
          caseNumber: '3',
          agreedFee: 3000.0,
          paid: 0.0,
          remaining: 3000.0,
          status: CaseFinanceStatus.unpaid,
        ),
      ];

      final summary = FinanceCalculator.calculateFirmSummary(caseRows);

      expect(summary.totalCaseValue, 18000.0);
      expect(summary.totalCollected, 9000.0);
      expect(summary.totalOutstanding, 9000.0);
      expect(summary.paidCases, 1);
      expect(summary.partialCases, 1);
      expect(summary.unpaidCases, 1);
    });

    // Scenario 11: Paid/unpaid/partial status transitions
    test('Scenario 11: Status derivation edge cases', () {
      expect(FinanceCalculator.deriveStatus(0, 0), CaseFinanceStatus.unpaid);
      expect(FinanceCalculator.deriveStatus(1000, 0), CaseFinanceStatus.unpaid);
      expect(FinanceCalculator.deriveStatus(1000, 0.01), CaseFinanceStatus.partial);
      expect(FinanceCalculator.deriveStatus(1000, 999.99), CaseFinanceStatus.partial);
      expect(FinanceCalculator.deriveStatus(1000, 1000), CaseFinanceStatus.paid);
      expect(FinanceCalculator.deriveStatus(1000, 1500), CaseFinanceStatus.paid);
    });
  });
}
