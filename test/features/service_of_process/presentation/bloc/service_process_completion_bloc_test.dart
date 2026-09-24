import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/documents/domain/repository/i_document_repository.dart';
import 'package:hqooq/features/lookups/domain/entities/lookup.dart';
import 'package:hqooq/features/lookups/domain/entities/lookup_kind.dart';
import 'package:hqooq/features/lookups/domain/repository/i_lookup_repository.dart';
import 'package:hqooq/features/service_of_process/domain/entities/service_process.dart';
import 'package:hqooq/features/service_of_process/domain/entities/service_status.dart';
import 'package:hqooq/features/service_of_process/domain/repository/i_service_process_repository.dart';
import 'package:hqooq/features/service_of_process/presentation/bloc/service_process_completion_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockDocumentRepository extends Mock implements IDocumentRepository {}

class MockServiceRepository extends Mock implements IServiceProcessRepository {}

class MockLookupRepository extends Mock implements ILookupRepository {}

void main() {
  late MockDocumentRepository documentRepository;
  late MockServiceRepository serviceRepository;
  late MockLookupRepository lookupRepository;

  final lookupCategory = Lookup(
    id: 'cat1',
    kind: LookupKind.documentCategory,
    labelEn: 'Service proof',
    labelAr: 'إثبات الإعلان',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final process = ServiceProcess(
    id: 'sp1',
    caseId: 'c1',
    targetName: 'Recipient Name',
    serviceMethodId: 'm1',
    scheduledAt: DateTime(2026, 9, 1),
    status: ServiceStatus.scheduled,
    createdAt: DateTime(2026, 8, 17),
    updatedAt: DateTime(2026, 8, 17),
  );

  setUp(() {
    documentRepository = MockDocumentRepository();
    serviceRepository = MockServiceRepository();
    lookupRepository = MockLookupRepository();
  });

  blocTest<ServiceProcessCompletionBloc, ServiceProcessCompletionState>(
    'loads document category lookups for completion ready state',
    build: () {
      when(
        () => lookupRepository.getLookups(
          kind: LookupKind.documentCategory,
        ),
      ).thenAnswer((_) async => Right([lookupCategory]));
      return ServiceProcessCompletionBloc(
        documentRepository,
        serviceRepository,
        lookupRepository,
      );
    },
    act: (bloc) => bloc.add(LoadServiceCompletionRequested()),
    expect: () => [
      ServiceProcessCompletionLoading(),
      ServiceProcessCompletionReady([lookupCategory]),
    ],
  );

  blocTest<ServiceProcessCompletionBloc, ServiceProcessCompletionState>(
    'resets isSubmitting and emits submitError when document upload fails',
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
      ).thenAnswer(
        (_) async => const Left(ServerFailure('Upload failed: File too large')),
      );
      return ServiceProcessCompletionBloc(
        documentRepository,
        serviceRepository,
        lookupRepository,
      );
    },
    seed: () => ServiceProcessCompletionReady([lookupCategory]),
    act: (bloc) => bloc.add(
      SubmitServiceCompletionRequested(
        process: process,
        filePath: '/tmp/proof.pdf',
        categoryId: 'cat1',
        resultNotes: 'Delivered',
        status: ServiceStatus.completed,
      ),
    ),
    expect: () => [
      ServiceProcessCompletionReady([
        lookupCategory,
      ], isSubmitting: true, progress: 0),
      ServiceProcessCompletionReady([
        lookupCategory,
      ], isSubmitting: false, submitError: 'Upload failed: File too large'),
    ],
  );
}
