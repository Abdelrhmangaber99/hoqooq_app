part of 'case_details_bloc.dart';

abstract class CaseDetailsState extends Equatable {
  const CaseDetailsState();

  @override
  List<Object?> get props => [];
}

class CaseDetailsInitial extends CaseDetailsState {}

class CaseDetailsLoading extends CaseDetailsState {}

class CaseDetailsLoaded extends CaseDetailsState {
  final LegalCase legalCase;
  const CaseDetailsLoaded(this.legalCase);

  @override
  List<Object?> get props => [legalCase];
}

class CaseDetailsError extends CaseDetailsState {
  final String message;
  const CaseDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
