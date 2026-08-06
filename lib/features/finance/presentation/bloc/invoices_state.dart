part of 'invoices_bloc.dart';

abstract class InvoicesState extends Equatable {
  const InvoicesState();

  @override
  List<Object?> get props => [];
}

class InvoicesInitial extends InvoicesState {}

class InvoicesLoading extends InvoicesState {}

/// Zero-results is represented by an empty `invoices` list here — the list
/// screen decides whether to show the `EmptyState` widget, same precedent
/// as `CasesLoaded`.
class InvoicesLoaded extends InvoicesState {
  final List<Invoice> invoices;
  final InvoiceStatus? statusFilter;

  const InvoicesLoaded(this.invoices, {this.statusFilter});

  @override
  List<Object?> get props => [invoices, statusFilter];
}

class InvoicesError extends InvoicesState {
  final String message;
  final bool isForbidden;
  const InvoicesError(this.message, {this.isForbidden = false});

  @override
  List<Object?> get props => [message, isForbidden];
}
