import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/courts/data/repository/court_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late CourtRepository repository;

  setUp(() {
    dio = MockDio();
    repository = CourtRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  group('getCourts', () {
    test('GETs /courts and parses the full shape', () async {
      when(() => dio.get('/courts')).thenAnswer(
        (_) async => okResponse('/courts', [
          {
            'id': 'co1',
            'name': 'District Court',
            'type': 'FIRST_INSTANCE',
            'city': 'New York',
            'address': '123 Main St',
            'isActive': true,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
        ]),
      );

      final result = await repository.getCourts();

      verify(() => dio.get('/courts')).called(1);
      result.fold((_) => fail('expected Right'), (courts) {
        expect(courts, hasLength(1));
        expect(courts.first.name, 'District Court');
        expect(courts.first.isActive, isTrue);
      });
    });

    test('maps a connection error to NetworkFailure', () async {
      when(() => dio.get('/courts')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/courts'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.getCourts();

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
