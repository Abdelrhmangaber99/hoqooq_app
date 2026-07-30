import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/client.dart';
import '../../domain/repository/i_client_repository.dart';

/// Real implementation of [IClientRepository] against `GET /clients` and
/// `GET /clients/{id}` per API_CONTRACT.md §5. Replaces
/// MockClientRepository — no mock is left in the clients path. Read-only
/// for M2.
@LazySingleton(as: IClientRepository)
class ClientRepository implements IClientRepository {
  ClientRepository(this._dio);

  final Dio _dio;

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
}
