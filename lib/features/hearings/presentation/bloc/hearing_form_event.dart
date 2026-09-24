part of 'hearing_form_bloc.dart';

abstract class HearingFormEvent extends Equatable {
  const HearingFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadHearingFormReferenceDataRequested extends HearingFormEvent {
  const LoadHearingFormReferenceDataRequested(
    this.governorateId, {
    this.initialCourtId,
  });
  final String? governorateId;
  final String? initialCourtId;

  @override
  List<Object?> get props => [governorateId, initialCourtId];
}

class LoadHearingCircuitsRequested extends HearingFormEvent {
  const LoadHearingCircuitsRequested(this.courtId);
  final String courtId;

  @override
  List<Object?> get props => [courtId];
}

class CreateHearingSubmitted extends HearingFormEvent {
  final CreateHearingRequest request;
  const CreateHearingSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateHearingSubmitted extends HearingFormEvent {
  final String id;
  final UpdateHearingRequest request;
  const UpdateHearingSubmitted(this.id, this.request);

  @override
  List<Object?> get props => [id, request];
}

class CompleteHearingSubmitted extends HearingFormEvent {
  const CompleteHearingSubmitted(this.id, this.request);
  final String id;
  final CompleteHearingRequest request;

  @override
  List<Object?> get props => [id, request];
}
