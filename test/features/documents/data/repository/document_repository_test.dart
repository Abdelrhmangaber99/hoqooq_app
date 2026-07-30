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
}
