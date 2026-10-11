import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../domain/entities/document_item.dart';
import '../../domain/entities/downloaded_document.dart';
import '../../domain/repository/i_document_repository.dart';

/// Real implementation of the current `GET|POST /documents` contract.
@LazySingleton(as: IDocumentRepository)
class DocumentRepository implements IDocumentRepository {
  DocumentRepository(this._dio);

  final Dio _dio;

  @override
  ApiResult<List<DocumentItem>> getDocuments([String? caseId]) async {
    try {
      final response = caseId == null
          ? await _dio.get('/documents')
          : await _dio.get('/documents', queryParameters: {'caseId': caseId});
      final data = response.data as List<dynamic>;
      return Right(
        data
            .map((json) => DocumentItem.fromJson(json as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    } catch (_) {
      // A payload that doesn't match the entity shape must fail as an
      // `ApiResult`, never as a thrown exception: an uncaught decode error
      // escapes the calling bloc's event handler before it can emit, which
      // pins the screen on its loading spinner instead of showing an error.
      return const Left(ServerFailure());
    }
  }

  @override
  ApiResult<DocumentItem> uploadDocument({
    required String filePath,
    required String caseId,
    required String categoryId,
    String? description,
    String? linkedEntityType,
    String? linkedEntityId,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'caseId': caseId,
        'categoryId': categoryId,
        if (description != null) 'description': description,
        if (linkedEntityType != null) 'linkedEntityType': linkedEntityType,
        if (linkedEntityId != null) 'linkedEntityId': linkedEntityId,
      });
      final response = await _dio.post(
        '/documents',
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

  @override
  ApiResult<DocumentItem> uploadVersion({
    required String documentId,
    required String filePath,
    String? changeSummary,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        if (changeSummary != null && changeSummary.trim().isNotEmpty)
          'changeSummary': changeSummary.trim(),
      });
      final response = await _dio.post(
        '/documents/$documentId/versions',
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

  @override
  ApiResult<DownloadedDocument> downloadDocument(
    String id,
    String fallbackFileName,
  ) async {
    try {
      final response = await _dio.get<List<int>>(
        '/documents/$id/download',
        options: Options(responseType: ResponseType.bytes),
      );
      final contentDisposition = response.headers.value('content-disposition');
      final encodedName = RegExp(
        "filename\\*=UTF-8''([^;]+)",
      ).firstMatch(contentDisposition ?? '')?.group(1);
      return Right(
        DownloadedDocument(
          fileName: encodedName == null
              ? fallbackFileName
              : Uri.decodeComponent(encodedName),
          bytes: Uint8List.fromList(response.data ?? const <int>[]),
        ),
      );
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }

  @override
  ApiResult<void> archiveDocument(String id) async {
    try {
      await _dio.delete('/documents/$id');
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioError(e));
    }
  }
}
