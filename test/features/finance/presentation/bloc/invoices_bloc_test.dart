import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/finance/domain/entities/invoice.dart';
import 'package:hqooq/features/finance/domain/entities/invoice_status.dart';
import 'package:hqooq/features/finance/domain/repository/i_finance_repository.dart';
import 'package:hqooq/features/finance/presentation/bloc/invoices_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements IFinanceRepository {}

void main() {
  late MockFinanceRepository repository;

  Invoice buildInvoice({
    required String id,
    required String invoiceNumber,
    InvoiceStatus status = InvoiceStatus.draft,
  }) {
    return Invoice(
      id: id,
      tenantId: 't1',
      clientId: 'cl1',
      invoiceNumber: invoiceNumber,
      status: status,
      issueDate: DateTime(2026, 1, 1),
      dueDate: DateTime(2026, 1, 31),
      subtotal: 1000,
      taxTotal: 100,
      grandTotal: 1100,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  setUp(() {
    repository = MockFinanceRepository();
  });

  InvoicesBloc buildBloc() => InvoicesBloc(repository);

  final invoiceA = buildInvoice(
    id: 'inv1',
    invoiceNumber: 'INV-2026-0001',
    status: InvoiceStatus.paid,
  );
  final invoiceB = buildInvoice(
    id: 'inv2',
    invoiceNumber: 'INV-2026-0002',
    status: InvoiceStatus.draft,
  );

  blocTest<InvoicesBloc, InvoicesState>(
    'emits [Loading, Loaded] with all invoices on a successful fetch',
    build: () {
      when(
        () => repository.getInvoices(),
      ).thenAnswer((_) async => Right([invoiceA, invoiceB]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(FetchInvoicesRequested()),
    expect: () => [
      isA<InvoicesLoading>(),
      InvoicesLoaded([invoiceA, invoiceB]),
    ],
  );

  blocTest<InvoicesBloc, InvoicesState>(
    'emits [Loading, Error] when the fetch fails, surfacing isForbidden',
    build: () {
      when(
        () => repository.getInvoices(),
      ).thenAnswer((_) async => const Left(ForbiddenFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(FetchInvoicesRequested()),
    expect: () => [
      isA<InvoicesLoading>(),
      isA<InvoicesError>().having((s) => s.isForbidden, 'isForbidden', true),
    ],
  );

  blocTest<InvoicesBloc, InvoicesState>(
    'filters by status client-side after fetching',
    build: () {
      when(
        () => repository.getInvoices(),
      ).thenAnswer((_) async => Right([invoiceA, invoiceB]));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(FetchInvoicesRequested());
      await Future.delayed(Duration.zero);
      bloc.add(const InvoicesStatusFilterChanged(InvoiceStatus.draft));
    },
    expect: () => [
      isA<InvoicesLoading>(),
      InvoicesLoaded([invoiceA, invoiceB]),
      InvoicesLoaded([invoiceB], statusFilter: InvoiceStatus.draft),
    ],
  );
}
