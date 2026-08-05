import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/cases/domain/entities/court.dart';
import 'package:hqooq/features/courts/domain/repository/i_court_repository.dart';
import 'package:hqooq/features/hearings/data/models/create_hearing_request.dart';
import 'package:hqooq/features/hearings/data/models/update_hearing_request.dart';
import 'package:hqooq/features/hearings/domain/entities/hearing.dart';
import 'package:hqooq/features/hearings/domain/entities/hearing_status.dart';
import 'package:hqooq/features/hearings/domain/repository/i_hearing_repository.dart';
import 'package:hqooq/features/hearings/presentation/bloc/hearing_form_bloc.dart';
import 'package:hqooq/features/lookups/domain/entities/lookup.dart';
import 'package:hqooq/features/lookups/domain/entities/lookup_kind.dart';
import 'package:hqooq/features/lookups/domain/repository/i_lookup_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockHearingRepository extends Mock implements IHearingRepository {}

class MockCourtRepository extends Mock implements ICourtRepository {}

class MockLookupRepository extends Mock implements ILookupRepository {}

void main() {
  late MockHearingRepository hearingRepository;
  late MockCourtRepository courtRepository;
  late MockLookupRepository lookupRepository;

  final court = Court(
    id: 'co1',
    name: 'District Court',
    type: 'FIRST_INSTANCE',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final hearingType = Lookup(
    id: 'ht1',
    tenantId: 't1',
    kind: LookupKind.hearingType,
    labelEn: 'Preliminary',
    labelAr: 'تمهيدية',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final hearing = Hearing(
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
    registerFallbackValue(
      CreateHearingRequest(
        caseId: 'c1',
        courtId: 'co1',
        hearingTypeId: 'ht1',
        scheduledAt: DateTime(2026, 2, 1),
      ),
    );
  });

  setUp(() {
    hearingRepository = MockHearingRepository();
    courtRepository = MockCourtRepository();
    lookupRepository = MockLookupRepository();
  });

  HearingFormBloc buildBloc() =>
      HearingFormBloc(hearingRepository, courtRepository, lookupRepository);

  void stubReferenceData({
    List<Court> courts = const [],
    List<Lookup> hearingTypes = const [],
  }) {
    when(
      () => courtRepository.getCourts(),
    ).thenAnswer((_) async => Right(courts));
    when(
      () => lookupRepository.getLookups(kind: LookupKind.hearingType),
    ).thenAnswer((_) async => Right(hearingTypes));
  }

  blocTest<HearingFormBloc, HearingFormState>(
    'emits [Loading, Ready] with courts/hearingTypes on '
    'LoadHearingFormReferenceDataRequested',
    build: () {
      stubReferenceData(courts: [court], hearingTypes: [hearingType]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadHearingFormReferenceDataRequested()),
    expect: () => [
      isA<HearingFormLoading>(),
      HearingFormReady(courts: [court], hearingTypes: [hearingType]),
    ],
  );

  blocTest<HearingFormBloc, HearingFormState>(
    'degrades to empty lists (not a screen failure) when reference data '
    'fails',
    build: () {
      when(
        () => courtRepository.getCourts(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => lookupRepository.getLookups(kind: LookupKind.hearingType),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadHearingFormReferenceDataRequested()),
    expect: () => [
      isA<HearingFormLoading>(),
      const HearingFormReady(courts: [], hearingTypes: []),
    ],
  );

  blocTest<HearingFormBloc, HearingFormState>(
    'emits [Ready(submitting), Success] on a successful create',
    build: () {
      stubReferenceData(courts: [court], hearingTypes: [hearingType]);
      when(
        () => hearingRepository.createHearing(any()),
      ).thenAnswer((_) async => Right(hearing));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(LoadHearingFormReferenceDataRequested());
      await Future.delayed(Duration.zero);
      bloc.add(
        CreateHearingSubmitted(
          CreateHearingRequest(
            caseId: 'c1',
            courtId: 'co1',
            hearingTypeId: 'ht1',
            scheduledAt: DateTime(2026, 2, 1),
          ),
        ),
      );
    },
    expect: () => [
      isA<HearingFormLoading>(),
      HearingFormReady(courts: [court], hearingTypes: [hearingType]),
      HearingFormReady(
        courts: [court],
        hearingTypes: [hearingType],
        isSubmitting: true,
      ),
      HearingFormSuccess(hearing),
    ],
  );

  blocTest<HearingFormBloc, HearingFormState>(
    'emits [Ready(submitting), Success] on a successful update '
    '(e.g. "completing" a hearing)',
    build: () {
      stubReferenceData(courts: [court]);
      when(
        () => hearingRepository.updateHearing('h1', any()),
      ).thenAnswer((_) async => Right(hearing));
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
      HearingFormReady(courts: [court], hearingTypes: const []),
      HearingFormReady(
        courts: [court],
        hearingTypes: const [],
        isSubmitting: true,
      ),
      HearingFormSuccess(hearing),
    ],
  );
}
