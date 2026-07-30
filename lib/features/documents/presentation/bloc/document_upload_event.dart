part of 'document_upload_bloc.dart';

abstract class DocumentUploadEvent extends Equatable {
  const DocumentUploadEvent();

  @override
  List<Object?> get props => [];
}

class DocumentUploadRequested extends DocumentUploadEvent {
  final String filePath;
  final String? caseId;

  const DocumentUploadRequested({required this.filePath, this.caseId});

  @override
  List<Object?> get props => [filePath, caseId];
}
