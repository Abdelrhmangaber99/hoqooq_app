part of 'case_team_assignment_bloc.dart';

abstract class CaseTeamAssignmentState extends Equatable {
  const CaseTeamAssignmentState();

  @override
  List<Object?> get props => [];
}

class CaseTeamAssignmentInitial extends CaseTeamAssignmentState {}

class CaseTeamAssignmentLoading extends CaseTeamAssignmentState {}

class CaseTeamAssignmentReady extends CaseTeamAssignmentState {
  final List<User> users;
  final bool isSubmitting;
  final String? submitError;

  const CaseTeamAssignmentReady({
    required this.users,
    this.isSubmitting = false,
    this.submitError,
  });

  CaseTeamAssignmentReady copyWith({bool? isSubmitting, String? submitError}) {
    return CaseTeamAssignmentReady(
      users: users,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [users, isSubmitting, submitError];
}

class CaseTeamAssignmentSuccess extends CaseTeamAssignmentState {
  const CaseTeamAssignmentSuccess();
}
