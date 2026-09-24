import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/finance/domain/entities/case_finance_detail.dart';
import 'package:hqooq/features/finance/domain/entities/case_finance_status.dart';
import 'package:hqooq/features/finance/domain/entities/payment_method.dart';
import 'package:hqooq/features/finance/domain/entities/payment_record.dart';

PaymentRecord payment({
  String id = 'p1',
  double amount = 1000,
  bool reversed = false,
}) {
  return PaymentRecord(
    id: id,
    caseId: 'c1',
    amount: amount,
    paidAt: DateTime(2026, 8, 20),
    method: PaymentMethod.cash,
    reversedAt: reversed ? DateTime(2026, 8, 21) : null,
  );
}

void main() {
  group('CaseFinanceDetail (BR-027 derived figures)', () {
    test('empty case: paid = 0, remaining = agreed fee, status unpaid', () {
      const detail = CaseFinanceDetail(
        caseId: 'c1',
        agreedFee: 10000,
        payments: [],
      );

      expect(detail.paid, 0);
      expect(detail.remaining, 10000);
      expect(detail.status, CaseFinanceStatus.unpaid);
    });

    test('paid = sum of non-reversed payments only', () {
      final detail = CaseFinanceDetail(
        caseId: 'c1',
        agreedFee: 10000,
        payments: [
          payment(id: 'p1', amount: 4000),
          payment(id: 'p2', amount: 2500.50),
          payment(id: 'p3', amount: 999, reversed: true),
        ],
      );

      expect(detail.paid, 6500.50);
      expect(detail.remaining, 3499.50);
      expect(detail.status, CaseFinanceStatus.partial);
    });

    test('remaining clamps to 0 and status flips to paid at full settlement',
        () {
      final detail = CaseFinanceDetail(
        caseId: 'c1',
        agreedFee: 10000,
        payments: [payment(amount: 10000)],
      );

      expect(detail.remaining, 0);
      expect(detail.status, CaseFinanceStatus.paid);
    });

    test('no-fee case: remaining is null and never fabricates 0 as a fee', () {
      const detail = CaseFinanceDetail(
        caseId: 'c1',
        agreedFee: null,
        payments: [],
      );

      expect(detail.agreedFee, isNull);
      expect(detail.remaining, isNull);
      expect(detail.paid, 0);
      expect(detail.status, CaseFinanceStatus.unpaid);
    });

    test('fromJson: absent agreedFee parses to null, not 0', () {
      final detail = CaseFinanceDetail.fromJson({
        'caseId': 'c1',
        'payments': <Map<String, dynamic>>[
          {
            'id': 'p1',
            'caseId': 'c1',
            'amount': 250.5,
            'paidAt': '2026-08-20T00:00:00.000',
            'method': 'BANK_TRANSFER',
            'reference': 'TRX-1',
            'note': 'wire',
            'recordedByName': 'Ali',
          },
        ],
      });

      expect(detail.agreedFee, isNull);
      expect(detail.paid, 250.5);
      expect(detail.payments.single.recordedByName, 'Ali');
      expect(detail.payments.single.method, PaymentMethod.bankTransfer);
    });

    test('fromJson: server-computed paid/remaining keys are ignored in favor '
        'of source-record derivation', () {
      final detail = CaseFinanceDetail.fromJson({
        'caseId': 'c1',
        'agreedFee': 1000,
        'paid': 999999,
        'remaining': -5,
        'payments': <Map<String, dynamic>>[],
      });

      expect(detail.paid, 0);
      expect(detail.remaining, 1000);
    });
  });
}
