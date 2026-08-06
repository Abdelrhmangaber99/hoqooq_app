part of 'cases_financial_summary_bloc.dart';

abstract class CasesFinancialSummaryState extends Equatable {
  const CasesFinancialSummaryState();

  @override
  List<Object?> get props => [];
}

class CasesFinancialSummaryInitial extends CasesFinancialSummaryState {}

class CasesFinancialSummaryLoading extends CasesFinancialSummaryState {}

class CasesFinancialSummaryLoaded extends CasesFinancialSummaryState {
  final List<CaseFinancialSummary> summaries;
  const CasesFinancialSummaryLoaded(this.summaries);

  @override
  List<Object?> get props => [summaries];
}

class CasesFinancialSummaryError extends CasesFinancialSummaryState {
  final String message;
  final bool isForbidden;
  const CasesFinancialSummaryError(this.message, {this.isForbidden = false});

  @override
  List<Object?> get props => [message, isForbidden];
}
