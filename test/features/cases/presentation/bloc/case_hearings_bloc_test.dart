import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_hearings_bloc.dart';
import 'package:hqooq/features/hearings/domain/entities/hearing.dart';
import 'package:hqooq/features/hearings/domain/entities/hearing_status.dart';
import 'package:hqooq/features/hearings/domain/repository/i_hearing_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockHearingRepository extends Mock implements IHearingRepository {}

void main() {
  late MockHearingRepository repository;

  Hearing buildHearing({required String id, required String caseId}) {
    return Hearing(
      id: id,
      caseId: caseId,
      courtId: 'co1',
      hearingTypeId: 'ht1',
      scheduledAt: DateTime(2026, 2, 1),
      status: HearingStatus.scheduled,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  setUp(() {
    repository = MockHearingRepository();
  });

  final hearingForCase1 = buildHearing(id: 'h1', caseId: 'c1');
  final hearingForCase2 = buildHearing(id: 'h2', caseId: 'c2');

  blocTest<CaseHearingsBloc, CaseHearingsState>(
    'emits [Loading, Loaded] with only this case\'s hearings, filtered client-side',
    build: () {
      when(
        () => repository.getHearings(),
      ).thenAnswer((_) async => Right([hearingForCase1, hearingForCase2]));
      return CaseHearingsBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseHearingsRequested('c1')),
    expect: () => [
      isA<CaseHearingsLoading>(),
      CaseHearingsLoaded([hearingForCase1]),
    ],
  );

  blocTest<CaseHearingsBloc, CaseHearingsState>(
    'emits [Loading, Error] when the fetch fails',
    build: () {
      when(
        () => repository.getHearings(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return CaseHearingsBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseHearingsRequested('c1')),
    expect: () => [isA<CaseHearingsLoading>(), isA<CaseHearingsError>()],
  );
}
