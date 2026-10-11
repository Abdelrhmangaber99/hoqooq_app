import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/service_of_process/data/models/create_service_process_request.dart';
import 'package:hqooq/features/service_of_process/data/models/complete_service_process_request.dart';
import 'package:hqooq/features/service_of_process/data/repository/service_process_repository.dart';
import 'package:hqooq/features/service_of_process/domain/entities/service_status.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late ServiceProcessRepository repository;

  Map<String, dynamic> itemJson({String status = 'SCHEDULED'}) => {
    'id': 's1',
    'caseId': 'c1',
    'courtId': 'co1',
    'court': {
      'id': 'co1',
      'nameEn': 'Cairo Court',
      'type': 'FIRST_INSTANCE',
      'isActive': true,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
    },
    'targetName': 'Recipient Name',
    'serviceMethodId': 'method1',
    'serviceMethod': {
      'id': 'method1',
      'tenantId': null,
      'kind': 'SERVICE_METHOD',
      'labelEn': 'Personal delivery',
      'labelAr': 'تسليم شخصي',
      'isActive': true,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
    },
    'scheduledAt': '2026-09-01T09:00:00.000Z',
    'status': status,
    'createdAt': '2026-08-17T00:00:00.000Z',
    'updatedAt': '2026-08-17T00:00:00.000Z',
  };

  Response<T> response<T>(String path, T data) => Response<T>(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: data,
  );

  setUp(() {
    dio = MockDio();
    repository = ServiceProcessRepository(dio);
  });

  test('loads only the requested Case service activities', () async {
    when(
      () => dio.get('/service-of-process', queryParameters: {'caseId': 'c1'}),
    ).thenAnswer((_) async => response('/service-of-process', [itemJson()]));

    final result = await repository.getForCase('c1');

    result.fold((_) => fail('expected Right'), (items) {
      expect(items, hasLength(1));
      expect(items.single.caseId, 'c1');
      expect(items.single.status, ServiceStatus.scheduled);
      expect(items.single.serviceMethod?.labelEn, 'Personal delivery');
      expect(items.single.serviceMethod?.tenantId, isNull);
    });
  });

  test('creates a Case-bound service activity with required fields', () async {
    when(
      () => dio.post('/service-of-process', data: any(named: 'data')),
    ).thenAnswer((_) async => response('/service-of-process', itemJson()));
    final request = CreateServiceProcessRequest(
      caseId: 'c1',
      targetName: 'Recipient Name',
      serviceMethodId: 'method1',
      scheduledAt: DateTime.utc(2026, 9, 1, 9),
    );

    await repository.create(request);

    final body =
        verify(
              () => dio.post(
                '/service-of-process',
                data: captureAny(named: 'data'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(body['caseId'], 'c1');
    expect(body['targetName'], 'Recipient Name');
    expect(body['serviceMethodId'], 'method1');
    expect(body['scheduledAt'], '2026-09-01T09:00:00.000Z');
  });

  test(
    'completes through the dedicated route with evidence document',
    () async {
      when(
        () => dio.patch(
          '/service-of-process/s1/complete',
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => response(
          '/service-of-process/s1/complete',
          itemJson(status: 'SERVED'),
        ),
      );

      await repository.complete(
        's1',
        const CompleteServiceProcessRequest(
          status: ServiceStatus.completed,
          resultNotes: 'Served and signed.',
        ),
      );

      final body =
          verify(
                () => dio.patch(
                  '/service-of-process/s1/complete',
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(body, {
        'status': 'SERVED',
        'resultNotes': 'Served and signed.',
      });
    },
  );

  test('cancels through DELETE while the server retains history', () async {
    when(
      () => dio.delete('/service-of-process/s1'),
    ).thenAnswer((_) async => response('/service-of-process/s1', null));

    final result = await repository.cancel('s1');

    verify(() => dio.delete('/service-of-process/s1')).called(1);
    result.fold((_) => fail('expected Right'), (_) {});
  });
}
