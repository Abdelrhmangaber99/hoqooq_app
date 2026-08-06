part of 'invoice_details_bloc.dart';

abstract class InvoiceDetailsEvent extends Equatable {
  const InvoiceDetailsEvent();

  @override
  List<Object?> get props => [];
}

class FetchInvoiceDetailsRequested extends InvoiceDetailsEvent {
  final String id;
  const FetchInvoiceDetailsRequested(this.id);

  @override
  List<Object?> get props => [id];
}
