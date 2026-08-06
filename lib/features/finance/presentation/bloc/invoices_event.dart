part of 'invoices_bloc.dart';

abstract class InvoicesEvent extends Equatable {
  const InvoicesEvent();

  @override
  List<Object?> get props => [];
}

class FetchInvoicesRequested extends InvoicesEvent {}

class InvoicesStatusFilterChanged extends InvoicesEvent {
  final InvoiceStatus? status;
  const InvoicesStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}
