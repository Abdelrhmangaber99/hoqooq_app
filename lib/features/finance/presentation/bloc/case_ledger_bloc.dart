import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/case_finance_detail.dart';
import '../../domain/repository/i_finance_repository.dart';

abstract class CaseLedgerEvent extends Equatable {
  const CaseLedgerEvent();
  @override
  List<Object?> get props => [];
}

/// finance.case.view: load the Case's agreed fee, paid total, remaining
/// balance, and payment history. There is no client-side agreed-fee writer
/// — the Case Finance API has no such route; the fee is edited on the Case
/// form (`PATCH /cases/:id`), which is gated by `case.edit`.
class FetchCaseLedgerRequested extends CaseLedgerEvent {
  const FetchCaseLedgerRequested(this.caseId);
  final String caseId;
  @override
  List<Object?> get props => [caseId];
}

abstract class CaseLedgerState extends Equatable {
  const CaseLedgerState();
  @override
  List<Object?> get props => [];
}

class CaseLedgerInitial extends CaseLedgerState {
  const CaseLedgerInitial();
}

class CaseLedgerLoading extends CaseLedgerState {
  const CaseLedgerLoading();
}

class CaseLedgerLoaded extends CaseLedgerState {
  const CaseLedgerLoaded(this.detail);
  final CaseFinanceDetail detail;
  @override
  List<Object?> get props => [detail];
}

/// Fetch/update failed. [detail] carries the last successfully loaded
/// ledger so the tab can keep rendering real data with the error shown
/// above it — a transient network failure doesn't blank the screen.
class CaseLedgerError extends CaseLedgerState {
  const CaseLedgerError({
    required this.message,
    this.isForbidden = false,
    this.detail,
  });
  final String message;
  final bool isForbidden;
  final CaseFinanceDetail? detail;
  @override
  List<Object?> get props => [message, isForbidden, detail];
}

@injectable
class CaseLedgerBloc extends Bloc<CaseLedgerEvent, CaseLedgerState> {
  CaseLedgerBloc(this._repository) : super(const CaseLedgerInitial()) {
    on<FetchCaseLedgerRequested>(_onFetchLedger);
  }

  final IFinanceRepository _repository;

  Future<void> _onFetchLedger(
    FetchCaseLedgerRequested event,
    Emitter<CaseLedgerState> emit,
  ) async {
    emit(const CaseLedgerLoading());
    final result = await _repository.getCaseFinance(event.caseId);
    _emitLedgerResult(result, emit, keepDetail: null);
  }

  /// One fold rule for the fetch: success → Loaded; failure → Error
  /// carrying [keepDetail] (the last good ledger) when there is one, so a
  /// transient failure never blanks already-rendered data.
  void _emitLedgerResult(
    Either<Failure, CaseFinanceDetail> result,
    Emitter<CaseLedgerState> emit, {
    required CaseFinanceDetail? keepDetail,
  }) {
    result.fold(
      (failure) => emit(CaseLedgerError(
        message: failure.message,
        isForbidden: failure is ForbiddenFailure,
        detail: keepDetail,
      )),
      (detail) => emit(CaseLedgerLoaded(detail)),
    );
  }
}
