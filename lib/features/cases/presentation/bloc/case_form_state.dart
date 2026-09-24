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
  final List<Governorate> governorates;
  final List<Court> courts;
  final List<CourtCircuit> circuits;
  final List<User> users;
  final List<CaseTypeReference> caseTypes;
  final bool isLoadingCourts;
  final String? courtLoadError;
  final bool isSubmitting;
  final String? submitError;

  const CaseFormReady({
    this.governorates = const [],
    required this.courts,
    this.circuits = const [],
    this.users = const [],
    required this.caseTypes,
    this.isLoadingCourts = false,
    this.courtLoadError,
    this.isSubmitting = false,
    this.submitError,
  });

  CaseFormReady copyWith({
    List<Court>? courts,
    List<CourtCircuit>? circuits,
    bool? isLoadingCourts,
    String? courtLoadError,
    bool? isSubmitting,
    String? submitError,
  }) {
    return CaseFormReady(
      governorates: governorates,
      courts: courts ?? this.courts,
      circuits: circuits ?? this.circuits,
      users: users,
      caseTypes: caseTypes,
      isLoadingCourts: isLoadingCourts ?? this.isLoadingCourts,
      courtLoadError: courtLoadError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [
    governorates,
    courts,
    circuits,
    users,
    caseTypes,
    isLoadingCourts,
    courtLoadError,
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
