import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../entities/client.dart';
import '../repository/i_client_repository.dart';

@lazySingleton
class GetClientsUseCase {
  final IClientRepository repository;

  GetClientsUseCase(this.repository);

  ApiResult<List<Client>> execute() {
    return repository.getClients();
  }
}
