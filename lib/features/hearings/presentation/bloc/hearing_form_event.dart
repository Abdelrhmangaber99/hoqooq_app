part of 'hearing_form_bloc.dart';

abstract class HearingFormEvent extends Equatable {
  const HearingFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadHearingFormReferenceDataRequested extends HearingFormEvent {}

class UpdateHearingSubmitted extends HearingFormEvent {
  final String id;
  final UpdateHearingRequest request;
  const UpdateHearingSubmitted(this.id, this.request);

  @override
  List<Object?> get props => [id, request];
}
