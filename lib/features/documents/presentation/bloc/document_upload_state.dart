part of 'document_upload_bloc.dart';

abstract class DocumentUploadState extends Equatable {
  const DocumentUploadState();

  @override
  List<Object?> get props => [];
}

class DocumentUploadInitial extends DocumentUploadState {}

class DocumentUploadInProgress extends DocumentUploadState {
  final double progress;
  const DocumentUploadInProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DocumentUploadSuccess extends DocumentUploadState {
  final DocumentItem document;
  const DocumentUploadSuccess(this.document);

  @override
  List<Object?> get props => [document];
}

class DocumentUploadFailure extends DocumentUploadState {
  final String message;
  const DocumentUploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
