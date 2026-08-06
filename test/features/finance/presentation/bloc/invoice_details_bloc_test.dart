import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/finance/domain/entities/invoice.dart';
import 'package:hqooq/features/finance/domain/entities/invoice_status.dart';
import 'package:hqooq/features/finance/domain/repository/i_finance_repository.dart';
import 'package:hqooq/features/finance/presentation/bloc/invoice_details_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements IFinanceRepository {}

void main() {
  late MockFinanceRepository repository;

  final invoice = Invoice(
    id: 'inv1',
    tenantId: 't1',
    clientId: 'cl1',
    invoiceNumber: 'INV-2026-0001',
    status: InvoiceStatus.draft,
    issueDate: DateTime(2026, 1, 1),
    dueDate: DateTime(2026, 1, 31),
    subtotal: 1000,
    taxTotal: 100,
    grandTotal: 1100,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    repository = MockFinanceRepository();
  });

  blocTest<InvoiceDetailsBloc, InvoiceDetailsState>(
    'emits [Loading, Loaded] on a successful GET /finance/invoices/{id}',
    build: () {
      when(
        () => repository.getInvoiceDetails('inv1'),
      ).thenAnswer((_) async => Right(invoice));
      return InvoiceDetailsBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchInvoiceDetailsRequested('inv1')),
    expect: () => [isA<InvoiceDetailsLoading>(), InvoiceDetailsLoaded(invoice)],
  );

  blocTest<InvoiceDetailsBloc, InvoiceDetailsState>(
    'emits [Loading, Error] surfacing isForbidden when the fetch 403s',
    build: () {
      when(
        () => repository.getInvoiceDetails('inv1'),
      ).thenAnswer((_) async => const Left(ForbiddenFailure()));
      return InvoiceDetailsBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchInvoiceDetailsRequested('inv1')),
    expect: () => [
      isA<InvoiceDetailsLoading>(),
      isA<InvoiceDetailsError>().having(
        (s) => s.isForbidden,
        'isForbidden',
        true,
      ),
    ],
  );
}
