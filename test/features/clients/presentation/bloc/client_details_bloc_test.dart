import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/case_type_lookup.dart';
import 'package:hqooq/features/cases/domain/entities/court.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/domain/repository/i_case_repository.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:hqooq/features/clients/domain/repository/i_client_repository.dart';
import 'package:hqooq/features/clients/presentation/bloc/client_details_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockClientRepository extends Mock implements IClientRepository {}

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
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

  final lawyer = User(
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

  final court = Court(
    id: 'co1',
    name: 'District Court',
    type: 'FIRST_INSTANCE',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  LegalCase buildCase(String id, String clientId) {
    return LegalCase(
      id: id,
      tenantId: 't1',
      caseNumber: 'CASE-2026-$id',
      status: CaseStatus.active,
      clientId: clientId,
      caseTypeId: 'ct1',
      priority: CasePriority.normal,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      client: client,
      primaryLawyerId: lawyer.id,
      primaryLawyer: lawyer,
      caseType: const CaseTypeLookup(id: 'ct1', name: 'Civil'),
      defaultCourtId: court.id,
      defaultCourt: court,
      team: const [],
    );
  }

  setUp(() {
    clientRepository = MockClientRepository();
    caseRepository = MockCaseRepository();
  });

  final matchingCase = buildCase('c1', 'cl1');
  final otherCase = buildCase('c2', 'cl2');

  blocTest<ClientDetailsBloc, ClientDetailsState>(
    'emits [Loading, Loaded] with the client and only its own cases '
    '(filtered client-side by clientId, since there is no server-side filter)',
    build: () {
      when(
        () => clientRepository.getClientDetails('cl1'),
      ).thenAnswer((_) async => Right(client));
      when(
        () => caseRepository.getCases(),
      ).thenAnswer((_) async => Right([matchingCase, otherCase]));
      return ClientDetailsBloc(clientRepository, caseRepository);
    },
    act: (bloc) => bloc.add(const FetchClientDetailsRequested('cl1')),
    expect: () => [
      isA<ClientDetailsLoading>(),
      ClientDetailsLoaded(client, [matchingCase]),
    ],
  );

  blocTest<ClientDetailsBloc, ClientDetailsState>(
    'emits [Loading, Error] when the client fetch fails',
    build: () {
      when(
        () => clientRepository.getClientDetails('missing'),
      ).thenAnswer((_) async => const Left(ServerFailure('Not found')));
      return ClientDetailsBloc(clientRepository, caseRepository);
    },
    act: (bloc) => bloc.add(const FetchClientDetailsRequested('missing')),
    expect: () => [isA<ClientDetailsLoading>(), isA<ClientDetailsError>()],
    verify: (_) {
      verifyNever(() => caseRepository.getCases());
    },
  );

  blocTest<ClientDetailsBloc, ClientDetailsState>(
    'shows the client with an empty case list if the cases fetch fails '
    '(a secondary-section failure does not fail the whole screen)',
    build: () {
      when(
        () => clientRepository.getClientDetails('cl1'),
      ).thenAnswer((_) async => Right(client));
      when(
        () => caseRepository.getCases(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return ClientDetailsBloc(clientRepository, caseRepository);
    },
    act: (bloc) => bloc.add(const FetchClientDetailsRequested('cl1')),
    expect: () => [
      isA<ClientDetailsLoading>(),
      ClientDetailsLoaded(client, const []),
    ],
  );
}
