import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
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
import 'package:hqooq/features/courts/domain/repository/i_court_repository.dart';
import 'package:hqooq/features/users/domain/repository/i_user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCaseRepository extends Mock implements ICaseRepository {}

class MockCourtRepository extends Mock implements ICourtRepository {}

class MockUserRepository extends Mock implements IUserRepository {}

void main() {
  late MockCaseRepository caseRepository;
  late MockCourtRepository courtRepository;
  late MockUserRepository userRepository;

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

  final updatedCase = LegalCase(
    id: 'c1',
    tenantId: 't1',
    caseNumber: 'CASE-2026-00001',
    status: CaseStatus.closed,
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
    team: const [],
  );

  setUpAll(() {
    registerFallbackValue(const UpdateCaseRequest());
  });

  setUp(() {
    caseRepository = MockCaseRepository();
    courtRepository = MockCourtRepository();
    userRepository = MockUserRepository();
  });

  CaseFormBloc buildBloc() =>
      CaseFormBloc(caseRepository, courtRepository, userRepository);

  blocTest<CaseFormBloc, CaseFormState>(
    'emits [Loading, Ready] with courts/users on LoadCaseFormReferenceDataRequested',
    build: () {
      when(
        () => courtRepository.getCourts(),
      ).thenAnswer((_) async => Right([court]));
      when(
        () => userRepository.getUsers(),
      ).thenAnswer((_) async => Right([user]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadCaseFormReferenceDataRequested()),
    expect: () => [
      isA<CaseFormLoading>(),
      CaseFormReady(courts: [court], users: [user]),
    ],
  );

  blocTest<CaseFormBloc, CaseFormState>(
    'degrades to empty lists (not a screen failure) when courts/users fail',
    build: () {
      when(
        () => courtRepository.getCourts(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      when(
        () => userRepository.getUsers(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(LoadCaseFormReferenceDataRequested()),
    expect: () => [
      isA<CaseFormLoading>(),
      const CaseFormReady(courts: [], users: []),
    ],
  );

  blocTest<CaseFormBloc, CaseFormState>(
    'emits [Ready(submitting), Success] on a successful update',
    build: () {
      when(
        () => courtRepository.getCourts(),
      ).thenAnswer((_) async => Right([court]));
      when(
        () => userRepository.getUsers(),
      ).thenAnswer((_) async => Right([user]));
      when(
        () => caseRepository.updateCase('c1', any()),
      ).thenAnswer((_) async => Right(updatedCase));
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
      CaseFormReady(courts: [court], users: [user]),
      CaseFormReady(courts: [court], users: [user], isSubmitting: true),
      CaseFormSuccess(updatedCase),
    ],
  );

  blocTest<CaseFormBloc, CaseFormState>(
    'emits a submit error on the Ready state when the update fails',
    build: () {
      when(
        () => courtRepository.getCourts(),
      ).thenAnswer((_) async => const Right([]));
      when(
        () => userRepository.getUsers(),
      ).thenAnswer((_) async => const Right([]));
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
      const CaseFormReady(courts: [], users: []),
      const CaseFormReady(courts: [], users: [], isSubmitting: true),
      const CaseFormReady(courts: [], users: [], submitError: 'bad request'),
    ],
  );
}
