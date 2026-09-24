import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/cases/data/models/assign_case_request.dart';
import 'package:hqooq/features/cases/data/models/create_case_request.dart';
import 'package:hqooq/features/cases/data/models/update_case_request.dart';
import 'package:hqooq/features/cases/data/repository/case_repository.dart';
import 'package:hqooq/features/cases/domain/entities/case_access_level.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late SessionCubit sessionCubit;
  late CaseRepository repository;

  final user = User(
    id: 'u1',
    email: 'lawyer@firm.com',
    fullName: 'Jane Doe',
    isSuperAdmin: false,
    status: 'ACTIVE',
    mfaEnabled: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
  );

  setUp(() {
    dio = MockDio();
    sessionCubit = SessionCubit();
    sessionCubit.authenticated(user, 'token', isFirmAdmin: false);
    repository = CaseRepository(dio, sessionCubit);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  // Full shape actually returned by the real backend (verified from source):
  // CasesController never applies plainToInstance/ClassSerializerInterceptor,
  // so the wire shape is governed by CasesService's query builder joins
  // (client snapshots, team, team.user, opponents, timelineEvents), not
  // by the (also never-enforced) CaseResponseDto. `caseType` is NOT among
  // them and is never returned by a real server, despite `caseTypeId`
  // always being present. `primaryLawyer`/`primaryLawyerId` no longer exist
  // on the entity at all (API_CONTRACT.md finding N, 2026-08-05) — not
  // modeled here. `team[]` entries carry `userId`/`accessLevel` (not
  // `roleOnCase` — see finding O) and, since `team.user` is now joined, a
  // nested `user` object too.
  Map<String, dynamic> caseJson({
    String id = 'c1',
    String status = 'ACTIVE',
    String priority = 'HIGH',
  }) {
    return {
      'id': id,
      'tenantId': 't1',
      'caseNumber': 'CASE-2026-00001',
      'status': status,
      'caseTypeId': 'ct1',
      'priority': priority,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'clientSnapshot': {
        'id': 'cl1',
        'clientType': 'INDIVIDUAL',
        'name': 'Carlos Hernandez',
        'phone': '+1 555-0100',
        'email': 'carlos@example.com',
        'address': '88 Canal St',
      },
      'courtName': 'District Court',
      'openingDate': '2026-01-05T00:00:00.000Z',
      'closingDate': null,
      'outcomeSummary': null,
      'agreedFee': 5000.0,
      'team': [
        {
          'id': 'ct-1',
          'userId': 'u2',
          'accessLevel': 'FULL_ACCESS',
          'user': {
            'id': 'u2',
            'email': 'lead@firm.com',
            'fullName': 'Lead Lawyer',
            'isSuperAdmin': false,
            'status': 'ACTIVE',
            'mfaEnabled': false,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
            'roles': <Map<String, dynamic>>[],
            'tenant': {'id': 't1', 'name': 'Reynolds & Associates'},
          },
        },
      ],
    };
  }

  group('getCases', () {
    test('GETs /cases and parses the full shape', () async {
      when(
        () => dio.get('/cases'),
      ).thenAnswer((_) async => okResponse('/cases', [caseJson()]));

      final result = await repository.getCases();

      verify(() => dio.get('/cases')).called(1);
      result.fold((_) => fail('expected Right'), (cases) {
        expect(cases, hasLength(1));
        expect(cases.first.caseNumber, 'CASE-2026-00001');
        expect(cases.first.status, CaseStatus.active);
        expect(cases.first.priority, CasePriority.high);
        expect(cases.first.clientSnapshot?.name, 'Carlos Hernandez');
        // caseType is never returned by the real backend (not in
        // CasesService's query builder joins) — must parse to null, not
        // throw. primaryLawyer no longer exists on the model at all.
        expect(cases.first.caseType, isNull);
        // team[] carries userId/accessLevel and, since team.user is now
        // joined, a nested user object too.
        expect(cases.first.team, hasLength(1));
        expect(cases.first.team.first.userId, 'u2');
        expect(cases.first.team.first.accessLevel, CaseAccessLevel.fullAccess);
        expect(cases.first.team.first.user?.fullName, 'Lead Lawyer');
      });
    });

    test('falls back to unknown for an unrecognized status/priority', () async {
      when(() => dio.get('/cases')).thenAnswer(
        (_) async => okResponse('/cases', [
          caseJson(status: 'SOMETHING_NEW', priority: 'SOMETHING_ELSE'),
        ]),
      );

      final result = await repository.getCases();

      result.fold((_) => fail('expected Right'), (cases) {
        expect(cases.first.status, CaseStatus.unknown);
        expect(cases.first.priority, CasePriority.unknown);
      });
    });

    test('maps a 401 to UnauthorizedFailure', () async {
      when(() => dio.get('/cases')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/cases'),
          response: Response(
            requestOptions: RequestOptions(path: '/cases'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.getCases();

      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('getCaseDetails', () {
    test('GETs /cases/{id} and parses the full shape', () async {
      when(
        () => dio.get('/cases/c1'),
      ).thenAnswer((_) async => okResponse('/cases/c1', caseJson()));

      final result = await repository.getCaseDetails('c1');

      verify(() => dio.get('/cases/c1')).called(1);
      result.fold(
        (_) => fail('expected Right'),
        (legalCase) => expect(legalCase.id, 'c1'),
      );
    });
  });

  group('updateCase', () {
    test('PATCHes /cases/{id} with only the changed fields', () async {
      when(
        () => dio.patch('/cases/c1', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/cases/c1', caseJson()));

      const request = UpdateCaseRequest(title: 'Updated title');
      await repository.updateCase('c1', request);

      final captured = verify(
        () => dio.patch('/cases/c1', data: captureAny(named: 'data')),
      ).captured;
      final body = captured.single as Map<String, dynamic>;
      // Only the one changed field -- unset fields are omitted entirely
      // (not sent as null), so CasesService.update's merge() can't null
      // out untouched columns.
      expect(body, {'title': 'Updated title'});
    });

    test('maps a 400 to ValidationFailure', () async {
      when(() => dio.patch('/cases/c1', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/cases/c1'),
          response: Response(
            requestOptions: RequestOptions(path: '/cases/c1'),
            statusCode: 400,
            data: {'message': 'agreedFee must be a number'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      const request = UpdateCaseRequest();
      final result = await repository.updateCase('c1', request);

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('createCase', () {
    test(
      'POSTs /cases with the authenticated tenant and v2 DTO body',
      () async {
        when(
          () => dio.post('/cases', data: any(named: 'data')),
        ).thenAnswer((_) async => okResponse('/cases', caseJson()));

        const request = CreateCaseRequest(
          caseNumber: 'CASE-2026-00002',
          caseTypeId: 'ct1',
          client: CaseClientInput(
            clientType: 'INDIVIDUAL',
            name: 'Carlos Hernandez',
          ),
        );
        final result = await repository.createCase(request);

        final captured = verify(
          () => dio.post('/cases', data: captureAny(named: 'data')),
        ).captured;
        final body = captured.single as Map<String, dynamic>;
        expect(body['caseNumber'], 'CASE-2026-00002');
        expect(body['client']['name'], 'Carlos Hernandez');
        expect(body['caseTypeId'], 'ct1');
        expect(body.containsKey('tenantId'), isFalse);
        expect(body.containsKey('title'), isFalse);
        expect(body.containsKey('client'), isTrue);
        result.fold(
          (_) => fail('expected Right'),
          (legalCase) => expect(legalCase.id, 'c1'),
        );
      },
    );

    test('maps a 400 to ValidationFailure', () async {
      when(() => dio.post('/cases', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/cases'),
          response: Response(
            requestOptions: RequestOptions(path: '/cases'),
            statusCode: 400,
            data: {'message': 'caseTypeId should not be empty'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      const request = CreateCaseRequest(
        caseNumber: 'CASE-2026-00002',
        caseTypeId: '',
        client: CaseClientInput(clientType: 'INDIVIDUAL', name: 'Client'),
      );
      final result = await repository.createCase(request);

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('setCaseAccess', () {
    test('PUTs the v2 access grant capabilities', () async {
      when(
        () => dio.put('/cases/c1/access-grants/u3', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/cases/c1/access-grants/u3', {}));

      const request = AssignCaseRequest(
        userId: 'u3',
        capabilities: ['case.view'],
      );
      final result = await repository.setCaseAccess('c1', request);

      final captured = verify(
        () => dio.put(
          '/cases/c1/access-grants/u3',
          data: captureAny(named: 'data'),
        ),
      ).captured;
      expect(captured.single, {
        'capabilities': ['case.view'],
      });
      result.fold((_) => fail('expected Right'), (_) => expect(true, isTrue));
    });

    test(
      'maps a 403 to ForbiddenFailure (no FULL_ACCESS/firm-admin)',
      () async {
        when(
          () => dio.put('/cases/c1/access-grants/u3', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/cases/c1/access-grants/u3'),
            response: Response(
              requestOptions: RequestOptions(
                path: '/cases/c1/access-grants/u3',
              ),
              statusCode: 403,
              data: {'message': 'Only firm admin or case managers can assign.'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        const request = AssignCaseRequest(
          userId: 'u3',
          capabilities: ['case.view'],
        );
        final result = await repository.setCaseAccess('c1', request);

        result.fold(
          (failure) => expect(failure, isA<ForbiddenFailure>()),
          (_) => fail('expected Left'),
        );
      },
    );
  });

  group('revokeCaseAccess', () {
    test('DELETEs every capability for the selected Employee', () async {
      when(
        () => dio.delete('/cases/c1/access-grants/u3'),
      ).thenAnswer((_) async => okResponse('/cases/c1/access-grants/u3', {}));

      final result = await repository.revokeCaseAccess('c1', 'u3');

      verify(() => dio.delete('/cases/c1/access-grants/u3')).called(1);
      result.fold((_) => fail('expected Right'), (_) => expect(true, isTrue));
    });
  });
}
