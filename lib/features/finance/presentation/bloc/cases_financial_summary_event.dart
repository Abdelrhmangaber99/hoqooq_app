part of 'cases_financial_summary_bloc.dart';

abstract class CasesFinancialSummaryEvent extends Equatable {
  const CasesFinancialSummaryEvent();

  @override
  List<Object?> get props => [];
}

class FetchCasesFinancialSummaryRequested extends CasesFinancialSummaryEvent {}
