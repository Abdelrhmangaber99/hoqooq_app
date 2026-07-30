import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/cases/domain/entities/court.dart';
import 'package:hqooq/features/courts/domain/repository/i_court_repository.dart';
import 'package:hqooq/features/hearings/data/models/update_hearing_request.dart';
import 'package:hqooq/features/hearings/domain/entities/hearing.dart';
import 'package:hqooq/features/hearings/domain/entities/hearing_status.dart';
import 'package:hqooq/features/hearings/domain/repository/i_hearing_repository.dart';
import 'package:hqooq/features/hearings/presentation/bloc/hearing_form_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockHearingRepository extends Mock implements IHearingRepository {}

class MockCourtRepository extends Mock implements ICourtRepository {}

void main() {
  late MockHearingRepository hearingRepository;
  late MockCourtRepository courtRepository;

  final court = Court(
    id: 'co1',
    name: 'District Court',
    type: 'FIRST_INSTANCE',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final updatedHearing = Hearing(
    id: 'h1',
    caseId: 'c1',
    courtId: 'co1',
    hearingTypeId: 'ht1',
    scheduledAt: DateTime(2026, 2, 1),
    status: HearingStatus.completed,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(const UpdateHearingRequest());
  });

  setUp(() {
    hearingRepository = MockHearingRepository();
    courtRepository = MockCourtRepository();
  });

  HearingFormBloc buildBloc() =>
      HearingFormBloc(hearingRepository, courtRepository);

  blocTest<HearingFormBloc, HearingFormState>(
    'emits [Loading, Ready] with courts on LoadHearingFormReferenceDataRequested',
    build: () {
      when(
        () => courtRepository.getCourts(),
      ).thenAnswer((_) async => Right([court]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadHearingFormReferenceDataRequested()),
    expect: () => [
      isA<HearingFormLoading>(),
      HearingFormReady(courts: [court]),
    ],
  );

  blocTest<HearingFormBloc, HearingFormState>(
    'degrades to an empty court list (not a screen failure) when courts fail',
    build: () {
      when(
        () => courtRepository.getCourts(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadHearingFormReferenceDataRequested()),
    expect: () => [
      isA<HearingFormLoading>(),
      const HearingFormReady(courts: []),
    ],
  );

  blocTest<HearingFormBloc, HearingFormState>(
    'emits [Ready(submitting), Success] on a successful update '
    '(e.g. "completing" a hearing)',
    build: () {
      when(
        () => courtRepository.getCourts(),
      ).thenAnswer((_) async => Right([court]));
      when(
        () => hearingRepository.updateHearing('h1', any()),
      ).thenAnswer((_) async => Right(updatedHearing));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(LoadHearingFormReferenceDataRequested());
      await Future.delayed(Duration.zero);
      bloc.add(
        const UpdateHearingSubmitted(
          'h1',
          UpdateHearingRequest(status: HearingStatus.completed),
        ),
      );
    },
    expect: () => [
      isA<HearingFormLoading>(),
      HearingFormReady(courts: [court]),
      HearingFormReady(courts: [court], isSubmitting: true),
      HearingFormSuccess(updatedHearing),
    ],
  );
}
