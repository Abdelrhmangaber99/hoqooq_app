part of 'case_meetings_bloc.dart';

sealed class CaseMeetingsEvent extends Equatable {
  const CaseMeetingsEvent();
  @override
  List<Object?> get props => [];
}

class FetchCaseMeetingsRequested extends CaseMeetingsEvent {
  const FetchCaseMeetingsRequested(this.caseId);
  final String caseId;
  @override
  List<Object?> get props => [caseId];
}

class CompleteMeetingRequested extends CaseMeetingsEvent {
  const CompleteMeetingRequested({
    required this.id,
    required this.caseId,
    required this.outcomeNotes,
  });
  final String id;
  final String caseId;
  final String outcomeNotes;
  @override
  List<Object?> get props => [id, caseId, outcomeNotes];
}

class CancelMeetingRequested extends CaseMeetingsEvent {
  const CancelMeetingRequested({required this.id, required this.caseId});
  final String id;
  final String caseId;
  @override
  List<Object?> get props => [id, caseId];
}
