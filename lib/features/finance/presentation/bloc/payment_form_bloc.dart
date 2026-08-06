import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/create_payment_request.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repository/i_finance_repository.dart';

part 'payment_form_event.dart';
part 'payment_form_state.dart';

/// Powers the "Record Payment" action on `InvoiceDetailsPage` — a
/// dedicated write-only bloc, sibling to `InvoiceDetailsBloc`/
/// `InvoicesBloc`, same precedent as `CalendarEventFormBloc`. Create-only:
/// no update (`FinanceController` has no `PATCH /finance/payments/{id}` at
/// all) and no delete (deferred, see API_CONTRACT.md finding R). No
/// reference-data step — `invoiceId` is known from the calling screen,
/// every other field is either free-form or a fixed enum.
///
/// Does not refetch the invoice itself on success — `InvoiceDetailsPage`
/// refetches explicitly, since the backend auto-transitions the invoice's
/// `status` server-side on payment and the client needs a fresh fetch to
/// see it (per PLAN.md's M6 scope note).
@injectable
class PaymentFormBloc extends Bloc<PaymentFormEvent, PaymentFormState> {
  final IFinanceRepository _financeRepository;

  PaymentFormBloc(this._financeRepository) : super(PaymentFormInitial()) {
    on<PaymentSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    PaymentSubmitted event,
    Emitter<PaymentFormState> emit,
  ) async {
    emit(PaymentFormSubmitting());
    final result = await _financeRepository.createPayment(event.request);
    result.fold(
      (failure) => emit(PaymentFormFailure(failure.message)),
      (payment) => emit(PaymentFormSuccess(payment)),
    );
  }
}
