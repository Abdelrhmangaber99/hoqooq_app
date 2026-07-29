import '../../../../core/network/api_result.dart';
import '../entities/client.dart';

abstract class IClientRepository {
  ApiResult<List<Client>> getClients({String? filter});
  ApiResult<Client> getClientDetails(String id);
  ApiResult<Client> createClient(Client client);
}
