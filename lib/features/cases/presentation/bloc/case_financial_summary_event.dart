part of 'case_financial_summary_bloc.dart';

abstract class CaseFinancialSummaryEvent extends Equatable {
  const CaseFinancialSummaryEvent();

  @override
  List<Object?> get props => [];
}

class FetchCaseFinancialSummaryRequested extends CaseFinancialSummaryEvent {
  final String caseId;
  const FetchCaseFinancialSummaryRequested(this.caseId);

  @override
  List<Object?> get props => [caseId];
}
