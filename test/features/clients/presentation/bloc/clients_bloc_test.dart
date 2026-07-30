import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:hqooq/features/clients/domain/repository/i_client_repository.dart';
import 'package:hqooq/features/clients/domain/usecases/get_clients_use_case.dart';
import 'package:hqooq/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockClientRepository extends Mock implements IClientRepository {}

void main() {
  late MockClientRepository repository;

  Client buildClient({
    required String id,
    required String fullName,
    ClientStatus status = ClientStatus.active,
    List<String> emails = const [],
  }) {
    return Client(
      id: id,
      tenantId: 't1',
      clientCode: 'CLI-$id',
      type: ClientType.individual,
      fullName: fullName,
      status: status,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      emails: emails,
      phones: const [],
      addresses: const [],
    );
  }

  setUp(() {
    repository = MockClientRepository();
  });

  ClientsBloc buildBloc() => ClientsBloc(GetClientsUseCase(repository));

  final clientA = buildClient(
    id: 'cl1',
    fullName: 'Carlos Hernandez',
    status: ClientStatus.active,
    emails: const ['carlos@example.com'],
  );
  final clientB = buildClient(
    id: 'cl2',
    fullName: 'Patricia Morrison',
    status: ClientStatus.inactive,
    emails: const ['patricia@example.com'],
  );

  blocTest<ClientsBloc, ClientsState>(
    'emits [Loading, Loaded] with all clients on a successful fetch',
    build: () {
      when(
        () => repository.getClients(),
      ).thenAnswer((_) async => Right([clientA, clientB]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(FetchClientsRequested()),
    expect: () => [
      isA<ClientsLoading>(),
      ClientsLoaded([clientA, clientB]),
    ],
  );

  blocTest<ClientsBloc, ClientsState>(
    'emits [Loading, Error] when the fetch fails',
    build: () {
      when(
        () => repository.getClients(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return buildBloc();
    },
    act: (bloc) => bloc.add(FetchClientsRequested()),
    expect: () => [isA<ClientsLoading>(), isA<ClientsError>()],
  );

  blocTest<ClientsBloc, ClientsState>(
    'filters by status client-side after fetching',
    build: () {
      when(
        () => repository.getClients(),
      ).thenAnswer((_) async => Right([clientA, clientB]));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(FetchClientsRequested());
      await Future.delayed(Duration.zero);
      bloc.add(const ClientsStatusFilterChanged(ClientStatus.inactive));
    },
    expect: () => [
      isA<ClientsLoading>(),
      ClientsLoaded([clientA, clientB]),
      ClientsLoaded([clientB], statusFilter: ClientStatus.inactive),
    ],
  );

  blocTest<ClientsBloc, ClientsState>(
    'filters by search query (name or email) client-side',
    build: () {
      when(
        () => repository.getClients(),
      ).thenAnswer((_) async => Right([clientA, clientB]));
      return buildBloc();
    },
    act: (bloc) async {
      bloc.add(FetchClientsRequested());
      await Future.delayed(Duration.zero);
      bloc.add(const ClientsSearchChanged('morrison'));
    },
    expect: () => [
      isA<ClientsLoading>(),
      ClientsLoaded([clientA, clientB]),
      ClientsLoaded([clientB], searchQuery: 'morrison'),
    ],
  );
}
