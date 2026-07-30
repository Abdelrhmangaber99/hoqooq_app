import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/clients/data/models/create_client_request.dart';
import 'package:hqooq/features/clients/data/models/update_client_request.dart';
import 'package:hqooq/features/clients/data/repository/client_repository.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late SessionCubit sessionCubit;
  late ClientRepository repository;

  final user = User(
    id: 'u1',
    email: 'lawyer@firm.com',
    fullName: 'Jane Doe',
    isSuperAdmin: false,
    status: 'ACTIVE',
    mfaEnabled: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    roles: const [],
    tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
  );

  setUp(() {
    dio = MockDio();
    sessionCubit = SessionCubit();
    sessionCubit.authenticated(user, 'token', isFirmAdmin: false);
    repository = ClientRepository(dio, sessionCubit);
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

  group('createClient', () {
    test(
      'POSTs /clients with the request body plus the current tenantId',
      () async {
        when(
          () => dio.post('/clients', data: any(named: 'data')),
        ).thenAnswer((_) async => okResponse('/clients', clientJson()));

        const request = CreateClientRequest(
          clientCode: 'CLI-002',
          type: ClientType.individual,
          fullName: 'New Client',
        );
        await repository.createClient(request);

        final captured = verify(
          () => dio.post('/clients', data: captureAny(named: 'data')),
        ).captured;
        final body = captured.single as Map<String, dynamic>;
        expect(body['clientCode'], 'CLI-002');
        expect(body['type'], 'INDIVIDUAL');
        expect(body['fullName'], 'New Client');
        expect(body['tenantId'], 't1');
        // No extra keys beyond CreateClientDto's whitelisted set + tenantId
        // -- ValidationPipe's forbidNonWhitelisted would 400 on anything
        // else.
        expect(
          body.keys,
          containsAll(['clientCode', 'type', 'fullName', 'tenantId']),
        );
      },
    );

    test('maps a 400 to ValidationFailure', () async {
      when(() => dio.post('/clients', data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/clients'),
          response: Response(
            requestOptions: RequestOptions(path: '/clients'),
            statusCode: 400,
            data: {'message': 'clientCode must be a string'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      const request = CreateClientRequest(
        clientCode: '',
        type: ClientType.individual,
        fullName: 'New Client',
      );
      final result = await repository.createClient(request);

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('updateClient', () {
    test('PATCHes /clients/{id} with only the changed fields', () async {
      when(
        () => dio.patch('/clients/cl1', data: any(named: 'data')),
      ).thenAnswer((_) async => okResponse('/clients/cl1', clientJson()));

      const request = UpdateClientRequest(fullName: 'Updated Name');
      await repository.updateClient('cl1', request);

      final captured = verify(
        () => dio.patch('/clients/cl1', data: captureAny(named: 'data')),
      ).captured;
      final body = captured.single as Map<String, dynamic>;
      // Only the one changed field is present -- unset fields are omitted
      // entirely (not sent as null), so ClientsService.update's merge()
      // can't null out untouched columns.
      expect(body, {'fullName': 'Updated Name'});
    });
  });
}
