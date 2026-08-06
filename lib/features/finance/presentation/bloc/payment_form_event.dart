part of 'payment_form_bloc.dart';

abstract class PaymentFormEvent extends Equatable {
  const PaymentFormEvent();

  @override
  List<Object?> get props => [];
}

class PaymentSubmitted extends PaymentFormEvent {
  final CreatePaymentRequest request;
  const PaymentSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}
