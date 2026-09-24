import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/cases/domain/entities/case_party_snapshot.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/domain/repository/i_case_repository.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_details_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

void main() {
  late MockCaseRepository repository;

  final legalCase = LegalCase(
    id: 'c1',
    tenantId: 't1',
    caseNumber: 'CASE-2026-00001',
    status: CaseStatus.active,
    caseTypeId: 'ct1',
    priority: CasePriority.high,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    clientSnapshot: const CaseClientSnapshot(
      id: 'cl1',
      clientType: 'INDIVIDUAL',
      name: 'Carlos Hernandez',
    ),
    courtName: 'District Court',
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

  blocTest<CaseDetailsBloc, CaseDetailsState>(
    'updates the loaded case after a successful status change',
    build: () {
      final updatedCase = legalCase.copyWith(status: CaseStatus.closed);
      when(
        () => repository.changeCaseStatus('c1', CaseStatus.closed),
      ).thenAnswer((_) async => Right(updatedCase));
      return CaseDetailsBloc(repository);
    },
    seed: () => CaseDetailsLoaded(legalCase),
    act: (bloc) =>
        bloc.add(const ChangeCaseStatusRequested('c1', CaseStatus.closed)),
    expect: () => [
      CaseDetailsLoaded(legalCase, isUpdatingStatus: true),
      CaseDetailsLoaded(legalCase.copyWith(status: CaseStatus.closed)),
    ],
    verify: (_) => verify(
      () => repository.changeCaseStatus('c1', CaseStatus.closed),
    ).called(1),
  );

  blocTest<CaseDetailsBloc, CaseDetailsState>(
    'keeps the loaded case and exposes the error when status change fails',
    build: () {
      when(
        () => repository.changeCaseStatus('c1', CaseStatus.suspended),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('Status change rejected')),
      );
      return CaseDetailsBloc(repository);
    },
    seed: () => CaseDetailsLoaded(legalCase),
    act: (bloc) =>
        bloc.add(const ChangeCaseStatusRequested('c1', CaseStatus.suspended)),
    expect: () => [
      CaseDetailsLoaded(legalCase, isUpdatingStatus: true),
      CaseDetailsLoaded(legalCase, actionError: 'Status change rejected'),
    ],
  );
}
