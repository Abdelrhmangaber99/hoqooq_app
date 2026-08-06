import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/financial_analytics.dart';
import '../../domain/repository/i_finance_repository.dart';

part 'financial_analytics_event.dart';
part 'financial_analytics_state.dart';

/// Calls the repository directly (`GET /finance/analytics`) rather than
/// through a dedicated use case — same precedent as `CaseDetailsBloc`.
@injectable
class FinancialAnalyticsBloc
    extends Bloc<FinancialAnalyticsEvent, FinancialAnalyticsState> {
  final IFinanceRepository _financeRepository;

  FinancialAnalyticsBloc(this._financeRepository)
    : super(FinancialAnalyticsInitial()) {
    on<FetchFinancialAnalyticsRequested>((event, emit) async {
      emit(FinancialAnalyticsLoading());
      final result = await _financeRepository.getFinancialAnalytics();
      result.fold(
        (failure) => emit(
          FinancialAnalyticsError(
            failure.message,
            isForbidden: failure is ForbiddenFailure,
          ),
        ),
        (analytics) => emit(FinancialAnalyticsLoaded(analytics)),
      );
    });
  }
}
