import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/documents/data/repository/document_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late DocumentRepository repository;

  setUp(() {
    dio = MockDio();
    repository = DocumentRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  // Real shape confirmed from source: DocumentsService.findAll loads
  // relations: ['case'] only -- uploadedBy/category stay ID-only.
  Map<String, dynamic> documentJson({String? caseId = 'c1'}) {
    return {
      'id': 'd1',
      'title': 'Motion.pdf',
      'fileType': 'application/pdf',
      'sizeBytes': 204800,
      'caseId': caseId,
      'case': caseId == null
          ? null
          : {
              'id': 'c1',
              'tenantId': 't1',
              'caseNumber': 'CASE-2026-00001',
              'status': 'ACTIVE',
              'clientId': 'cl1',
              'caseTypeId': 'ct1',
              'priority': 'HIGH',
              'createdAt': '2026-01-01T00:00:00.000Z',
              'updatedAt': '2026-01-01T00:00:00.000Z',
            },
      'uploadedById': 'u1',
      'versionNumber': 1,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
    };
  }

  group('getDocuments', () {
    test('GETs /documents and parses the full shape', () async {
      when(
        () => dio.get('/documents'),
      ).thenAnswer((_) async => okResponse('/documents', [documentJson()]));

      final result = await repository.getDocuments();

      verify(() => dio.get('/documents')).called(1);
      result.fold((_) => fail('expected Right'), (documents) {
        expect(documents, hasLength(1));
        expect(documents.first.title, 'Motion.pdf');
        expect(documents.first.caseId, 'c1');
        expect(documents.first.caseSummary?.caseNumber, 'CASE-2026-00001');
        expect(documents.first.versionNumber, 1);
      });
    });

    test('parses a document with no case (caseId/case both null)', () async {
      when(() => dio.get('/documents')).thenAnswer(
        (_) async => okResponse('/documents', [documentJson(caseId: null)]),
      );

      final result = await repository.getDocuments();

      result.fold((_) => fail('expected Right'), (documents) {
        expect(documents.first.caseId, isNull);
        expect(documents.first.caseSummary, isNull);
      });
    });

    test('maps a 401 to UnauthorizedFailure', () async {
      when(() => dio.get('/documents')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/documents'),
          response: Response(
            requestOptions: RequestOptions(path: '/documents'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.getDocuments();

      result.fold(
        (failure) => expect(failure, isA<UnauthorizedFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('uploadDocument', () {
    late File tempFile;

    setUp(() async {
      tempFile = await File(
        '${Directory.systemTemp.path}/hoqooq_upload_test.pdf',
      ).writeAsBytes([1, 2, 3]);
    });

    tearDown(() async {
      if (await tempFile.exists()) await tempFile.delete();
    });

    test('POSTs current multipart contract with Case and category', () async {
      when(
        () => dio.post(
          '/documents',
          data: any(named: 'data'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer((_) async => okResponse('/documents', documentJson()));

      final result = await repository.uploadDocument(
        filePath: tempFile.path,
        caseId: 'c1',
        categoryId: 'cat1',
      );

      final captured = verify(
        () => dio.post(
          '/documents',
          data: captureAny(named: 'data'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).captured;
      final formData = captured.single as FormData;
      expect(formData.files, hasLength(1));
      expect(formData.files.single.key, 'file');
      final caseIdField = formData.fields.firstWhere((e) => e.key == 'caseId');
      expect(caseIdField.value, 'c1');
      expect(
        formData.fields.firstWhere((e) => e.key == 'categoryId').value,
        'cat1',
      );
      result.fold(
        (_) => fail('expected Right'),
        (document) => expect(document.title, 'Motion.pdf'),
      );
    });

    test('includes paired Service activity link metadata', () async {
      when(
        () => dio.post(
          '/documents',
          data: any(named: 'data'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer((_) async => okResponse('/documents', documentJson()));

      await repository.uploadDocument(
        filePath: tempFile.path,
        caseId: 'c1',
        categoryId: 'cat1',
        linkedEntityType: 'SERVICE',
        linkedEntityId: 's1',
      );

      final captured = verify(
        () => dio.post(
          '/documents',
          data: captureAny(named: 'data'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).captured;
      final formData = captured.single as FormData;
      expect(
        formData.fields.firstWhere((e) => e.key == 'linkedEntityType').value,
        'SERVICE',
      );
      expect(
        formData.fields.firstWhere((e) => e.key == 'linkedEntityId').value,
        's1',
      );
    });

    test('maps a 400 to ValidationFailure', () async {
      when(
        () => dio.post(
          '/documents',
          data: any(named: 'data'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/documents'),
          response: Response(
            requestOptions: RequestOptions(path: '/documents'),
            statusCode: 400,
            data: {'message': 'No file provided'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await repository.uploadDocument(
        filePath: tempFile.path,
        caseId: 'c1',
        categoryId: 'cat1',
      );

      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  test('uploads an immutable new version with an optional summary', () async {
    final tempFile = await File(
      '${Directory.systemTemp.path}/hoqooq_version_test.pdf',
    ).writeAsBytes([1, 2, 3]);
    addTearDown(() async {
      if (await tempFile.exists()) await tempFile.delete();
    });
    when(
      () => dio.post(
        '/documents/d1/versions',
        data: any(named: 'data'),
        onSendProgress: any(named: 'onSendProgress'),
      ),
    ).thenAnswer(
      (_) async => okResponse('/documents/d1/versions', {
        ...documentJson(),
        'versionNumber': 2,
      }),
    );

    final result = await repository.uploadVersion(
      documentId: 'd1',
      filePath: tempFile.path,
      changeSummary: 'Signed copy',
    );

    final formData =
        verify(
              () => dio.post(
                '/documents/d1/versions',
                data: captureAny(named: 'data'),
                onSendProgress: any(named: 'onSendProgress'),
              ),
            ).captured.single
            as FormData;
    expect(formData.files.single.key, 'file');
    expect(
      formData.fields.firstWhere((field) => field.key == 'changeSummary').value,
      'Signed copy',
    );
    result.fold(
      (_) => fail('expected Right'),
      (document) => expect(document.versionNumber, 2),
    );
  });

  test('downloads bytes through the separately authorized endpoint', () async {
    when(
      () => dio.get<List<int>>(
        '/documents/d1/download',
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<List<int>>(
        requestOptions: RequestOptions(path: '/documents/d1/download'),
        data: [37, 80, 68, 70],
        headers: Headers.fromMap({
          'content-disposition': [
            "attachment; filename*=UTF-8''Motion%20Final.pdf",
          ],
        }),
      ),
    );

    final result = await repository.downloadDocument('d1', 'fallback.pdf');

    result.fold((_) => fail('expected Right'), (download) {
      expect(download.fileName, 'Motion Final.pdf');
      expect(download.bytes, [37, 80, 68, 70]);
    });
  });

  test('archives without exposing a physical-delete operation', () async {
    when(
      () => dio.delete('/documents/d1'),
    ).thenAnswer((_) async => okResponse('/documents/d1', null));

    final result = await repository.archiveDocument('d1');

    expect(result.isRight(), isTrue);
    verify(() => dio.delete('/documents/d1')).called(1);
  });
}
