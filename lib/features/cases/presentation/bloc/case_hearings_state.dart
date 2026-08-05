part of 'case_hearings_bloc.dart';

abstract class CaseHearingsState extends Equatable {
  const CaseHearingsState();

  @override
  List<Object?> get props => [];
}

class CaseHearingsInitial extends CaseHearingsState {}

class CaseHearingsLoading extends CaseHearingsState {}

class CaseHearingsLoaded extends CaseHearingsState {
  final List<Hearing> hearings;
  const CaseHearingsLoaded(this.hearings);

  @override
  List<Object?> get props => [hearings];
}

class CaseHearingsError extends CaseHearingsState {
  final String message;
  final bool isForbidden;
  const CaseHearingsError(this.message, {this.isForbidden = false});

  @override
  List<Object?> get props => [message, isForbidden];
}
