import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/finance/domain/entities/case_finance_status.dart';
import 'package:hqooq/features/finance/domain/entities/finance_summary.dart';

void main() {
  group('CaseFinanceSummaryRow.fromJson', () {
    test('parses full valid JSON response', () {
      final json = {
        'caseId': 'c123',
        'caseNumber': 'CASE-2026-001',
        'agreedFee': 5000,
        'paid': 2000,
        'remaining': 3000,
        'status': 'PARTIAL',
      };

      final row = CaseFinanceSummaryRow.fromJson(json);

      expect(row.caseId, 'c123');
      expect(row.caseNumber, 'CASE-2026-001');
      expect(row.agreedFee, 5000.0);
      expect(row.paid, 2000.0);
      expect(row.remaining, 3000.0);
      expect(row.status, CaseFinanceStatus.partial);
    });

    test('handles missing optional fields and double/int coercion', () {
      final json = {
        'caseId': 'c999',
        'agreedFee': 1000.5,
        'status': 'PAID',
      };

      final row = CaseFinanceSummaryRow.fromJson(json);

      expect(row.caseId, 'c999');
      expect(row.caseNumber, '');
      expect(row.agreedFee, 1000.5);
      expect(row.paid, 0.0);
      expect(row.remaining, 0.0);
      expect(row.status, CaseFinanceStatus.paid);
    });
  });

  group('FinanceSummary.fromJson', () {
    test('parses full summary payload with case list', () {
      final json = {
        'totalCaseValue': 15000,
        'totalCollected': 5000,
        'totalOutstanding': 10000,
        'paidCases': 1,
        'partialCases': 1,
        'unpaidCases': 1,
        'cases': [
          {
            'caseId': 'c1',
            'caseNumber': 'CASE-1',
            'agreedFee': 5000,
            'paid': 5000,
            'remaining': 0,
            'status': 'PAID',
          },
          {
            'caseId': 'c2',
            'caseNumber': 'CASE-2',
            'agreedFee': 10000,
            'paid': 0,
            'remaining': 10000,
            'status': 'UNPAID',
          },
        ],
      };

      final summary = FinanceSummary.fromJson(json);

      expect(summary.totalCaseValue, 15000.0);
      expect(summary.totalCollected, 5000.0);
      expect(summary.totalOutstanding, 10000.0);
      expect(summary.paidCases, 1);
      expect(summary.partialCases, 1);
      expect(summary.unpaidCases, 1);
      expect(summary.cases, hasLength(2));
      expect(summary.cases.first.status, CaseFinanceStatus.paid);
      expect(summary.cases.last.status, CaseFinanceStatus.unpaid);
    });

    test('handles empty or missing cases list gracefully', () {
      final json = <String, dynamic>{};

      final summary = FinanceSummary.fromJson(json);

      expect(summary.totalCaseValue, 0.0);
      expect(summary.totalCollected, 0.0);
      expect(summary.totalOutstanding, 0.0);
      expect(summary.paidCases, 0);
      expect(summary.partialCases, 0);
      expect(summary.unpaidCases, 0);
      expect(summary.cases, isEmpty);
    });
  });
}
