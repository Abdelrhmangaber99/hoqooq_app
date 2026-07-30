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
import 'package:hqooq/features/cases/domain/usecases/get_cases_use_case.dart';
import 'package:hqooq/features/cases/presentation/bloc/cases_bloc.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:mocktail/mocktail.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
  late MockCaseRepository repository;

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

  LegalCase buildCase({
    required String id,
    required String caseNumber,
    required String clientFullName,
    CaseStatus status = CaseStatus.active,
  }) {
    return LegalCase(
      id: id,
      tenantId: 't1',
      caseNumber: caseNumber,
      status: status,
      clientId: 'cl-$id',
      caseTypeId: 'ct1',
      priority: CasePriority.normal,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      client: Client(
        id: 'cl-$id',
        tenantId: 't1',
        clientCode: 'CLI-$id',
        type: ClientType.individual,
        fullName: clientFullName,
        status: ClientStatus.active,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        emails: const [],
        phones: const [],
        addresses: const [],
      ),
      primaryLawyerId: lawyer.id,
      primaryLawyer: lawyer,
      caseType: const CaseTypeLookup(id: 'ct1', name: 'Civil'),
      defaultCourtId: court.id,
      defaultCourt: court,
      team: const [],
    );
  }

  setUp(() {
    repository = MockCaseRepository();
  });

  CasesBloc buildBloc() => CasesBloc(GetCasesUseCase(repository));

  final caseA = buildCase(
    id: 'c1',
    caseNumber: 'CASE-2026-00001',
    clientFullName: 'Carlos Hernandez',
    status: CaseStatus.active,
  );
  final caseB = buildCase(
    id: 'c2',
    caseNumber: 'CASE-2026-00002',
    clientFullName: 'Patricia Morrison',
    status: CaseStatus.draft,
  );

  blocTest<CasesBloc, CasesState>(
    'emits [Loading, Loaded] with all cases on a successful fetch',
    build: () {
      when(
        () => repository.getCases(),
      ).thenAnswer((_) async => Right([caseA, caseB]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(FetchCasesRequested()),
    expect: () => [
      isA<CasesLoading>(),
      CasesLoaded([caseA, caseB]),
    ],
  );

  blocTest<CasesBloc, CasesState>(
    'emits [Loading, Error] when the fetch fails',
    build: () {
      when(
        () => repository.getCases(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(FetchCasesRequested()),
    expect: () => [isA<CasesLoading>(), isA<CasesError>()],
  );

  blocTest<CasesBloc, CasesState>(
    'filters by status client-side after fetching',
    build: () {
      when(
        () => repository.getCases(),
      ).thenAnswer((_) async => Right([caseA, caseB]));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(FetchCasesRequested());
      await Future.delayed(Duration.zero);
      bloc.add(const CasesStatusFilterChanged(CaseStatus.draft));
    },
    expect: () => [
      isA<CasesLoading>(),
      CasesLoaded([caseA, caseB]),
      CasesLoaded([caseB], statusFilter: CaseStatus.draft),
    ],
  );

  blocTest<CasesBloc, CasesState>(
    'filters by search query (case number or client name) client-side',
    build: () {
      when(
        () => repository.getCases(),
      ).thenAnswer((_) async => Right([caseA, caseB]));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(FetchCasesRequested());
      await Future.delayed(Duration.zero);
      bloc.add(const CasesSearchChanged('morrison'));
    },
    expect: () => [
      isA<CasesLoading>(),
      CasesLoaded([caseA, caseB]),
      CasesLoaded([caseB], searchQuery: 'morrison'),
    ],
  );
}
