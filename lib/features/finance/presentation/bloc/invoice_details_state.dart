part of 'invoice_details_bloc.dart';

abstract class InvoiceDetailsState extends Equatable {
  const InvoiceDetailsState();

  @override
  List<Object?> get props => [];
}

class InvoiceDetailsInitial extends InvoiceDetailsState {}

class InvoiceDetailsLoading extends InvoiceDetailsState {}

class InvoiceDetailsLoaded extends InvoiceDetailsState {
  final Invoice invoice;
  const InvoiceDetailsLoaded(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class InvoiceDetailsError extends InvoiceDetailsState {
  final String message;
  final bool isForbidden;
  const InvoiceDetailsError(this.message, {this.isForbidden = false});

  @override
  List<Object?> get props => [message, isForbidden];
}
