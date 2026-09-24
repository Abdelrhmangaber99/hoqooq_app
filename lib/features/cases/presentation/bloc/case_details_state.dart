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
  final bool isUpdatingStatus;
  final String? actionError;
  const CaseDetailsLoaded(
    this.legalCase, {
    this.isUpdatingStatus = false,
    this.actionError,
  });

  CaseDetailsLoaded copyWith({
    LegalCase? legalCase,
    bool? isUpdatingStatus,
    String? actionError,
  }) => CaseDetailsLoaded(
    legalCase ?? this.legalCase,
    isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
    actionError: actionError,
  );

  @override
  List<Object?> get props => [legalCase, isUpdatingStatus, actionError];
}

class CaseDetailsError extends CaseDetailsState {
  final String message;
  final bool isForbidden;
  const CaseDetailsError(this.message, {this.isForbidden = false});

  @override
  List<Object?> get props => [message, isForbidden];
}
