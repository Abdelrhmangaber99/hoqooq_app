part of 'case_form_bloc.dart';

abstract class CaseFormState extends Equatable {
  const CaseFormState();

  @override
  List<Object?> get props => [];
}

class CaseFormInitial extends CaseFormState {}

class CaseFormLoading extends CaseFormState {}

/// The form is ready to use — Courts/Users/Clients/case-type Lookups
/// reference data loaded (or degraded to empty on failure). Also carries
/// submission status so the same screen can show a spinner/error without
/// losing the reference data it already has.
class CaseFormReady extends CaseFormState {
  final List<Court> courts;
  final List<User> users;
  final List<Client> clients;
  final List<Lookup> caseTypes;
  final bool isSubmitting;
  final String? submitError;

  const CaseFormReady({
    required this.courts,
    required this.users,
    required this.clients,
    required this.caseTypes,
    this.isSubmitting = false,
    this.submitError,
  });

  CaseFormReady copyWith({bool? isSubmitting, String? submitError}) {
    return CaseFormReady(
      courts: courts,
      users: users,
      clients: clients,
      caseTypes: caseTypes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [
    courts,
    users,
    clients,
    caseTypes,
    isSubmitting,
    submitError,
  ];
}

class CaseFormSuccess extends CaseFormState {
  final LegalCase savedCase;
  const CaseFormSuccess(this.savedCase);

  @override
  List<Object?> get props => [savedCase];
}
