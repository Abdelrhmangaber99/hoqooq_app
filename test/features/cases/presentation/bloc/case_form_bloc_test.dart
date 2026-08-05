import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/cases/data/models/create_case_request.dart';
import 'package:hqooq/features/cases/data/models/update_case_request.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/court.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/domain/repository/i_case_repository.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_form_bloc.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:hqooq/features/clients/domain/repository/i_client_repository.dart';
import 'package:hqooq/features/courts/domain/repository/i_court_repository.dart';
import 'package:hqooq/features/lookups/domain/entities/lookup.dart';
import 'package:hqooq/features/lookups/domain/entities/lookup_kind.dart';
import 'package:hqooq/features/lookups/domain/repository/i_lookup_repository.dart';
import 'package:hqooq/features/users/domain/repository/i_user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

class MockCourtRepository extends Mock implements ICourtRepository {}

class MockUserRepository extends Mock implements IUserRepository {}

class MockClientRepository extends Mock implements IClientRepository {}

class MockLookupRepository extends Mock implements ILookupRepository {}

void main() {
  late MockCaseRepository caseRepository;
  late MockCourtRepository courtRepository;
  late MockUserRepository userRepository;
  late MockClientRepository clientRepository;
  late MockLookupRepository lookupRepository;

  final court = Court(
    id: 'co1',
    name: 'District Court',
    type: 'FIRST_INSTANCE',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final user = User(
    id: 'u1',
    email: 'lawyer@firm.com',
    fullName: 'Jane Doe',
    isSuperAdmin: false,
    status: 'ACTIVE',
    mfaEnabled: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    roles: const [],
    tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
  );

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

  final caseType = Lookup(
    id: 'ct1',
    tenantId: 't1',
    kind: LookupKind.caseType,
    labelEn: 'Civil',
    labelAr: 'مدني',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final legalCase = LegalCase(
    id: 'c1',
    tenantId: 't1',
    caseNumber: 'CASE-2026-00001',
    status: CaseStatus.closed,
    clientId: 'cl1',
    caseTypeId: 'ct1',
    priority: CasePriority.high,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    client: client,
    team: const [],
  );

  setUpAll(() {
    registerFallbackValue(const UpdateCaseRequest());
    registerFallbackValue(
      const CreateCaseRequest(caseNumber: '', clientId: '', caseTypeId: ''),
    );
  });

  setUp(() {
    caseRepository = MockCaseRepository();
    courtRepository = MockCourtRepository();
    userRepository = MockUserRepository();
    clientRepository = MockClientRepository();
    lookupRepository = MockLookupRepository();
  });

  CaseFormBloc buildBloc() => CaseFormBloc(
    caseRepository,
    courtRepository,
    userRepository,
    clientRepository,
    lookupRepository,
  );

  void stubReferenceData({
    List<Court> courts = const [],
    List<User> users = const [],
    List<Client> clients = const [],
    List<Lookup> caseTypes = const [],
  }) {
    when(
      () => courtRepository.getCourts(),
    ).thenAnswer((_) async => Right(courts));
    when(() => userRepository.getUsers()).thenAnswer((_) async => Right(users));
    when(
      () => clientRepository.getClients(),
    ).thenAnswer((_) async => Right(clients));
    when(
      () => lookupRepository.getLookups(kind: LookupKind.caseType),
    ).thenAnswer((_) async => Right(caseTypes));
  }

  blocTest<CaseFormBloc, CaseFormState>(
    'emits [Loading, Ready] with courts/users/clients/caseTypes on '
    'LoadCaseFormReferenceDataRequested',
    build: () {
      stubReferenceData(
        courts: [court],
        users: [user],
        clients: [client],
        caseTypes: [caseType],
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadCaseFormReferenceDataRequested()),
    expect: () => [
      isA<CaseFormLoading>(),
      CaseFormReady(
        courts: [court],
        users: [user],
        clients: [client],
        caseTypes: [caseType],
      ),
    ],
  );

  blocTest<CaseFormBloc, CaseFormState>(
    'degrades to empty lists (not a screen failure) when all reference '
    'data fails',
    build: () {
      when(
        () => courtRepository.getCourts(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => userRepository.getUsers(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => clientRepository.getClients(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => lookupRepository.getLookups(kind: LookupKind.caseType),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadCaseFormReferenceDataRequested()),
    expect: () => [
      isA<CaseFormLoading>(),
      const CaseFormReady(courts: [], users: [], clients: [], caseTypes: []),
    ],
  );

  blocTest<CaseFormBloc, CaseFormState>(
    'emits [Ready(submitting), Success] on a successful create',
    build: () {
      stubReferenceData(clients: [client], caseTypes: [caseType]);
      when(
        () => caseRepository.createCase(any()),
      ).thenAnswer((_) async => Right(legalCase));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(LoadCaseFormReferenceDataRequested());
      await Future.delayed(Duration.zero);
      bloc.add(
        const CreateCaseSubmitted(
          CreateCaseRequest(
            caseNumber: 'CASE-2026-00001',
            clientId: 'cl1',
            caseTypeId: 'ct1',
          ),
        ),
      );
    },
    expect: () => [
      isA<CaseFormLoading>(),
      CaseFormReady(
        courts: const [],
        users: const [],
        clients: [client],
        caseTypes: [caseType],
      ),
      CaseFormReady(
        courts: const [],
        users: const [],
        clients: [client],
        caseTypes: [caseType],
        isSubmitting: true,
      ),
      CaseFormSuccess(legalCase),
    ],
  );

  blocTest<CaseFormBloc, CaseFormState>(
    'emits [Ready(submitting), Success] on a successful update',
    build: () {
      stubReferenceData(courts: [court], users: [user]);
      when(
        () => caseRepository.updateCase('c1', any()),
      ).thenAnswer((_) async => Right(legalCase));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(LoadCaseFormReferenceDataRequested());
      await Future.delayed(Duration.zero);
      bloc.add(
        const UpdateCaseSubmitted(
          'c1',
          UpdateCaseRequest(status: CaseStatus.closed),
        ),
      );
    },
    expect: () => [
      isA<CaseFormLoading>(),
      CaseFormReady(
        courts: [court],
        users: [user],
        clients: const [],
        caseTypes: const [],
      ),
      CaseFormReady(
        courts: [court],
        users: [user],
        clients: const [],
        caseTypes: const [],
        isSubmitting: true,
      ),
      CaseFormSuccess(legalCase),
    ],
  );

  blocTest<CaseFormBloc, CaseFormState>(
    'emits a submit error on the Ready state when the update fails',
    build: () {
      stubReferenceData();
      when(
        () => caseRepository.updateCase('c1', any()),
      ).thenAnswer((_) async => const Left(ValidationFailure('bad request')));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(LoadCaseFormReferenceDataRequested());
      await Future.delayed(Duration.zero);
      bloc.add(
        const UpdateCaseSubmitted(
          'c1',
          UpdateCaseRequest(status: CaseStatus.closed),
        ),
      );
    },
    expect: () => [
      isA<CaseFormLoading>(),
      const CaseFormReady(courts: [], users: [], clients: [], caseTypes: []),
      const CaseFormReady(
        courts: [],
        users: [],
        clients: [],
        caseTypes: [],
        isSubmitting: true,
      ),
      const CaseFormReady(
        courts: [],
        users: [],
        clients: [],
        caseTypes: [],
        submitError: 'bad request',
      ),
    ],
  );
}
