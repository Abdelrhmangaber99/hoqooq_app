import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/cases/data/repository/case_repository.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late CaseRepository repository;

  setUp(() {
    dio = MockDio();
    repository = CaseRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  // Full shape per API_CONTRACT.md §8 (post 2026-07-30 backend rebuild).
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
      'clientId': 'cl1',
      'caseTypeId': 'ct1',
      'priority': priority,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'client': {
        'id': 'cl1',
        'tenantId': 't1',
        'clientCode': 'CLI-001',
        'type': 'INDIVIDUAL',
        'fullName': 'Carlos Hernandez',
        'status': 'ACTIVE',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
        'emails': ['carlos@example.com'],
        'phones': ['+1 555-0100'],
        'addresses': ['88 Canal St'],
      },
      'primaryLawyerId': 'u1',
      'primaryLawyer': {
        'id': 'u1',
        'email': 'lawyer@firm.com',
        'fullName': 'Jane Doe',
        'isSuperAdmin': false,
        'status': 'ACTIVE',
        'mfaEnabled': false,
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
        'roles': <Map<String, dynamic>>[],
        'tenant': {'id': 't1', 'name': 'Reynolds & Associates'},
      },
      'caseType': {'id': 'ct1', 'name': 'Criminal Defense'},
      'defaultCourtId': 'co1',
      'defaultCourt': {
        'id': 'co1',
        'name': 'District Court',
        'type': 'FIRST_INSTANCE',
        'isActive': true,
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
      },
      'openingDate': '2026-01-05T00:00:00.000Z',
      'closingDate': null,
      'outcomeSummary': null,
      'agreedFee': 5000.0,
      'team': <Map<String, dynamic>>[],
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
        expect(cases.first.client.fullName, 'Carlos Hernandez');
        expect(cases.first.primaryLawyer.fullName, 'Jane Doe');
        expect(cases.first.agreedFee, 5000.0);
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
}
