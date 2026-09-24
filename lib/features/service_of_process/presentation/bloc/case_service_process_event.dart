part of 'case_service_process_bloc.dart';

sealed class CaseServiceProcessEvent extends Equatable {
  const CaseServiceProcessEvent();
  @override
  List<Object?> get props => [];
}

class FetchCaseServiceProcessesRequested extends CaseServiceProcessEvent {
  const FetchCaseServiceProcessesRequested(this.caseId);
  final String caseId;
  @override
  List<Object?> get props => [caseId];
}

class CancelServiceProcessRequested extends CaseServiceProcessEvent {
  const CancelServiceProcessRequested({required this.id, required this.caseId});
  final String id;
  final String caseId;
  @override
  List<Object?> get props => [id, caseId];
}
