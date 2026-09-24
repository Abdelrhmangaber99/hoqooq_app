import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/cases/domain/entities/court.dart';
import 'package:hqooq/features/courts/domain/repository/i_court_repository.dart';
import 'package:hqooq/features/lookups/domain/entities/lookup.dart';
import 'package:hqooq/features/lookups/domain/entities/lookup_kind.dart';
import 'package:hqooq/features/lookups/domain/repository/i_lookup_repository.dart';
import 'package:hqooq/features/service_of_process/data/models/create_service_process_request.dart';
import 'package:hqooq/features/service_of_process/domain/entities/service_process.dart';
import 'package:hqooq/features/service_of_process/domain/entities/service_status.dart';
import 'package:hqooq/features/service_of_process/domain/repository/i_service_process_repository.dart';
import 'package:hqooq/features/service_of_process/presentation/bloc/case_service_process_bloc.dart';
import 'package:hqooq/features/service_of_process/presentation/bloc/service_process_form_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockServiceRepository extends Mock implements IServiceProcessRepository {}

class MockCourtRepository extends Mock implements ICourtRepository {}

class MockLookupRepository extends Mock implements ILookupRepository {}

void main() {
  late MockServiceRepository repository;
  late MockCourtRepository courts;
  late MockLookupRepository lookups;

  final item = ServiceProcess(
    id: 's1',
    caseId: 'c1',
    targetName: 'Recipient',
    serviceMethodId: 'm1',
    scheduledAt: DateTime(2026, 9, 1),
    status: ServiceStatus.scheduled,
    createdAt: DateTime(2026, 8, 17),
    updatedAt: DateTime(2026, 8, 17),
  );
  final court = Court(
    id: 'co1',
    name: 'Cairo Court',
    type: 'FIRST_INSTANCE',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
  final method = Lookup(
    id: 'm1',
    kind: LookupKind.serviceMethod,
    labelEn: 'Personal delivery',
    labelAr: 'تسليم شخصي',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      CreateServiceProcessRequest(
        caseId: 'c1',
        targetName: 'Recipient',
        serviceMethodId: 'm1',
        scheduledAt: DateTime(2026, 9, 1),
      ),
    );
  });

  setUp(() {
    repository = MockServiceRepository();
    courts = MockCourtRepository();
    lookups = MockLookupRepository();
  });

  blocTest<CaseServiceProcessBloc, CaseServiceProcessState>(
    'loads the Case-scoped collection',
    build: () {
      when(
        () => repository.getForCase('c1'),
      ).thenAnswer((_) async => Right([item]));
      return CaseServiceProcessBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseServiceProcessesRequested('c1')),
    expect: () => [
      CaseServiceProcessLoading(),
      CaseServiceProcessLoaded([item]),
    ],
  );

  blocTest<CaseServiceProcessBloc, CaseServiceProcessState>(
    'preserves forbidden failures for the Case Details error view',
    build: () {
      when(
        () => repository.getForCase('c1'),
      ).thenAnswer((_) async => const Left(ForbiddenFailure()));
      return CaseServiceProcessBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseServiceProcessesRequested('c1')),
    expect: () => [
      CaseServiceProcessLoading(),
      isA<CaseServiceProcessError>().having(
        (state) => state.isForbidden,
        'isForbidden',
        isTrue,
      ),
    ],
  );

  blocTest<CaseServiceProcessBloc, CaseServiceProcessState>(
    'cancels then refreshes the retained activity status',
    build: () {
      final cancelled = ServiceProcess(
        id: 's1',
        caseId: 'c1',
        targetName: 'Recipient',
        serviceMethodId: 'm1',
        scheduledAt: DateTime(2026, 9, 1),
        status: ServiceStatus.cancelled,
        createdAt: DateTime(2026, 8, 17),
        updatedAt: DateTime(2026, 8, 18),
      );
      when(
        () => repository.cancel('s1'),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => repository.getForCase('c1'),
      ).thenAnswer((_) async => Right([cancelled]));
      return CaseServiceProcessBloc(repository);
    },
    seed: () => CaseServiceProcessLoaded([item]),
    act: (bloc) =>
        bloc.add(const CancelServiceProcessRequested(id: 's1', caseId: 'c1')),
    expect: () => [
      CaseServiceProcessLoaded([item], cancellingId: 's1'),
      isA<CaseServiceProcessLoaded>().having(
        (state) => state.items.single.status,
        'status',
        ServiceStatus.cancelled,
      ),
    ],
  );

  blocTest<ServiceProcessFormBloc, ServiceProcessFormState>(
    'loads Governorate Courts and global service methods',
    build: () {
      when(
        () => courts.getCourts('g1'),
      ).thenAnswer((_) async => Right([court]));
      when(
        () => lookups.getLookups(kind: LookupKind.serviceMethod),
      ).thenAnswer((_) async => Right([method]));
      return ServiceProcessFormBloc(repository, courts, lookups);
    },
    act: (bloc) => bloc.add(const LoadServiceProcessFormRequested('g1')),
    expect: () => [
      ServiceProcessFormLoading(),
      ServiceProcessFormReady(courts: [court], methods: [method]),
    ],
  );

  blocTest<ServiceProcessFormBloc, ServiceProcessFormState>(
    'submits a Case-bound create request',
    build: () {
      when(
        () => courts.getCourts('g1'),
      ).thenAnswer((_) async => Right([court]));
      when(
        () => lookups.getLookups(kind: LookupKind.serviceMethod),
      ).thenAnswer((_) async => Right([method]));
      when(() => repository.create(any())).thenAnswer((_) async => Right(item));
      return ServiceProcessFormBloc(repository, courts, lookups);
    },
    act: (bloc) async {
      bloc.add(const LoadServiceProcessFormRequested('g1'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(
        CreateServiceProcessSubmitted(
          CreateServiceProcessRequest(
            caseId: 'c1',
            targetName: 'Recipient',
            serviceMethodId: 'm1',
            scheduledAt: DateTime(2026, 9, 1),
          ),
        ),
      );
    },
    expect: () => [
      ServiceProcessFormLoading(),
      ServiceProcessFormReady(courts: [court], methods: [method]),
      ServiceProcessFormReady(
        courts: [court],
        methods: [method],
        isSubmitting: true,
      ),
      ServiceProcessFormSuccess(item),
    ],
  );

  blocTest<ServiceProcessFormBloc, ServiceProcessFormState>(
    'resets isSubmitting on failure and ignores duplicate submission calls while in flight',
    build: () {
      when(() => repository.create(any())).thenAnswer(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return const Left(ServerFailure('Create failed'));
        },
      );
      return ServiceProcessFormBloc(repository, courts, lookups);
    },
    seed: () => ServiceProcessFormReady(courts: [court], methods: [method]),
    wait: const Duration(milliseconds: 50),
    act: (bloc) async {
      final req = CreateServiceProcessSubmitted(
        CreateServiceProcessRequest(
          caseId: 'c1',
          targetName: 'Recipient',
          serviceMethodId: 'm1',
          scheduledAt: DateTime(2026, 9, 1),
        ),
      );
      bloc.add(req);
      bloc.add(req); // duplicate submission while in flight
    },
    expect: () => [
      ServiceProcessFormReady(
        courts: [court],
        methods: [method],
        isSubmitting: true,
      ),
      ServiceProcessFormReady(
        courts: [court],
        methods: [method],
        isSubmitting: false,
        submitError: 'Create failed',
      ),
    ],
  );
}
