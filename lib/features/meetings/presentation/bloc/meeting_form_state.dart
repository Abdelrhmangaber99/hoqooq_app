part of 'meeting_form_bloc.dart';

sealed class MeetingFormState extends Equatable {
  const MeetingFormState();
  @override
  List<Object?> get props => [];
}

class MeetingFormReady extends MeetingFormState {
  const MeetingFormReady({this.isSubmitting = false, this.submitError});
  final bool isSubmitting;
  final String? submitError;
  @override
  List<Object?> get props => [isSubmitting, submitError];
}

class MeetingFormSuccess extends MeetingFormState {
  const MeetingFormSuccess(this.item);
  final ClientMeeting item;
  @override
  List<Object?> get props => [item];
}
