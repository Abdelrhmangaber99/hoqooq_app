import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_documents_bloc.dart';
import 'package:hqooq/features/documents/domain/entities/document_item.dart';
import 'package:hqooq/features/documents/domain/entities/downloaded_document.dart';
import 'package:hqooq/features/documents/domain/repository/i_document_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDocumentRepository extends Mock implements IDocumentRepository {}

void main() {
  late MockDocumentRepository repository;

  DocumentItem buildDocument({required String id, String? caseId}) {
    return DocumentItem(
      id: id,
      title: 'Doc-$id.pdf',
      fileType: 'application/pdf',
      sizeBytes: 1024,
      caseId: caseId,
      uploadedById: 'u1',
      versionNumber: 1,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  setUp(() {
    repository = MockDocumentRepository();
  });

  final docForCase1 = buildDocument(id: 'd1', caseId: 'c1');

  blocTest<CaseDocumentsBloc, CaseDocumentsState>(
    'emits [Loading, Loaded] from the backend Case filter',
    build: () {
      when(
        () => repository.getDocuments('c1'),
      ).thenAnswer((_) async => Right([docForCase1]));
      return CaseDocumentsBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseDocumentsRequested('c1')),
    expect: () => [
      isA<CaseDocumentsLoading>(),
      CaseDocumentsLoaded([docForCase1]),
    ],
  );

  blocTest<CaseDocumentsBloc, CaseDocumentsState>(
    'emits [Loading, Error] when the fetch fails',
    build: () {
      when(
        () => repository.getDocuments('c1'),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return CaseDocumentsBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseDocumentsRequested('c1')),
    expect: () => [isA<CaseDocumentsLoading>(), isA<CaseDocumentsError>()],
  );

  blocTest<CaseDocumentsBloc, CaseDocumentsState>(
    'uploads a version and refreshes the active Case list',
    seed: () => CaseDocumentsLoaded([docForCase1]),
    build: () {
      when(
        () => repository.uploadVersion(
          documentId: 'd1',
          filePath: 'new.pdf',
          changeSummary: 'Signed',
        ),
      ).thenAnswer((_) async => Right(docForCase1.copyWith(versionNumber: 2)));
      when(() => repository.getDocuments('c1')).thenAnswer(
        (_) async => Right([docForCase1.copyWith(versionNumber: 2)]),
      );
      return CaseDocumentsBloc(repository);
    },
    act: (bloc) => bloc.add(
      const UploadDocumentVersionRequested(
        documentId: 'd1',
        caseId: 'c1',
        filePath: 'new.pdf',
        changeSummary: 'Signed',
      ),
    ),
    expect: () => [
      isA<CaseDocumentsLoaded>().having(
        (state) => state.actionId,
        'actionId',
        'd1',
      ),
      isA<CaseDocumentsLoaded>().having(
        (state) => state.documents.single.versionNumber,
        'version',
        2,
      ),
    ],
  );

  blocTest<CaseDocumentsBloc, CaseDocumentsState>(
    'returns authorized download bytes to the presentation layer',
    seed: () => CaseDocumentsLoaded([docForCase1]),
    build: () {
      when(() => repository.downloadDocument('d1', 'Doc-d1.pdf')).thenAnswer(
        (_) async => Right(
          DownloadedDocument(
            fileName: 'Doc-d1.pdf',
            bytes: Uint8List.fromList([1, 2, 3]),
          ),
        ),
      );
      return CaseDocumentsBloc(repository);
    },
    act: (bloc) => bloc.add(
      const DownloadDocumentRequested(documentId: 'd1', fileName: 'Doc-d1.pdf'),
    ),
    expect: () => [
      isA<CaseDocumentsLoaded>().having(
        (state) => state.actionId,
        'actionId',
        'd1',
      ),
      isA<CaseDocumentsLoaded>().having(
        (state) => state.downloadedDocument?.bytes,
        'bytes',
        [1, 2, 3],
      ),
    ],
  );

  blocTest<CaseDocumentsBloc, CaseDocumentsState>(
    'archives then refreshes the active list',
    seed: () => CaseDocumentsLoaded([docForCase1]),
    build: () {
      when(
        () => repository.archiveDocument('d1'),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => repository.getDocuments('c1'),
      ).thenAnswer((_) async => const Right([]));
      return CaseDocumentsBloc(repository);
    },
    act: (bloc) => bloc.add(
      const ArchiveDocumentRequested(documentId: 'd1', caseId: 'c1'),
    ),
    expect: () => [
      isA<CaseDocumentsLoaded>().having(
        (state) => state.actionId,
        'actionId',
        'd1',
      ),
      const CaseDocumentsLoaded([]),
    ],
  );
}
