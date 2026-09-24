import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/cases/data/models/create_case_request.dart';
import 'package:hqooq/features/cases/data/models/update_case_request.dart';
import 'package:hqooq/features/cases/domain/entities/case_party_snapshot.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/domain/repository/i_case_repository.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_form_bloc.dart';
import 'package:hqooq/features/courts/domain/entities/case_type_reference.dart';
import 'package:hqooq/features/courts/domain/entities/governorate.dart';
import 'package:hqooq/features/courts/domain/repository/i_court_repository.dart';
import 'package:hqooq/features/lookups/domain/repository/i_lookup_repository.dart';
import 'package:hqooq/features/users/domain/repository/i_user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

class MockCourtRepository extends Mock implements ICourtRepository {}

class MockUserRepository extends Mock implements IUserRepository {}

class MockLookupRepository extends Mock implements ILookupRepository {}

void main() {
  late MockCaseRepository caseRepository;
  late MockCourtRepository courtRepository;
  late MockUserRepository userRepository;
  late MockLookupRepository lookupRepository;

  const caseType = CaseTypeReference(
    id: 'ct1',
    code: 'CIVIL',
    labelEn: 'Civil',
    labelAr: 'مدني',
  );

  final legalCase = LegalCase(
    id: 'c1',
    tenantId: 't1',
    caseNumber: 'CASE-2026-00001',
    status: CaseStatus.closed,
    caseTypeId: 'ct1',
    priority: CasePriority.high,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    clientSnapshot: const CaseClientSnapshot(
      id: 'cl1',
      clientType: 'INDIVIDUAL',
      name: 'Carlos Hernandez',
    ),
    team: const [],
  );

  setUpAll(() {
    registerFallbackValue(const UpdateCaseRequest());
    registerFallbackValue(
      const CreateCaseRequest(
        caseNumber: '',
        caseTypeId: '',
        client: CaseClientInput(clientType: 'INDIVIDUAL', name: ''),
      ),
    );
  });

  setUp(() {
    caseRepository = MockCaseRepository();
    courtRepository = MockCourtRepository();
    userRepository = MockUserRepository();
    lookupRepository = MockLookupRepository();
  });

  CaseFormBloc buildBloc() => CaseFormBloc(
    caseRepository,
    courtRepository,
    userRepository,
    lookupRepository,
  );

  // `_onLoad` only fetches Governorates and Case Types today — Courts are
  // loaded from Google Places by the form itself after a Governorate is
  // selected, and the `IUserRepository`/`ILookupRepository` constructor
  // params are currently unused/discarded (kept for DI-shape compatibility).
  void stubReferenceData({
    List<Governorate> governorates = const [],
    List<CaseTypeReference> caseTypes = const [],
  }) {
    when(
      () => courtRepository.getGovernorates(),
    ).thenAnswer((_) async => Right(governorates));
    when(
      () => courtRepository.getCaseTypes(),
    ).thenAnswer((_) async => Right(caseTypes));
  }

  blocTest<CaseFormBloc, CaseFormState>(
    'emits [Loading, Ready] with governorates/caseTypes on '
    'LoadCaseFormReferenceDataRequested',
    build: () {
      stubReferenceData(caseTypes: [caseType]);
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadCaseFormReferenceDataRequested()),
    expect: () => [
      isA<CaseFormLoading>(),
      const CaseFormReady(courts: [], caseTypes: [caseType]),
    ],
  );

  blocTest<CaseFormBloc, CaseFormState>(
    'degrades to empty lists (not a screen failure) when reference data '
    'fails',
    build: () {
      when(
        () => courtRepository.getGovernorates(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => courtRepository.getCaseTypes(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadCaseFormReferenceDataRequested()),
    expect: () => [
      isA<CaseFormLoading>(),
      const CaseFormReady(courts: [], caseTypes: []),
    ],
  );

  blocTest<CaseFormBloc, CaseFormState>(
    'emits [Ready(submitting), Success] on a successful create',
    build: () {
      stubReferenceData(caseTypes: [caseType]);
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
            caseTypeId: 'ct1',
            client: CaseClientInput(
              clientType: 'INDIVIDUAL',
              name: 'Carlos Hernandez',
            ),
          ),
        ),
      );
    },
    expect: () => [
      isA<CaseFormLoading>(),
      const CaseFormReady(courts: [], caseTypes: [caseType]),
      const CaseFormReady(
        courts: [],
        caseTypes: [caseType],
        isSubmitting: true,
      ),
      CaseFormSuccess(legalCase),
    ],
  );

  blocTest<CaseFormBloc, CaseFormState>(
    'emits [Ready(submitting), Success] on a successful update',
    build: () {
      stubReferenceData();
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
          UpdateCaseRequest(title: 'Updated title'),
        ),
      );
    },
    expect: () => [
      isA<CaseFormLoading>(),
      const CaseFormReady(courts: [], caseTypes: []),
      const CaseFormReady(courts: [], caseTypes: [], isSubmitting: true),
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
          UpdateCaseRequest(title: 'Updated title'),
        ),
      );
    },
    expect: () => [
      isA<CaseFormLoading>(),
      const CaseFormReady(courts: [], caseTypes: []),
      const CaseFormReady(courts: [], caseTypes: [], isSubmitting: true),
      const CaseFormReady(
        courts: [],
        caseTypes: [],
        submitError: 'bad request',
      ),
    ],
  );
}
