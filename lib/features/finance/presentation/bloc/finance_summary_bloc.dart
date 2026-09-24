import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/repository/i_finance_repository.dart';

abstract class FinanceSummaryEvent extends Equatable {
  const FinanceSummaryEvent();
  @override
  List<Object?> get props => [];
}

class FetchFinanceSummaryRequested extends FinanceSummaryEvent {
  const FetchFinanceSummaryRequested();
}

abstract class FinanceSummaryState extends Equatable {
  const FinanceSummaryState();
  @override
  List<Object?> get props => [];
}

class FinanceSummaryInitial extends FinanceSummaryState {
  const FinanceSummaryInitial();
}

class FinanceSummaryLoading extends FinanceSummaryState {
  const FinanceSummaryLoading();
}

class FinanceSummaryLoaded extends FinanceSummaryState {
  const FinanceSummaryLoaded(this.summary);
  final FinanceSummary summary;
  @override
  List<Object?> get props => [summary];
}

class FinanceSummaryError extends FinanceSummaryState {
  const FinanceSummaryError({required this.message, this.isForbidden = false});
  final String message;
  final bool isForbidden;
  @override
  List<Object?> get props => [message, isForbidden];
}

@injectable
class FinanceSummaryBloc
    extends Bloc<FinanceSummaryEvent, FinanceSummaryState> {
  FinanceSummaryBloc(this._repository) : super(const FinanceSummaryInitial()) {
    on<FetchFinanceSummaryRequested>(_onFetchSummary);
  }

  final IFinanceRepository _repository;

  Future<void> _onFetchSummary(
    FetchFinanceSummaryRequested event,
    Emitter<FinanceSummaryState> emit,
  ) async {
    emit(const FinanceSummaryLoading());
    final result = await _repository.getSummary();
    result.fold(
      (failure) => emit(
        FinanceSummaryError(
          message: failure.message,
          isForbidden: failure is ForbiddenFailure,
        ),
      ),
      (summary) => emit(FinanceSummaryLoaded(summary)),
    );
  }
}
