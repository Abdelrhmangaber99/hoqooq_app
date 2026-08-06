part of 'financial_analytics_bloc.dart';

abstract class FinancialAnalyticsEvent extends Equatable {
  const FinancialAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class FetchFinancialAnalyticsRequested extends FinancialAnalyticsEvent {}
