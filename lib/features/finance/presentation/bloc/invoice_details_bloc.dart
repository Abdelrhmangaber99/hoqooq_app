import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repository/i_finance_repository.dart';

part 'invoice_details_event.dart';
part 'invoice_details_state.dart';

/// Calls the repository directly (`GET /finance/invoices/{id}`) rather
/// than through a dedicated use case — same precedent as `CaseDetailsBloc`.
@injectable
class InvoiceDetailsBloc
    extends Bloc<InvoiceDetailsEvent, InvoiceDetailsState> {
  final IFinanceRepository _financeRepository;

  InvoiceDetailsBloc(this._financeRepository) : super(InvoiceDetailsInitial()) {
    on<FetchInvoiceDetailsRequested>((event, emit) async {
      emit(InvoiceDetailsLoading());
      final result = await _financeRepository.getInvoiceDetails(event.id);
      result.fold(
        (failure) => emit(
          InvoiceDetailsError(
            failure.message,
            isForbidden: failure is ForbiddenFailure,
          ),
        ),
        (invoice) => emit(InvoiceDetailsLoaded(invoice)),
      );
    });
  }
}
