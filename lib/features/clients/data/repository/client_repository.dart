import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../domain/entities/client.dart';
import '../../domain/repository/i_client_repository.dart';
import '../models/create_client_request.dart';
import '../models/update_client_request.dart';

/// Real implementation of [IClientRepository] against `GET /clients` and
/// `GET /clients/{id}` per API_CONTRACT.md §5. Replaces
/// MockClientRepository — no mock is left in the clients path.
///
/// `createClient` reads the current tenant id from [SessionCubit] and
/// injects it into the wire body — `CreateClientDto.tenantId` is required
/// server-side, but no screen/bloc should have to know or supply it.
@LazySingleton(as: IClientRepository)
class ClientRepository implements IClientRepository {
  ClientRepository(this._dio, this._sessionCubit);

  final Dio _dio;
  final SessionCubit _sessionCubit;

  @override
  ApiResult<List<Client>> getClients() async {
    try {
      final response = await _dio.get('/clients');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => Client.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<Client> getClientDetails(String id) async {
    try {
      final response = await _dio.get('/clients/$id');
      return Right(Client.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<Client> createClient(CreateClientRequest request) async {
    try {
      final sessionState = _sessionCubit.state;
      final tenantId = sessionState is SessionAuthenticated
          ? sessionState.user.tenant.id
          : null;
      final body = {
        ...request.toJson(),
        if (tenantId != null) 'tenantId': tenantId,
      };
      final response = await _dio.post('/clients', data: body);
      return Right(Client.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<Client> updateClient(String id, UpdateClientRequest request) async {
    try {
      final response = await _dio.patch('/clients/$id', data: request.toJson());
      return Right(Client.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
