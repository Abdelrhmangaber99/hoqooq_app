import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/lookup.dart';
import '../../domain/entities/lookup_kind.dart';
import '../../domain/repository/i_lookup_repository.dart';

/// Real implementation of [ILookupRepository] against `GET /lookups`.
@LazySingleton(as: ILookupRepository)
class LookupRepository implements ILookupRepository {
  LookupRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<List<Lookup>> getLookups({required LookupKind kind}) async {
    try {
      final response = await _dio.get(
        '/lookups',
        queryParameters: {'kind': lookupKindWireValue(kind)},
      );
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => Lookup.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
