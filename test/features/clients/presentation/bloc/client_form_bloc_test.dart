import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/clients/data/models/create_client_request.dart';
import 'package:hqooq/features/clients/data/models/update_client_request.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:hqooq/features/clients/domain/repository/i_client_repository.dart';
import 'package:hqooq/features/clients/presentation/bloc/client_form_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockClientRepository extends Mock implements IClientRepository {}

void main() {
  late MockClientRepository repository;

  final client = Client(
    id: 'cl1',
    tenantId: 't1',
    clientCode: 'CLI-001',
    type: ClientType.individual,
    fullName: 'Carlos Hernandez',
    status: ClientStatus.active,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    emails: const [],
    phones: const [],
    addresses: const [],
  );

  setUpAll(() {
    registerFallbackValue(
      const CreateClientRequest(
        clientCode: '',
        type: ClientType.individual,
        fullName: '',
      ),
    );
    registerFallbackValue(const UpdateClientRequest());
  });

  setUp(() {
    repository = MockClientRepository();
  });

  ClientFormBloc buildBloc() => ClientFormBloc(repository);

  blocTest<ClientFormBloc, ClientFormState>(
    'emits [Submitting, Success] on a successful create',
    build: () {
      when(
        () => repository.createClient(any()),
      ).thenAnswer((_) async => Right(client));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const CreateClientSubmitted(
        CreateClientRequest(
          clientCode: 'CLI-001',
          type: ClientType.individual,
          fullName: 'Carlos Hernandez',
        ),
      ),
    ),
    expect: () => [isA<ClientFormSubmitting>(), ClientFormSuccess(client)],
  );

  blocTest<ClientFormBloc, ClientFormState>(
    'emits [Submitting, Failure] when create fails validation',
    build: () {
      when(() => repository.createClient(any())).thenAnswer(
        (_) async => const Left(ValidationFailure('fullName is required')),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const CreateClientSubmitted(
        CreateClientRequest(
          clientCode: 'CLI-001',
          type: ClientType.individual,
          fullName: '',
        ),
      ),
    ),
    expect: () => [
      isA<ClientFormSubmitting>(),
      const ClientFormFailure('fullName is required'),
    ],
  );

  blocTest<ClientFormBloc, ClientFormState>(
    'emits [Submitting, Success] on a successful update',
    build: () {
      when(
        () => repository.updateClient('cl1', any()),
      ).thenAnswer((_) async => Right(client));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const UpdateClientSubmitted(
        'cl1',
        UpdateClientRequest(fullName: 'Updated Name'),
      ),
    ),
    expect: () => [isA<ClientFormSubmitting>(), ClientFormSuccess(client)],
  );
}
