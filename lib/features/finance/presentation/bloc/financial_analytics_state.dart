part of 'financial_analytics_bloc.dart';

abstract class FinancialAnalyticsState extends Equatable {
  const FinancialAnalyticsState();

  @override
  List<Object?> get props => [];
}

class FinancialAnalyticsInitial extends FinancialAnalyticsState {}

class FinancialAnalyticsLoading extends FinancialAnalyticsState {}

class FinancialAnalyticsLoaded extends FinancialAnalyticsState {
  final FinancialAnalytics analytics;
  const FinancialAnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

class FinancialAnalyticsError extends FinancialAnalyticsState {
  final String message;
  final bool isForbidden;
  const FinancialAnalyticsError(this.message, {this.isForbidden = false});

  @override
  List<Object?> get props => [message, isForbidden];
}
