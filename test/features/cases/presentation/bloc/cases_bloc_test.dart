import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/cases/domain/entities/case_party_snapshot.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/domain/repository/i_case_repository.dart';
import 'package:hqooq/features/cases/domain/usecases/get_cases_use_case.dart';
import 'package:hqooq/features/cases/presentation/bloc/cases_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
  late MockCaseRepository repository;

  LegalCase buildCase({
    required String id,
    required String caseNumber,
    required String clientFullName,
    String courtName = 'District Court',
    CaseStatus status = CaseStatus.active,
  }) {
    return LegalCase(
      id: id,
      tenantId: 't1',
      caseNumber: caseNumber,
      status: status,
      caseTypeId: 'ct1',
      priority: CasePriority.normal,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      clientSnapshot: CaseClientSnapshot(
        id: 'cl-$id',
        clientType: 'INDIVIDUAL',
        name: clientFullName,
      ),
      courtName: courtName,
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
    courtName: 'Alexandria Court of Appeal',
    status: CaseStatus.draft,
  );
  final statusCounts = {
    for (final status in CaseStatus.values)
      status: [caseA, caseB].where((item) => item.status == status).length,
  };

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
      CasesLoaded([caseA, caseB], totalCount: 2, statusCounts: statusCounts),
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
      CasesLoaded([caseA, caseB], totalCount: 2, statusCounts: statusCounts),
      CasesLoaded(
        [caseB],
        statusFilter: CaseStatus.draft,
        totalCount: 2,
        statusCounts: statusCounts,
      ),
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
      CasesLoaded([caseA, caseB], totalCount: 2, statusCounts: statusCounts),
      CasesLoaded(
        [caseB],
        searchQuery: 'morrison',
        totalCount: 2,
        statusCounts: statusCounts,
      ),
    ],
  );

  blocTest<CasesBloc, CasesState>(
    'filters by the stored Google Court name client-side',
    build: () {
      when(
        () => repository.getCases(),
      ).thenAnswer((_) async => Right([caseA, caseB]));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(FetchCasesRequested());
      await Future.delayed(Duration.zero);
      bloc.add(const CasesSearchChanged('alexandria court'));
    },
    expect: () => [
      isA<CasesLoading>(),
      CasesLoaded([caseA, caseB], totalCount: 2, statusCounts: statusCounts),
      CasesLoaded(
        [caseB],
        searchQuery: 'alexandria court',
        totalCount: 2,
        statusCounts: statusCounts,
      ),
    ],
  );
}
