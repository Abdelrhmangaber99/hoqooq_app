import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_documents_bloc.dart';
import 'package:hqooq/features/documents/domain/entities/document_item.dart';
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
  final docForCase2 = buildDocument(id: 'd2', caseId: 'c2');

  blocTest<CaseDocumentsBloc, CaseDocumentsState>(
    'emits [Loading, Loaded] with only this case\'s documents, filtered client-side',
    build: () {
      when(
        () => repository.getDocuments(),
      ).thenAnswer((_) async => Right([docForCase1, docForCase2]));
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
        () => repository.getDocuments(),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return CaseDocumentsBloc(repository);
    },
    act: (bloc) => bloc.add(const FetchCaseDocumentsRequested('c1')),
    expect: () => [isA<CaseDocumentsLoading>(), isA<CaseDocumentsError>()],
  );
}
