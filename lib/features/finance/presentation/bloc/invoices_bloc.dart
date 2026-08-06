import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_status.dart';
import '../../domain/repository/i_finance_repository.dart';

part 'invoices_event.dart';
part 'invoices_state.dart';

/// No query parameters are documented on `GET /finance/invoices`
/// (API_CONTRACT.md finding R), so status filtering is done client-side
/// here over the full fetched list — same precedent as `CasesBloc`.
@injectable
class InvoicesBloc extends Bloc<InvoicesEvent, InvoicesState> {
  final IFinanceRepository _financeRepository;

  List<Invoice> _allInvoices = [];
  InvoiceStatus? _statusFilter;

  InvoicesBloc(this._financeRepository) : super(InvoicesInitial()) {
    on<FetchInvoicesRequested>(_onFetch);
    on<InvoicesStatusFilterChanged>(_onStatusFilterChanged);
  }

  Future<void> _onFetch(
    FetchInvoicesRequested event,
    Emitter<InvoicesState> emit,
  ) async {
    emit(InvoicesLoading());
    final result = await _financeRepository.getInvoices();
    result.fold(
      (failure) => emit(
        InvoicesError(
          failure.message,
          isForbidden: failure is ForbiddenFailure,
        ),
      ),
      (invoices) {
        _allInvoices = invoices;
        emit(_buildLoadedState());
      },
    );
  }

  void _onStatusFilterChanged(
    InvoicesStatusFilterChanged event,
    Emitter<InvoicesState> emit,
  ) {
    _statusFilter = event.status;
    emit(_buildLoadedState());
  }

  InvoicesState _buildLoadedState() {
    var filtered = _allInvoices;
    if (_statusFilter != null) {
      filtered = filtered.where((i) => i.status == _statusFilter).toList();
    }
    return InvoicesLoaded(filtered, statusFilter: _statusFilter);
  }
}
