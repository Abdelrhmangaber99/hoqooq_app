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
  final bool isSubmitting;
  final String? submitError;

  const HearingFormReady({
    required this.courts,
    this.isSubmitting = false,
    this.submitError,
  });

  HearingFormReady copyWith({bool? isSubmitting, String? submitError}) {
    return HearingFormReady(
      courts: courts,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [courts, isSubmitting, submitError];
}

class HearingFormSuccess extends HearingFormState {
  final Hearing updatedHearing;
  const HearingFormSuccess(this.updatedHearing);

  @override
  List<Object?> get props => [updatedHearing];
}
