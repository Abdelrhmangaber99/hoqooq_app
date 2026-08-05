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
    test('GETs /lookups?kind=CASE_TYPE and parses the full shape', () async {
      when(
        () =>
            dio.get('/lookups', queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => okResponse('/lookups', [
          {
            'id': 'lk1',
            'tenantId': 't1',
            'kind': 'CASE_TYPE',
            'labelEn': 'Civil',
            'labelAr': 'مدني',
            'isActive': true,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
        ]),
      );

      final result = await repository.getLookups(kind: LookupKind.caseType);

      verify(
        () => dio.get('/lookups', queryParameters: {'kind': 'CASE_TYPE'}),
      ).called(1);
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

      final result = await repository.getLookups(kind: LookupKind.caseType);

      result.fold(
        (_) => fail('expected Right'),
        (lookups) => expect(lookups.first.kind, LookupKind.unknown),
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

      final result = await repository.getLookups(kind: LookupKind.caseType);

      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
