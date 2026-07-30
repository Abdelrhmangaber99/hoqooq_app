import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/document_item.dart';
import '../../domain/repository/i_document_repository.dart';

/// Real implementation of [IDocumentRepository] against `GET /documents`.
@LazySingleton(as: IDocumentRepository)
class DocumentRepository implements IDocumentRepository {
  DocumentRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<List<DocumentItem>> getDocuments() async {
    try {
      final response = await _dio.get('/documents');
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => DocumentItem.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
