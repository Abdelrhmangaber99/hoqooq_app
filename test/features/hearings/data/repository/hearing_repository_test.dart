import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/hearings/data/models/update_hearing_request.dart';
import 'package:hqooq/features/hearings/data/models/complete_hearing_request.dart';
import 'package:hqooq/features/hearings/data/repository/hearing_repository.dart';
import 'package:hqooq/features/hearings/domain/entities/hearing_status.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late HearingRepository repository;

  setUp(() {
    dio = MockDio();
    repository = HearingRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  // Real shape confirmed from Hoqooq-main source (API_CONTRACT.md finding
  // I): HearingsService loads relations: ['case', 'court'] -- circuitId/
  // hearingTypeId stay ID-only since circuit/hearingType aren't loaded.
  Map<String, dynamic> hearingJson({String status = 'SCHEDULED'}) {
    return {
      'id': 'h1',
      'caseId': 'c1',
      'case': {
        'id': 'c1',
        'tenantId': 't1',
        'caseNumber': 'CASE-2026-00001',
        'courtCaseNumber': '417',
        'courtCaseYear': 2026,
        'status': 'ACTIVE',
        'clientId': 'cl1',
        'caseTypeId': 'ct1',
        'priority': 'HIGH',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
      },
      'courtId': 'co1',
      'court': {
        'id': 'co1',
        'name': 'District Court',
        'type': 'FIRST_INSTANCE',
        'isActive': true,
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
      },
      'hearingTypeId': 'ht1',
      'scheduledAt': '2026-02-01T09:00:00.000Z',
      'judgeName': 'Judge Smith',
      'status': status,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
    };
  }

  group('getHearings', () {
    test('GETs /hearings and parses the full shape', () async {
      when(
        () => dio.get('/hearings'),
      ).thenAnswer((_) async => okResponse('/hearings', [hearingJson()]));

      final result = await repository.getHearings();

      verify(() => dio.get('/hearings')).called(1);
      result.fold((_) => fail('expected Right'), (hearings) {
        expect(hearings, hasLength(1));
        expect(hearings.first.caseId, 'c1');
        expect(hearings.first.caseSummary?.caseNumber, 'CASE-2026-00001');
        expect(hearings.first.caseSummary?.courtCaseNumber, '417');
        expect(hearings.first.caseSummary?.courtCaseYear, 2026);
        expect(hearings.first.court?.name, 'District Court');
        expect(hearings.first.status, HearingStatus.scheduled);
        expect(hearings.first.judgeName, 'Judge Smith');
      });
    });

    test('falls back to unknown for an unrecognized status', () async {
      when(() => dio.get('/hearings')).thenAnswer(
        (_) async =>
            okResponse('/hearings', [hearingJson(status: 'SOMETHING_NEW')]),
      );

      final result = await repository.getHearings();

      result.fold((_) => fail('expected Right'), (hearings) {
        expect(hearings.first.status, HearingStatus.unknown);
      });
    });

    test('maps a connection error to NetworkFailure', () async {
      when(() => dio.get('/hearings')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/hearings'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.getHearings();

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('updateHearing', () {
    test('PATCHes /hearings/{id} with only the changed fields', () async {
      when(
        () => dio.patch('/hearings/h1', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/hearings/h1', hearingJson()));

      const request = UpdateHearingRequest(status: HearingStatus.completed);
      await repository.updateHearing('h1', request);

      final captured = verify(
        () => dio.patch('/hearings/h1', data: captureAny(named: 'data')),
      ).captured;
      final body = captured.single as Map<String, dynamic>;
      // Only the one changed field -- unset fields are omitted entirely.
      expect(body, {'status': 'COMPLETED'});
    });

    test('maps a 400 to ValidationFailure', () async {
      when(() => dio.patch('/hearings/h1', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/hearings/h1'),
          response: Response(
            requestOptions: RequestOptions(path: '/hearings/h1'),
            statusCode: 400,
            data: {'message': 'scheduledAt must be a valid date'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      const request = UpdateHearingRequest(judgeName: '');
      final result = await repository.updateHearing('h1', request);

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('completeHearing', () {
    test('PATCHes the dedicated completion route with outcome data', () async {
      when(
        () => dio.patch('/hearings/h1/complete', data: any(named: 'data')),
      ).thenAnswer(
        (_) async => okResponse(
          '/hearings/h1/complete',
          hearingJson(status: 'COMPLETED'),
        ),
      );

      const request = CompleteHearingRequest(
        outcomeText:
            'The hearing concluded after submissions and judgment was reserved.',
      );
      final result = await repository.completeHearing('h1', request);

      final body = verify(
        () => dio.patch(
          '/hearings/h1/complete',
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(body['outcomeText'], request.outcomeText);
      result.fold(
        (_) => fail('expected Right'),
        (value) => expect(value.status, HearingStatus.completed),
      );
    });
  });
}
