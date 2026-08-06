part of 'case_financial_summary_bloc.dart';

abstract class CaseFinancialSummaryState extends Equatable {
  const CaseFinancialSummaryState();

  @override
  List<Object?> get props => [];
}

class CaseFinancialSummaryInitial extends CaseFinancialSummaryState {}

class CaseFinancialSummaryLoading extends CaseFinancialSummaryState {}

class CaseFinancialSummaryLoaded extends CaseFinancialSummaryState {
  final SingleCaseFinancialDetail summary;
  const CaseFinancialSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class CaseFinancialSummaryError extends CaseFinancialSummaryState {
  final String message;
  final bool isForbidden;
  const CaseFinancialSummaryError(this.message, {this.isForbidden = false});

  @override
  List<Object?> get props => [message, isForbidden];
}
