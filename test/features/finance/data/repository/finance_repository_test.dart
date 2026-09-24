import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/finance/data/models/create_payment_request.dart';
import 'package:hqooq/features/finance/data/repository/finance_repository.dart';
import 'package:hqooq/features/finance/domain/entities/case_finance_status.dart';
import 'package:hqooq/features/finance/domain/entities/payment_method.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late FinanceRepository repository;

  setUp(() {
    dio = MockDio();
    repository = FinanceRepository(dio);
  });

  group('FinanceRepository API Layer Tests', () {
    test('getSummary returns FinanceSummary on HTTP 200', () async {
      when(
        () => dio.get(
          '/finance/summary',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'totalCaseValue': 10000,
            'totalCollected': 4000,
            'totalOutstanding': 6000,
            'paidCases': 1,
            'partialCases': 1,
            'unpaidCases': 0,
            'cases': [
              {
                'caseId': 'c1',
                'caseNumber': 'C-1',
                'agreedFee': 5000,
                'paid': 4000,
                'remaining': 1000,
                'status': 'PARTIAL',
              },
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/finance/summary'),
        ),
      );

      final result = await repository.getSummary();

      expect(result.isRight(), true);
      result.fold((l) => fail('Should be right'), (summary) {
        expect(summary.totalCaseValue, 10000.0);
        expect(summary.totalCollected, 4000.0);
        expect(summary.cases, hasLength(1));
        expect(summary.cases.first.status, CaseFinanceStatus.partial);
      });
    });

    test('getCaseFinance returns CaseFinanceDetail on HTTP 200', () async {
      when(() => dio.get('/finance/cases/c123')).thenAnswer(
        (_) async => Response(
          data: {
            'caseId': 'c123',
            'agreedFee': 5000,
            'paid': 2000,
            'remaining': 3000,
            'payments': [
              {
                'id': 'p1',
                'caseId': 'c123',
                'amount': 2000,
                'paidAt': '2026-08-01T00:00:00.000Z',
                'method': 'CASH',
              },
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/finance/cases/c123'),
        ),
      );

      final result = await repository.getCaseFinance('c123');

      expect(result.isRight(), true);
      result.fold((l) => fail('Should be right'), (detail) {
        expect(detail.caseId, 'c123');
        expect(detail.agreedFee, 5000.0);
        expect(detail.paid, 2000.0);
        expect(detail.remaining, 3000.0);
        expect(detail.payments, hasLength(1));
      });
    });

    // No agreed-fee writer is tested here: the Case Finance API has no such
    // route (the fee is a Case column written through `PATCH /cases/:id`).

    test(
      'recordPayment issues POST request with valid CreatePaymentRequest',
      () async {
        const request = CreatePaymentRequest(
          amount: 1500.0,
          paidAt: '2026-08-15',
          method: PaymentMethod.bankTransfer,
          reference: 'REF-999',
          note: 'Deposit payment',
        );

        when(
          () =>
              dio.post('/finance/cases/c123/payments', data: request.toJson()),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'id': 'p2',
              'caseId': 'c123',
              'amount': 1500,
              'paidAt': '2026-08-15T00:00:00.000Z',
              'method': 'BANK_TRANSFER',
              'reference': 'REF-999',
              'note': 'Deposit payment',
            },
            statusCode: 201,
            requestOptions: RequestOptions(
              path: '/finance/cases/c123/payments',
            ),
          ),
        );

        final result = await repository.recordPayment('c123', request);

        expect(result.isRight(), true);
        result.fold((l) => fail('Should be right'), (payment) {
          expect(payment.id, 'p2');
          expect(payment.amount, 1500.0);
          expect(payment.method, PaymentMethod.bankTransfer);
          expect(payment.reference, 'REF-999');
        });
      },
    );

    test(
      'reversePayment issues PATCH request and returns updated PaymentRecord with reversedAt',
      () async {
        when(
          () => dio.patch(
            '/finance/payments/p1/reverse',
            data: {'reason': 'Bank rejection'},
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'id': 'p1',
              'caseId': 'c123',
              'amount': 2000,
              'paidAt': '2026-08-01T00:00:00.000Z',
              'method': 'CASH',
              'reversedAt': '2026-08-16T10:00:00.000Z',
              'reversalReason': 'Bank rejection',
            },
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/finance/payments/p1/reverse',
            ),
          ),
        );

        final result = await repository.reversePayment('p1', 'Bank rejection');

        expect(result.isRight(), true);
        result.fold((l) => fail('Should be right'), (payment) {
          expect(payment.id, 'p1');
          expect(payment.isReversed, true);
          expect(payment.reversalReason, 'Bank rejection');
        });
      },
    );
  });
}
