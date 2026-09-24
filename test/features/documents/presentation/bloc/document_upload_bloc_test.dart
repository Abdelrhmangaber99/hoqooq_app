import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/documents/domain/entities/document_item.dart';
import 'package:hqooq/features/documents/domain/repository/i_document_repository.dart';
import 'package:hqooq/features/documents/presentation/bloc/document_upload_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockDocumentRepository extends Mock implements IDocumentRepository {}

void main() {
  late MockDocumentRepository documentRepository;

  final document = DocumentItem(
    id: 'd1',
    title: 'Motion.pdf',
    fileType: 'application/pdf',
    sizeBytes: 204800,
    caseId: 'c1',
    uploadedById: 'u1',
    versionNumber: 1,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    documentRepository = MockDocumentRepository();
  });

  blocTest<DocumentUploadBloc, DocumentUploadState>(
    'emits [InProgress, Success] on a successful upload',
    build: () {
      when(
        () => documentRepository.uploadDocument(
          filePath: any(named: 'filePath'),
          caseId: any(named: 'caseId'),
          categoryId: any(named: 'categoryId'),
          description: any(named: 'description'),
          linkedEntityType: any(named: 'linkedEntityType'),
          linkedEntityId: any(named: 'linkedEntityId'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer((_) async => Right(document));
      return DocumentUploadBloc(documentRepository);
    },
    act: (bloc) => bloc.add(
      const DocumentUploadRequested(
        filePath: '/tmp/motion.pdf',
        caseId: 'c1',
        categoryId: 'cat1',
      ),
    ),
    expect: () => [
      const DocumentUploadInProgress(0),
      DocumentUploadSuccess(document),
    ],
  );

  blocTest<DocumentUploadBloc, DocumentUploadState>(
    'emits progress updates reported via onSendProgress',
    build: () {
      when(
        () => documentRepository.uploadDocument(
          filePath: any(named: 'filePath'),
          caseId: any(named: 'caseId'),
          categoryId: any(named: 'categoryId'),
          description: any(named: 'description'),
          linkedEntityType: any(named: 'linkedEntityType'),
          linkedEntityId: any(named: 'linkedEntityId'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer((invocation) async {
        final onSendProgress =
            invocation.namedArguments[#onSendProgress]
                as void Function(int, int)?;
        onSendProgress?.call(50, 100);
        return Right(document);
      });
      return DocumentUploadBloc(documentRepository);
    },
    act: (bloc) => bloc.add(
      const DocumentUploadRequested(
        filePath: '/tmp/motion.pdf',
        caseId: 'c1',
        categoryId: 'cat1',
      ),
    ),
    expect: () => [
      const DocumentUploadInProgress(0),
      const DocumentUploadInProgress(0.5),
      DocumentUploadSuccess(document),
    ],
  );

  blocTest<DocumentUploadBloc, DocumentUploadState>(
    'emits [InProgress, Failure] when the upload fails',
    build: () {
      when(
        () => documentRepository.uploadDocument(
          filePath: any(named: 'filePath'),
          caseId: any(named: 'caseId'),
          categoryId: any(named: 'categoryId'),
          description: any(named: 'description'),
          linkedEntityType: any(named: 'linkedEntityType'),
          linkedEntityId: any(named: 'linkedEntityId'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure()));
      return DocumentUploadBloc(documentRepository);
    },
    act: (bloc) => bloc.add(
      const DocumentUploadRequested(
        filePath: '/tmp/motion.pdf',
        caseId: 'c1',
        categoryId: 'cat1',
      ),
    ),
    expect: () => [
      const DocumentUploadInProgress(0),
      const DocumentUploadFailure('Server error occurred'),
    ],
  );

  blocTest<DocumentUploadBloc, DocumentUploadState>(
    'ignores duplicate upload requests while upload is in progress',
    build: () {
      when(
        () => documentRepository.uploadDocument(
          filePath: any(named: 'filePath'),
          caseId: any(named: 'caseId'),
          categoryId: any(named: 'categoryId'),
          description: any(named: 'description'),
          linkedEntityType: any(named: 'linkedEntityType'),
          linkedEntityId: any(named: 'linkedEntityId'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return Right(document);
      });
      return DocumentUploadBloc(documentRepository);
    },
    wait: const Duration(milliseconds: 50),
    act: (bloc) async {
      const event = DocumentUploadRequested(
        filePath: '/tmp/motion.pdf',
        caseId: 'c1',
        categoryId: 'cat1',
      );
      bloc.add(event);
      bloc.add(event); // duplicate request
    },
    expect: () => [
      const DocumentUploadInProgress(0),
      DocumentUploadSuccess(document),
    ],
  );
}
