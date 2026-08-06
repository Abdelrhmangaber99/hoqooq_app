part of 'payment_form_bloc.dart';

abstract class PaymentFormState extends Equatable {
  const PaymentFormState();

  @override
  List<Object?> get props => [];
}

class PaymentFormInitial extends PaymentFormState {}

class PaymentFormSubmitting extends PaymentFormState {}

class PaymentFormSuccess extends PaymentFormState {
  final Payment payment;
  const PaymentFormSuccess(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentFormFailure extends PaymentFormState {
  final String message;
  const PaymentFormFailure(this.message);

  @override
  List<Object?> get props => [message];
}
