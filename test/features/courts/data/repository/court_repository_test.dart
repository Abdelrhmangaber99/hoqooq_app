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

  group('global judicial reference data', () {
    test('GETs governorates and parses localized labels', () async {
      when(() => dio.get('/reference/governorates')).thenAnswer(
        (_) async => okResponse('/reference/governorates', [
          {'id': 'g1', 'nameEn': 'Cairo', 'nameAr': 'القاهرة'},
        ]),
      );

      final result = await repository.getGovernorates();

      verify(() => dio.get('/reference/governorates')).called(1);
      result.fold((_) => fail('expected Right'), (governorates) {
        expect(governorates.single.labelFor('ar'), 'القاهرة');
      });
    });

    test('GETs courts below the selected governorate', () async {
      when(() => dio.get('/reference/governorates/g1/courts')).thenAnswer(
        (_) async => okResponse('/courts', [
          {
            'id': 'co1',
            'nameEn': 'Cairo Court of Appeal',
            'nameAr': 'محكمة استئناف القاهرة',
            'type': 'FIRST_INSTANCE',
            'governorateId': 'g1',
            'isActive': true,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
        ]),
      );

      final result = await repository.getCourts('g1');

      verify(() => dio.get('/reference/governorates/g1/courts')).called(1);
      result.fold((_) => fail('expected Right'), (courts) {
        expect(courts, hasLength(1));
        expect(courts.first.name, 'Cairo Court of Appeal');
        expect(courts.first.isActive, isTrue);
      });
    });

    test('does not request courts before a governorate is selected', () async {
      final result = await repository.getCourts();
      verifyNever(() => dio.get(any()));
      result.fold(
        (_) => fail('expected Right'),
        (courts) => expect(courts, isEmpty),
      );
    });

    test('GETs global case types for v2 Case forms', () async {
      when(() => dio.get('/reference/case-types')).thenAnswer(
        (_) async => okResponse('/reference/case-types', [
          {'id': 'ct1', 'code': 'CIVIL', 'labelEn': 'Civil', 'labelAr': 'مدني'},
        ]),
      );

      final result = await repository.getCaseTypes();

      verify(() => dio.get('/reference/case-types')).called(1);
      result.fold((_) => fail('expected Right'), (caseTypes) {
        expect(caseTypes.single.code, 'CIVIL');
        expect(caseTypes.single.labelFor('ar'), 'مدني');
      });
    });

    test('maps a governorate connection error to NetworkFailure', () async {
      when(() => dio.get('/reference/governorates')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/reference/governorates'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.getGovernorates();

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
