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
import 'package:hqooq/features/cases/presentation/bloc/case_details_bloc.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:mocktail/mocktail.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
  late MockCaseRepository repository;

  final legalCase = LegalCase(
    id: 'c1',
    tenantId: 't1',
    caseNumber: 'CASE-2026-00001',
    status: CaseStatus.active,
    clientId: 'cl1',
    caseTypeId: 'ct1',
    priority: CasePriority.high,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    client: Client(
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
    ),
    primaryLawyerId: 'u1',
    primaryLawyer: User(
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
    ),
    caseType: const CaseTypeLookup(id: 'ct1', name: 'Civil'),
    defaultCourtId: 'co1',
    defaultCourt: Court(
      id: 'co1',
      name: 'District Court',
      type: 'FIRST_INSTANCE',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    team: const [],
  );

  setUp(() {
    repository = MockCaseRepository();
  });

  blocTest<CaseDetailsBloc, CaseDetailsState>(
    'emits [Loading, Loaded] on a successful GET /cases/{id}',
    build: () {
      when(
        () => repository.getCaseDetails('c1'),
      ).thenAnswer((_) async => Right(legalCase));
      return CaseDetailsBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseDetailsRequested('c1')),
    expect: () => [isA<CaseDetailsLoading>(), CaseDetailsLoaded(legalCase)],
  );

  blocTest<CaseDetailsBloc, CaseDetailsState>(
    'emits [Loading, Error] when the fetch fails',
    build: () {
      when(
        () => repository.getCaseDetails('missing'),
      ).thenAnswer((_) async => const Left(ServerFailure('Case not found')));
      return CaseDetailsBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseDetailsRequested('missing')),
    expect: () => [isA<CaseDetailsLoading>(), isA<CaseDetailsError>()],
  );
}
