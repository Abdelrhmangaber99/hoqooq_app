part of 'meeting_form_bloc.dart';

sealed class MeetingFormEvent extends Equatable {
  const MeetingFormEvent();
  @override
  List<Object?> get props => [];
}

class CreateMeetingSubmitted extends MeetingFormEvent {
  const CreateMeetingSubmitted(this.request);
  final CreateMeetingRequest request;
  @override
  List<Object?> get props => [request];
}

class UpdateMeetingSubmitted extends MeetingFormEvent {
  const UpdateMeetingSubmitted(this.id, this.request);
  final String id;
  final UpdateMeetingRequest request;
  @override
  List<Object?> get props => [id, request];
}
