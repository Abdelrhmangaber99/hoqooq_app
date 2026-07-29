import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/client.dart';
import '../../domain/repository/i_client_repository.dart';

@LazySingleton(as: IClientRepository)
class MockClientRepository implements IClientRepository {
  @override
  ApiResult<List<Client>> getClients({String? filter}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const Right([
      Client(
        id: '1',
        name: 'Carlos Hernandez',
        email: 'carlos@hernandez.com',
        phone: '+1 (212) 555-0147',
        area: 'Criminal Defense',
        status: 'Active',
        info: '2 cases · Since 2024',
        address: '88 Canal St, New York, NY',
      ),
      Client(
        id: '2',
        name: 'Patricia Morrison',
        email: 'patricia@morrison.com',
        phone: '+1 (212) 555-0150',
        area: 'Estate Planning',
        status: 'Active',
        info: '1 case · Since 2023',
        address: '123 Park Ave, New York, NY',
      ),
    ]);
  }

  @override
  ApiResult<Client> getClientDetails(String id) async {
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  ApiResult<Client> createClient(Client client) async {
    return Right(client);
  }
}
