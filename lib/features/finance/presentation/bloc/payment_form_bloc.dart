import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/create_payment_request.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/repository/i_finance_repository.dart';

abstract class PaymentFormEvent extends Equatable {
  const PaymentFormEvent();
  @override
  List<Object?> get props => [];
}

class RecordPaymentSubmitted extends PaymentFormEvent {
  const RecordPaymentSubmitted({required this.caseId, required this.request});
  final String caseId;
  final CreatePaymentRequest request;
  @override
  List<Object?> get props => [caseId, request];
}

class ReversePaymentSubmitted extends PaymentFormEvent {
  const ReversePaymentSubmitted(
      {required this.paymentId, required this.reason});
  final String paymentId;
  final String reason;
  @override
  List<Object?> get props => [paymentId, reason];
}

abstract class PaymentFormState extends Equatable {
  const PaymentFormState();
  @override
  List<Object?> get props => [];
}

class PaymentFormInitial extends PaymentFormState {
  const PaymentFormInitial();
}

class PaymentFormSubmitting extends PaymentFormState {
  const PaymentFormSubmitting();
}

class PaymentFormSuccess extends PaymentFormState {
  const PaymentFormSuccess(this.record, {this.fromReverse = false});
  final PaymentRecord record;

  /// True when this success came from reversing a payment rather than
  /// recording a new one — callers show the right feedback per action.
  final bool fromReverse;
  @override
  List<Object?> get props => [record, fromReverse];
}

/// Submission failed. The dialog that triggered it stays open with its
/// entered values intact — the user can correct and resubmit without
/// retyping the whole form.
class PaymentFormError extends PaymentFormState {
  const PaymentFormError(
    this.message, {
    this.isValidationError = false,
    this.isForbidden = false,
    this.fromReverse = false,
  });

  final String message;

  /// True when the server rejected the payload (400/422) — overpayment
  /// and amount/date/method validation live here.
  final bool isValidationError;

  /// True on 403 — the session lost finance rights mid-form; the dialog
  /// closes rather than offering a retry that will fail again.
  final bool isForbidden;

  /// True when the failure came from the reverse action rather than
  /// recording a new payment — callers key success/failure handling on it.
  final bool fromReverse;

  @override
  List<Object?> get props =>
      [message, isValidationError, isForbidden, fromReverse];
}

@injectable
class PaymentFormBloc extends Bloc<PaymentFormEvent, PaymentFormState> {
  PaymentFormBloc(this._repository) : super(const PaymentFormInitial()) {
    on<RecordPaymentSubmitted>(_onRecordPayment);
    on<ReversePaymentSubmitted>(_onReversePayment);
  }

  final IFinanceRepository _repository;

  Future<void> _onRecordPayment(
    RecordPaymentSubmitted event,
    Emitter<PaymentFormState> emit,
  ) async {
    if (state is PaymentFormSubmitting) return;
    emit(const PaymentFormSubmitting());
    final result = await _repository.recordPayment(event.caseId, event.request);
    result.fold(
      (failure) => emit(_failureState(failure, fromReverse: false)),
      (record) => emit(PaymentFormSuccess(record)),
    );
  }

  Future<void> _onReversePayment(
    ReversePaymentSubmitted event,
    Emitter<PaymentFormState> emit,
  ) async {
    if (state is PaymentFormSubmitting) return;
    emit(const PaymentFormSubmitting());
    final result =
        await _repository.reversePayment(event.paymentId, event.reason);
    result.fold(
      (failure) => emit(_failureState(failure, fromReverse: true)),
      (record) => emit(PaymentFormSuccess(record, fromReverse: true)),
    );
  }

  PaymentFormError _failureState(
    Failure failure, {
    required bool fromReverse,
  }) {
    return PaymentFormError(
      failure.message,
      isValidationError: failure is ValidationFailure,
      isForbidden: failure is ForbiddenFailure || failure is UnauthorizedFailure,
      fromReverse: fromReverse,
    );
  }
}
