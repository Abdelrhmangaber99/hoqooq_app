import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/clients/data/repository/client_repository.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late ClientRepository repository;

  setUp(() {
    dio = MockDio();
    repository = ClientRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  // Full shape per API_CONTRACT.md §5 (post 2026-07-30 backend rebuild).
  Map<String, dynamic> clientJson({
    String id = 'cl1',
    String type = 'INDIVIDUAL',
    String status = 'ACTIVE',
  }) {
    return {
      'id': id,
      'tenantId': 't1',
      'clientCode': 'CLI-001',
      'type': type,
      'fullName': 'Carlos Hernandez',
      'status': status,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'nationalId': '123456789',
      'commercialReg': null,
      'emails': ['carlos@example.com'],
      'phones': ['+1 555-0100'],
      'addresses': ['88 Canal St, New York, NY'],
    };
  }

  group('getClients', () {
    test('GETs /clients and parses the full shape', () async {
      when(
        () => dio.get('/clients'),
      ).thenAnswer((_) async => okResponse('/clients', [clientJson()]));

      final result = await repository.getClients();

      verify(() => dio.get('/clients')).called(1);
      result.fold((_) => fail('expected Right'), (clients) {
        expect(clients, hasLength(1));
        expect(clients.first.fullName, 'Carlos Hernandez');
        expect(clients.first.type, ClientType.individual);
        expect(clients.first.status, ClientStatus.active);
        expect(clients.first.emails, ['carlos@example.com']);
      });
    });

    test('falls back to unknown for an unrecognized type/status', () async {
      when(() => dio.get('/clients')).thenAnswer(
        (_) async => okResponse('/clients', [
          clientJson(type: 'PARTNERSHIP', status: 'PENDING'),
        ]),
      );

      final result = await repository.getClients();

      result.fold((_) => fail('expected Right'), (clients) {
        expect(clients.first.type, ClientType.unknown);
        expect(clients.first.status, ClientStatus.unknown);
      });
    });

    test('maps a connection error to NetworkFailure', () async {
      when(() => dio.get('/clients')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/clients'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.getClients();

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('getClientDetails', () {
    test('GETs /clients/{id} and parses the full shape', () async {
      when(
        () => dio.get('/clients/cl1'),
      ).thenAnswer((_) async => okResponse('/clients/cl1', clientJson()));

      final result = await repository.getClientDetails('cl1');

      verify(() => dio.get('/clients/cl1')).called(1);
      result.fold(
        (_) => fail('expected Right'),
        (client) => expect(client.id, 'cl1'),
      );
    });
  });
}
