import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/meetings/data/models/meeting_requests.dart';
import 'package:hqooq/features/meetings/data/repository/meeting_repository.dart';
import 'package:hqooq/features/meetings/domain/entities/meeting_status.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late MeetingRepository repository;
  Map<String, dynamic> json({String status = 'SCHEDULED'}) => {
    'id': 'm1',
    'caseId': 'c1',
    'scheduledAt': '2026-09-10T10:00:00.000Z',
    'locationOrMethod': 'Video call',
    'subject': 'Case update',
    'status': status,
    'createdAt': '2026-08-17T00:00:00.000Z',
    'updatedAt': '2026-08-17T00:00:00.000Z',
  };
  Response<T> response<T>(String path, T data) => Response<T>(
    requestOptions: RequestOptions(path: path),
    data: data,
    statusCode: 200,
  );
  setUp(() {
    dio = MockDio();
    repository = MeetingRepository(dio);
  });

  test('loads tenant-visible meetings', () async {
    when(
      () => dio.get('/meetings'),
    ).thenAnswer((_) async => response('/meetings', [json()]));
    final result = await repository.getMeetings();
    result.fold((_) => fail('expected Right'), (items) {
      expect(items.single.caseId, 'c1');
      expect(items.single.status, MeetingStatus.scheduled);
    });
  });

  test('creates a Case-bound meeting', () async {
    when(
      () => dio.post('/meetings', data: any(named: 'data')),
    ).thenAnswer((_) async => response('/meetings', json()));
    await repository.create(
      CreateMeetingRequest(
        caseId: 'c1',
        scheduledAt: DateTime.utc(2026, 9, 10, 10),
        locationOrMethod: 'Video call',
        subject: 'Case update',
      ),
    );
    final body =
        verify(
              () => dio.post('/meetings', data: captureAny(named: 'data')),
            ).captured.single
            as Map<String, dynamic>;
    expect(body['caseId'], 'c1');
    expect(body['subject'], 'Case update');
  });

  test('completes with required outcome notes', () async {
    when(
      () => dio.patch('/meetings/m1/complete', data: any(named: 'data')),
    ).thenAnswer(
      (_) async => response('/meetings/m1/complete', json(status: 'COMPLETED')),
    );
    final result = await repository.complete(
      'm1',
      'Client approved the next steps.',
    );
    verify(
      () => dio.patch(
        '/meetings/m1/complete',
        data: {'outcomeNotes': 'Client approved the next steps.'},
      ),
    ).called(1);
    result.fold(
      (_) => fail('expected Right'),
      (item) => expect(item.status, MeetingStatus.completed),
    );
  });

  test('cancels through retained DELETE workflow', () async {
    when(
      () => dio.delete('/meetings/m1'),
    ).thenAnswer((_) async => response('/meetings/m1', null));
    await repository.cancel('m1');
    verify(() => dio.delete('/meetings/m1')).called(1);
  });
}
