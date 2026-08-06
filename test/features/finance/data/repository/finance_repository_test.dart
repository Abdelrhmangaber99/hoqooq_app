import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/finance/data/models/create_invoice_request.dart';
import 'package:hqooq/features/finance/data/models/create_payment_request.dart';
import 'package:hqooq/features/finance/data/models/update_invoice_request.dart';
import 'package:hqooq/features/finance/data/repository/finance_repository.dart';
import 'package:hqooq/features/finance/domain/entities/invoice_status.dart';
import 'package:hqooq/features/finance/domain/entities/payment_method.dart';
import 'package:hqooq/features/finance/domain/entities/payment_status.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late FinanceRepository repository;

  setUp(() {
    dio = MockDio();
    repository = FinanceRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  // Real shape confirmed from Hoqooq-main source (API_CONTRACT.md finding
  // R): FinanceController never applies plainToInstance -- the wire shape
  // is governed by FinanceService's relations, which differ by call site.
  // List: relations ['client', 'case', 'payments'] -- no lineItems.
  Map<String, dynamic> invoiceListJson({String status = 'DRAFT'}) {
    return {
      'id': 'inv1',
      'tenantId': 't1',
      'clientId': 'cl1',
      'invoiceNumber': 'INV-2026-0001',
      'status': status,
      'issueDate': '2026-01-01',
      'dueDate': '2026-01-31',
      'subtotal': 1000.0,
      'taxTotal': 100.0,
      'grandTotal': 1100.0,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'client': {
        'id': 'cl1',
        'tenantId': 't1',
        'clientCode': 'CLI-001',
        'type': 'INDIVIDUAL',
        'fullName': 'Carlos Hernandez',
        'status': 'ACTIVE',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
        'emails': <String>[],
        'phones': <String>[],
        'addresses': <String>[],
      },
      'payments': <Map<String, dynamic>>[],
    };
  }

  // Detail: relations ['client', 'case', 'payments', 'lineItems'].
  Map<String, dynamic> invoiceDetailJson() {
    return {
      ...invoiceListJson(),
      'lineItems': [
        {
          'id': 'li1',
          'invoiceId': 'inv1',
          'description': 'Legal consultation',
          'quantity': 2.0,
          'unitPrice': 500.0,
          // Real JSON key is snake_case tax_rate -- see InvoiceLineItem's
          // doc comment (the one non-camelCase field in this API).
          'tax_rate': 10.0,
          'total': 1100.0,
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
        },
      ],
    };
  }

  Map<String, dynamic> paymentJson() {
    return {
      'id': 'pay1',
      'tenantId': 't1',
      'invoiceId': 'inv1',
      'amount': 500.0,
      'paymentDate': '2026-01-15',
      'paymentMethod': 'BANK_TRANSFER',
      'referenceNumber': 'REF-001',
      'createdAt': '2026-01-15T00:00:00.000Z',
      'updatedAt': '2026-01-15T00:00:00.000Z',
    };
  }

  group('getInvoices', () {
    test('GETs /finance/invoices and parses the full shape', () async {
      when(() => dio.get('/finance/invoices')).thenAnswer(
        (_) async => okResponse('/finance/invoices', [invoiceListJson()]),
      );

      final result = await repository.getInvoices();

      verify(() => dio.get('/finance/invoices')).called(1);
      result.fold((_) => fail('expected Right'), (invoices) {
        expect(invoices, hasLength(1));
        expect(invoices.first.invoiceNumber, 'INV-2026-0001');
        expect(invoices.first.status, InvoiceStatus.draft);
        expect(invoices.first.client?.fullName, 'Carlos Hernandez');
        // lineItems key is absent entirely on the list endpoint.
        expect(invoices.first.lineItems, isNull);
      });
    });

    test('falls back to unknown for an unrecognized status', () async {
      when(() => dio.get('/finance/invoices')).thenAnswer(
        (_) async => okResponse('/finance/invoices', [
          invoiceListJson(status: 'SOMETHING_NEW'),
        ]),
      );

      final result = await repository.getInvoices();

      result.fold((_) => fail('expected Right'), (invoices) {
        expect(invoices.first.status, InvoiceStatus.unknown);
      });
    });

    test('maps a connection error to NetworkFailure', () async {
      when(() => dio.get('/finance/invoices')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/finance/invoices'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.getInvoices();

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('getInvoiceDetails', () {
    test('GETs /finance/invoices/{id} and parses lineItems', () async {
      when(() => dio.get('/finance/invoices/inv1')).thenAnswer(
        (_) async => okResponse('/finance/invoices/inv1', invoiceDetailJson()),
      );

      final result = await repository.getInvoiceDetails('inv1');

      verify(() => dio.get('/finance/invoices/inv1')).called(1);
      result.fold((_) => fail('expected Right'), (invoice) {
        expect(invoice.lineItems, hasLength(1));
        expect(invoice.lineItems!.first.taxRate, 10.0);
        expect(invoice.lineItems!.first.description, 'Legal consultation');
      });
    });
  });

  group('createInvoice', () {
    test(
      'POSTs /finance/invoices with the request body, no tenantId',
      () async {
        when(
          () => dio.post('/finance/invoices', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => okResponse('/finance/invoices', invoiceListJson()),
        );

        final request = CreateInvoiceRequest(
          clientId: 'cl1',
          invoiceNumber: 'INV-2026-0001',
          subtotal: 1000,
          taxTotal: 100,
          grandTotal: 1100,
          issueDate: DateTime(2026, 1, 1),
          dueDate: DateTime(2026, 1, 31),
        );
        await repository.createInvoice(request);

        final captured = verify(
          () => dio.post('/finance/invoices', data: captureAny(named: 'data')),
        ).captured;
        final body = captured.single as Map<String, dynamic>;
        expect(body.containsKey('tenantId'), isFalse);
        expect(body['clientId'], 'cl1');
      },
    );

    test('maps a 400 to ValidationFailure', () async {
      when(
        () => dio.post('/finance/invoices', data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/finance/invoices'),
          response: Response(
            requestOptions: RequestOptions(path: '/finance/invoices'),
            statusCode: 400,
            data: {'message': 'grandTotal must be a positive number'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final request = CreateInvoiceRequest(
        clientId: 'cl1',
        invoiceNumber: 'INV-2026-0001',
        subtotal: 1000,
        taxTotal: 100,
        grandTotal: -1,
        issueDate: DateTime(2026, 1, 1),
        dueDate: DateTime(2026, 1, 31),
      );
      final result = await repository.createInvoice(request);

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('updateInvoice', () {
    test(
      'PATCHes /finance/invoices/{id} with only the changed fields',
      () async {
        when(
          () => dio.patch('/finance/invoices/inv1', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => okResponse('/finance/invoices/inv1', invoiceListJson()),
        );

        const request = UpdateInvoiceRequest(status: InvoiceStatus.sent);
        await repository.updateInvoice('inv1', request);

        final captured = verify(
          () => dio.patch(
            '/finance/invoices/inv1',
            data: captureAny(named: 'data'),
          ),
        ).captured;
        final body = captured.single as Map<String, dynamic>;
        expect(body, {'status': 'SENT'});
      },
    );
  });

  group('getPayments', () {
    test('GETs /finance/payments and parses the shape', () async {
      when(() => dio.get('/finance/payments')).thenAnswer(
        (_) async => okResponse('/finance/payments', [paymentJson()]),
      );

      final result = await repository.getPayments();

      verify(() => dio.get('/finance/payments')).called(1);
      result.fold((_) => fail('expected Right'), (payments) {
        expect(payments, hasLength(1));
        expect(payments.first.amount, 500.0);
        expect(payments.first.method, PaymentMethod.bankTransfer);
        // JSON key is paymentMethod, not method -- confirms the DTO/entity
        // field-name mismatch from finding R is handled correctly.
      });
    });
  });

  group('createPayment', () {
    test('POSTs /finance/payments with method (not paymentMethod)', () async {
      when(
        () => dio.post('/finance/payments', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/finance/payments', paymentJson()));

      final request = CreatePaymentRequest(
        invoiceId: 'inv1',
        amount: 500,
        paymentDate: DateTime(2026, 1, 15),
        method: PaymentMethod.cash,
      );
      await repository.createPayment(request);

      final captured = verify(
        () => dio.post('/finance/payments', data: captureAny(named: 'data')),
      ).captured;
      final body = captured.single as Map<String, dynamic>;
      expect(body['method'], 'CASH');
      expect(body.containsKey('paymentMethod'), isFalse);
    });

    test('maps a 403 to ForbiddenFailure', () async {
      when(
        () => dio.post('/finance/payments', data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/finance/payments'),
          response: Response(
            requestOptions: RequestOptions(path: '/finance/payments'),
            statusCode: 403,
            data: {'message': 'Insufficient permissions'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final request = CreatePaymentRequest(
        invoiceId: 'inv1',
        amount: 500,
        paymentDate: DateTime(2026, 1, 15),
        method: PaymentMethod.cash,
      );
      final result = await repository.createPayment(request);

      result.fold(
        (failure) => expect(failure, isA<ForbiddenFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('getFinancialAnalytics', () {
    test('GETs /finance/analytics and parses the hand-built shape', () async {
      when(() => dio.get('/finance/analytics')).thenAnswer(
        (_) async => okResponse('/finance/analytics', {
          'totalInvoiced': 125000.5,
          'totalPaid': 95000.0,
          'totalOutstanding': 30000.5,
          'collectionRatePercentage': 76.0,
          'totalInvoicesCount': 45,
          'paidInvoicesCount': 30,
          'partialInvoicesCount': 10,
          'unpaidInvoicesCount': 5,
          'grossRevenue': 95000.0,
          'netProfitEstimate': 95000.0,
        }),
      );

      final result = await repository.getFinancialAnalytics();

      verify(() => dio.get('/finance/analytics')).called(1);
      result.fold((_) => fail('expected Right'), (analytics) {
        expect(analytics.totalInvoiced, 125000.5);
        expect(analytics.totalInvoicesCount, 45);
      });
    });
  });

  group('getCasesFinancialSummary', () {
    test('GETs /finance/cases-summary and parses paymentStatus', () async {
      when(() => dio.get('/finance/cases-summary')).thenAnswer(
        (_) async => okResponse('/finance/cases-summary', [
          {
            'caseId': 'c1',
            'caseNumber': 'CASE-2026-00001',
            'clientName': 'Carlos Hernandez',
            'totalInvoiced': 15000.0,
            'totalPaid': 10000.0,
            'outstandingBalance': 5000.0,
            'paymentStatus': 'PARTIAL',
            'invoicesCount': 2,
          },
        ]),
      );

      final result = await repository.getCasesFinancialSummary();

      verify(() => dio.get('/finance/cases-summary')).called(1);
      result.fold((_) => fail('expected Right'), (summaries) {
        expect(summaries, hasLength(1));
        expect(summaries.first.paymentStatus, PaymentStatus.partial);
      });
    });
  });

  group('getCaseFinancialSummary', () {
    test(
      'GETs /finance/cases/{id}/summary with nested thin invoices',
      () async {
        when(() => dio.get('/finance/cases/c1/summary')).thenAnswer(
          (_) async => okResponse('/finance/cases/c1/summary', {
            'caseId': 'c1',
            'caseNumber': 'CASE-2026-00001',
            'clientName': 'Carlos Hernandez',
            'totalInvoiced': 15000.0,
            'totalPaid': 10000.0,
            'outstandingBalance': 5000.0,
            'paymentStatus': 'PARTIAL',
            // getCaseFinancialSummary's internal invoice fetch only loads
            // relations: ['payments'] -- no client/case/lineItems.
            'invoices': [
              {
                'id': 'inv1',
                'tenantId': 't1',
                'clientId': 'cl1',
                'invoiceNumber': 'INV-2026-0001',
                'status': 'PARTIAL',
                'issueDate': '2026-01-01',
                'dueDate': '2026-01-31',
                'subtotal': 15000.0,
                'taxTotal': 0.0,
                'grandTotal': 15000.0,
                'createdAt': '2026-01-01T00:00:00.000Z',
                'updatedAt': '2026-01-01T00:00:00.000Z',
                'payments': <Map<String, dynamic>>[],
              },
            ],
          }),
        );

        final result = await repository.getCaseFinancialSummary('c1');

        verify(() => dio.get('/finance/cases/c1/summary')).called(1);
        result.fold((_) => fail('expected Right'), (summary) {
          expect(summary.invoices, hasLength(1));
          // client/caseSummary/lineItems absent in this context -- must not
          // throw, confirming Invoice's all-nullable-relations design.
          expect(summary.invoices.first.client, isNull);
          expect(summary.invoices.first.caseSummary, isNull);
          expect(summary.invoices.first.lineItems, isNull);
        });
      },
    );
  });
}
