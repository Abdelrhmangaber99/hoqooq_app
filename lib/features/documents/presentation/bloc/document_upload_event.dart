part of 'document_upload_bloc.dart';

abstract class DocumentUploadEvent extends Equatable {
  const DocumentUploadEvent();

  @override
  List<Object?> get props => [];
}

class DocumentUploadRequested extends DocumentUploadEvent {
  final String filePath;
  final String caseId;
  final String categoryId;
  final String? description;
  final String? linkedEntityType;
  final String? linkedEntityId;

  const DocumentUploadRequested({
    required this.filePath,
    required this.caseId,
    required this.categoryId,
    this.description,
    this.linkedEntityType,
    this.linkedEntityId,
  });

  @override
  List<Object?> get props => [
    filePath,
    caseId,
    categoryId,
    description,
    linkedEntityType,
    linkedEntityId,
  ];
}
