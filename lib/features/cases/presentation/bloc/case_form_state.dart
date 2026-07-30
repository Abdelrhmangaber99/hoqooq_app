part of 'case_form_bloc.dart';

abstract class CaseFormState extends Equatable {
  const CaseFormState();

  @override
  List<Object?> get props => [];
}

class CaseFormInitial extends CaseFormState {}

class CaseFormLoading extends CaseFormState {}

/// The form is ready to use — Courts/Users reference data loaded (or
/// degraded to empty on failure). Also carries submission status so the
/// same screen can show a spinner/error without losing the reference data
/// it already has.
class CaseFormReady extends CaseFormState {
  final List<Court> courts;
  final List<User> users;
  final bool isSubmitting;
  final String? submitError;

  const CaseFormReady({
    required this.courts,
    required this.users,
    this.isSubmitting = false,
    this.submitError,
  });

  CaseFormReady copyWith({bool? isSubmitting, String? submitError}) {
    return CaseFormReady(
      courts: courts,
      users: users,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [courts, users, isSubmitting, submitError];
}

class CaseFormSuccess extends CaseFormState {
  final LegalCase updatedCase;
  const CaseFormSuccess(this.updatedCase);

  @override
  List<Object?> get props => [updatedCase];
}
