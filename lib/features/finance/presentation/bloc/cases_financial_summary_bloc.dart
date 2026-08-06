import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/case_financial_summary.dart';
import '../../domain/repository/i_finance_repository.dart';

part 'cases_financial_summary_event.dart';
part 'cases_financial_summary_state.dart';

/// Calls the repository directly (`GET /finance/cases-summary`) rather
/// than through a dedicated use case — same precedent as `CaseDetailsBloc`.
/// No client-side filtering here (unlike `InvoicesBloc`/`CasesBloc`) — not
/// asked for in the approved M6 scope.
@injectable
class CasesFinancialSummaryBloc
    extends Bloc<CasesFinancialSummaryEvent, CasesFinancialSummaryState> {
  final IFinanceRepository _financeRepository;

  CasesFinancialSummaryBloc(this._financeRepository)
    : super(CasesFinancialSummaryInitial()) {
    on<FetchCasesFinancialSummaryRequested>((event, emit) async {
      emit(CasesFinancialSummaryLoading());
      final result = await _financeRepository.getCasesFinancialSummary();
      result.fold(
        (failure) => emit(
          CasesFinancialSummaryError(
            failure.message,
            isForbidden: failure is ForbiddenFailure,
          ),
        ),
        (summaries) => emit(CasesFinancialSummaryLoaded(summaries)),
      );
    });
  }
}
