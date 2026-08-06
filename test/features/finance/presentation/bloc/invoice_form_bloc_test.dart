import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/domain/repository/i_case_repository.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:hqooq/features/clients/domain/repository/i_client_repository.dart';
import 'package:hqooq/features/finance/data/models/create_invoice_request.dart';
import 'package:hqooq/features/finance/data/models/update_invoice_request.dart';
import 'package:hqooq/features/finance/domain/entities/invoice.dart';
import 'package:hqooq/features/finance/domain/entities/invoice_status.dart';
import 'package:hqooq/features/finance/domain/repository/i_finance_repository.dart';
import 'package:hqooq/features/finance/presentation/bloc/invoice_form_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements IFinanceRepository {}

class MockClientRepository extends Mock implements IClientRepository {}

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
  late MockFinanceRepository financeRepository;
  late MockClientRepository clientRepository;
  late MockCaseRepository caseRepository;

  final client = Client(
    id: 'cl1',
    tenantId: 't1',
    clientCode: 'CLI-001',
    type: ClientType.individual,
    fullName: 'Carlos Hernandez',
    status: ClientStatus.active,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    emails: const [],
    phones: const [],
    addresses: const [],
  );

  final legalCase = LegalCase(
    id: 'c1',
    tenantId: 't1',
    caseNumber: 'CASE-2026-00001',
    status: CaseStatus.active,
    clientId: 'cl1',
    caseTypeId: 'ct1',
    priority: CasePriority.normal,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    client: client,
    team: const [],
  );

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

  setUpAll(() {
    registerFallbackValue(const UpdateInvoiceRequest());
    registerFallbackValue(
      CreateInvoiceRequest(
        clientId: 'cl1',
        invoiceNumber: 'INV-2026-0001',
        subtotal: 1000,
        taxTotal: 100,
        grandTotal: 1100,
        issueDate: DateTime(2026, 1, 1),
        dueDate: DateTime(2026, 1, 31),
      ),
    );
  });

  setUp(() {
    financeRepository = MockFinanceRepository();
    clientRepository = MockClientRepository();
    caseRepository = MockCaseRepository();
  });

  InvoiceFormBloc buildBloc() =>
      InvoiceFormBloc(financeRepository, clientRepository, caseRepository);

  void stubReferenceData({
    List<Client> clients = const [],
    List<LegalCase> cases = const [],
  }) {
    when(
      () => clientRepository.getClients(),
    ).thenAnswer((_) async => Right(clients));
    when(() => caseRepository.getCases()).thenAnswer((_) async => Right(cases));
  }

  blocTest<InvoiceFormBloc, InvoiceFormState>(
    'emits [Loading, Ready] with clients/cases on '
    'LoadInvoiceFormReferenceDataRequested',
    build: () {
      stubReferenceData(clients: [client], cases: [legalCase]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadInvoiceFormReferenceDataRequested()),
    expect: () => [
      isA<InvoiceFormLoading>(),
      InvoiceFormReady(clients: [client], cases: [legalCase]),
    ],
  );

  blocTest<InvoiceFormBloc, InvoiceFormState>(
    'degrades to empty lists (not a screen failure) when reference data '
    'fails',
    build: () {
      when(
        () => clientRepository.getClients(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => caseRepository.getCases(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadInvoiceFormReferenceDataRequested()),
    expect: () => [
      isA<InvoiceFormLoading>(),
      const InvoiceFormReady(clients: [], cases: []),
    ],
  );

  blocTest<InvoiceFormBloc, InvoiceFormState>(
    'emits [Ready(submitting), Success] on a successful create',
    build: () {
      stubReferenceData(clients: [client], cases: [legalCase]);
      when(
        () => financeRepository.createInvoice(any()),
      ).thenAnswer((_) async => Right(invoice));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(LoadInvoiceFormReferenceDataRequested());
      await Future.delayed(Duration.zero);
      bloc.add(
        CreateInvoiceSubmitted(
          CreateInvoiceRequest(
            clientId: 'cl1',
            invoiceNumber: 'INV-2026-0001',
            subtotal: 1000,
            taxTotal: 100,
            grandTotal: 1100,
            issueDate: DateTime(2026, 1, 1),
            dueDate: DateTime(2026, 1, 31),
          ),
        ),
      );
    },
    expect: () => [
      isA<InvoiceFormLoading>(),
      InvoiceFormReady(clients: [client], cases: [legalCase]),
      InvoiceFormReady(
        clients: [client],
        cases: [legalCase],
        isSubmitting: true,
      ),
      InvoiceFormSuccess(invoice),
    ],
  );

  blocTest<InvoiceFormBloc, InvoiceFormState>(
    'emits [Ready(submitting), Success] on a successful update',
    build: () {
      stubReferenceData(clients: [client]);
      when(
        () => financeRepository.updateInvoice('inv1', any()),
      ).thenAnswer((_) async => Right(invoice));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(LoadInvoiceFormReferenceDataRequested());
      await Future.delayed(Duration.zero);
      bloc.add(
        const UpdateInvoiceSubmitted(
          'inv1',
          UpdateInvoiceRequest(status: InvoiceStatus.sent),
        ),
      );
    },
    expect: () => [
      isA<InvoiceFormLoading>(),
      InvoiceFormReady(clients: [client], cases: const []),
      InvoiceFormReady(clients: [client], cases: const [], isSubmitting: true),
      InvoiceFormSuccess(invoice),
    ],
  );

  blocTest<InvoiceFormBloc, InvoiceFormState>(
    'surfaces the failure message without losing reference data on a '
    'failed submit',
    build: () {
      stubReferenceData(clients: [client], cases: [legalCase]);
      when(
        () => financeRepository.createInvoice(any()),
      ).thenAnswer((_) async => const Left(ValidationFailure('bad request')));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(LoadInvoiceFormReferenceDataRequested());
      await Future.delayed(Duration.zero);
      bloc.add(
        CreateInvoiceSubmitted(
          CreateInvoiceRequest(
            clientId: 'cl1',
            invoiceNumber: 'INV-2026-0001',
            subtotal: 1000,
            taxTotal: 100,
            grandTotal: 1100,
            issueDate: DateTime(2026, 1, 1),
            dueDate: DateTime(2026, 1, 31),
          ),
        ),
      );
    },
    expect: () => [
      isA<InvoiceFormLoading>(),
      InvoiceFormReady(clients: [client], cases: [legalCase]),
      InvoiceFormReady(
        clients: [client],
        cases: [legalCase],
        isSubmitting: true,
      ),
      InvoiceFormReady(
        clients: [client],
        cases: [legalCase],
        submitError: 'bad request',
      ),
    ],
  );
}
