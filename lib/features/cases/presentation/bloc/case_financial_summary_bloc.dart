import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../finance/domain/entities/single_case_financial_detail.dart';
import '../../../finance/domain/repository/i_finance_repository.dart';

part 'case_financial_summary_event.dart';
part 'case_financial_summary_state.dart';

/// Powers `CaseDetailsPage`'s Financials section
/// (`GET /finance/cases/:caseId/summary`, API_CONTRACT.md finding R). A
/// sibling bloc to `CaseDetailsBloc`/`CaseHearingsBloc`/`CaseDocumentsBloc`
/// rather than folded into any of them, same Rule-of-Three precedent as
/// those two. Depends on the `finance` feature's repository — this app's
/// established pattern already crosses feature boundaries this way
/// (`ClientDetailsBloc` depends on `ICaseRepository`, `DashboardBloc`
/// depends on `ITaskRepository`), not a new precedent.
@injectable
class CaseFinancialSummaryBloc
    extends Bloc<CaseFinancialSummaryEvent, CaseFinancialSummaryState> {
  final IFinanceRepository _financeRepository;

  CaseFinancialSummaryBloc(this._financeRepository)
    : super(CaseFinancialSummaryInitial()) {
    on<FetchCaseFinancialSummaryRequested>((event, emit) async {
      emit(CaseFinancialSummaryLoading());
      final result = await _financeRepository.getCaseFinancialSummary(
        event.caseId,
      );
      result.fold(
        (failure) => emit(
          CaseFinancialSummaryError(
            failure.message,
            isForbidden: failure is ForbiddenFailure,
          ),
        ),
        (summary) => emit(CaseFinancialSummaryLoaded(summary)),
      );
    });
  }
}
