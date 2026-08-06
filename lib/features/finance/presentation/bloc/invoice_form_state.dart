part of 'invoice_form_bloc.dart';

abstract class InvoiceFormState extends Equatable {
  const InvoiceFormState();

  @override
  List<Object?> get props => [];
}

class InvoiceFormInitial extends InvoiceFormState {}

class InvoiceFormLoading extends InvoiceFormState {}

/// The form is ready to use — Clients/Cases reference data loaded (or
/// degraded to empty on failure). Also carries submission status so the
/// same screen can show a spinner/error without losing the reference data
/// it already has.
class InvoiceFormReady extends InvoiceFormState {
  final List<Client> clients;
  final List<LegalCase> cases;
  final bool isSubmitting;
  final String? submitError;

  const InvoiceFormReady({
    required this.clients,
    required this.cases,
    this.isSubmitting = false,
    this.submitError,
  });

  InvoiceFormReady copyWith({bool? isSubmitting, String? submitError}) {
    return InvoiceFormReady(
      clients: clients,
      cases: cases,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [clients, cases, isSubmitting, submitError];
}

class InvoiceFormSuccess extends InvoiceFormState {
  final Invoice savedInvoice;
  const InvoiceFormSuccess(this.savedInvoice);

  @override
  List<Object?> get props => [savedInvoice];
}
