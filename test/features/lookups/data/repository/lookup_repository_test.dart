import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/lookups/data/repository/lookup_repository.dart';
import 'package:hqooq/features/lookups/domain/entities/lookup_kind.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late LookupRepository repository;

  setUp(() {
    dio = MockDio();
    repository = LookupRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  group('getLookups', () {
    test('GETs global case types from the judicial reference route', () async {
      when(() => dio.get('/reference/case-types')).thenAnswer(
        (_) async => okResponse('/reference/case-types', [
          {
            'id': 'lk1',
            'labelEn': 'Civil',
            'labelAr': 'مدني',
            'isActive': true,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
        ]),
      );

      final result = await repository.getLookups(kind: LookupKind.caseType);

      verify(() => dio.get('/reference/case-types')).called(1);
      result.fold((_) => fail('expected Right'), (lookups) {
        expect(lookups, hasLength(1));
        expect(lookups.first.kind, LookupKind.caseType);
        expect(lookups.first.labelEn, 'Civil');
        expect(lookups.first.labelAr, 'مدني');
      });
    });

    test('sends the correct kind query value per LookupKind', () async {
      when(
        () =>
            dio.get('/lookups', queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => okResponse('/lookups', []));

      await repository.getLookups(kind: LookupKind.hearingType);

      verify(
        () => dio.get('/lookups', queryParameters: {'kind': 'HEARING_TYPE'}),
      ).called(1);
    });

    test('falls back to unknown for an unrecognized kind value', () async {
      when(
        () =>
            dio.get('/lookups', queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => okResponse('/lookups', [
          {
            'id': 'lk1',
            'tenantId': 't1',
            'kind': 'SOMETHING_NEW',
            'labelEn': 'Mystery',
            'labelAr': 'غامض',
            'isActive': true,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
        ]),
      );

      final result = await repository.getLookups(kind: LookupKind.hearingType);

      result.fold(
        (_) => fail('expected Right'),
        (lookups) => expect(lookups.first.kind, LookupKind.unknown),
      );
    });

    test('collapses per-tenant duplicate labels into one option, preferring '
        'the global row', () async {
      // The backend's `tenantId: null` filter is dropped by this TypeORM
      // version, so every tenant's copy of a kind comes back alongside
      // the global row — the same Hearing Type repeated N times.
      when(
        () =>
            dio.get('/lookups', queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => okResponse('/lookups', [
          {
            'id': 'tenant-a',
            'tenantId': 'tenant-a',
            'kind': 'HEARING_TYPE',
            'labelEn': 'First Hearing',
            'labelAr': 'جلسة أولى',
            'isActive': true,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
          {
            'id': 'tenant-b',
            'tenantId': 'tenant-b',
            'kind': 'HEARING_TYPE',
            'labelEn': 'First Hearing',
            'labelAr': 'جلسة أولى',
            'isActive': true,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
          {
            'id': 'global',
            'tenantId': null,
            'kind': 'HEARING_TYPE',
            'labelEn': 'First Hearing',
            'labelAr': 'جلسة أولى',
            'isActive': true,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
          {
            'id': 'global-appeal',
            'tenantId': null,
            'kind': 'HEARING_TYPE',
            'labelEn': 'Appeal',
            'labelAr': 'استئناف',
            'isActive': true,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
        ]),
      );

      final result = await repository.getLookups(kind: LookupKind.hearingType);

      result.fold((_) => fail('expected Right'), (lookups) {
        expect(lookups, hasLength(2));
        expect(
          lookups.map((l) => l.labelEn),
          containsAll(<String>['First Hearing', 'Appeal']),
        );
        // The global row wins, so the picker submits a row the endpoint
        // was actually documented to return.
        expect(
          lookups.firstWhere((l) => l.labelEn == 'First Hearing').id,
          'global',
        );
      });
    });

    test('keeps options whose labels differ', () async {
      when(
        () =>
            dio.get('/lookups', queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => okResponse('/lookups', [
          {
            'id': 'g1',
            'tenantId': null,
            'kind': 'HEARING_TYPE',
            'labelEn': 'Pleading',
            'labelAr': 'مرافعة',
            'isActive': true,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
          {
            'id': 't1',
            'tenantId': 'tenant-a',
            'kind': 'HEARING_TYPE',
            'labelEn': 'Firm-specific Pleading',
            'labelAr': 'مرافعة خاصة',
            'isActive': true,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
        ]),
      );

      final result = await repository.getLookups(kind: LookupKind.hearingType);

      result.fold(
        (_) => fail('expected Right'),
        (lookups) => expect(lookups, hasLength(2)),
      );
    });

    test('maps a 401 to UnauthorizedFailure', () async {
      when(
        () =>
            dio.get('/lookups', queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/lookups'),
          response: Response(
            requestOptions: RequestOptions(path: '/lookups'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.getLookups(kind: LookupKind.hearingType);

      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
