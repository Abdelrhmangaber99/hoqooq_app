import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/document_item.dart';
import '../../domain/repository/i_document_repository.dart';

/// Real implementation of [IDocumentRepository] against `GET /documents`
/// and `POST /documents/upload`.
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

  @override
  ApiResult<DocumentItem> uploadDocument({
    required String filePath,
    String? caseId,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        if (caseId != null) 'caseId': caseId,
      });
      final response = await _dio.post(
        '/documents/upload',
        data: formData,
        onSendProgress: onSendProgress,
      );
      return Right(
        DocumentItem.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
