part of 'hearing_form_bloc.dart';

abstract class HearingFormState extends Equatable {
  const HearingFormState();

  @override
  List<Object?> get props => [];
}

class HearingFormInitial extends HearingFormState {}

class HearingFormLoading extends HearingFormState {}

class HearingFormReady extends HearingFormState {
  final List<Court> courts;
  final List<Lookup> hearingTypes;
  final List<CourtCircuit> circuits;
  final bool isSubmitting;
  final String? submitError;
  final String? courtLoadError;
  final String? hearingTypeLoadError;

  const HearingFormReady({
    required this.courts,
    required this.hearingTypes,
    this.circuits = const [],
    this.isSubmitting = false,
    this.submitError,
    this.courtLoadError,
    this.hearingTypeLoadError,
  });

  HearingFormReady copyWith({
    List<CourtCircuit>? circuits,
    bool? isSubmitting,
    String? submitError,
  }) {
    return HearingFormReady(
      courts: courts,
      hearingTypes: hearingTypes,
      circuits: circuits ?? this.circuits,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
      courtLoadError: courtLoadError,
      hearingTypeLoadError: hearingTypeLoadError,
    );
  }

  @override
  List<Object?> get props => [
    courts,
    hearingTypes,
    circuits,
    isSubmitting,
    submitError,
    courtLoadError,
    hearingTypeLoadError,
  ];
}

class HearingFormSuccess extends HearingFormState {
  final Hearing savedHearing;
  const HearingFormSuccess(this.savedHearing);

  @override
  List<Object?> get props => [savedHearing];
}
