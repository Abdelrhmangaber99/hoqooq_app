part of 'invoice_form_bloc.dart';

abstract class InvoiceFormEvent extends Equatable {
  const InvoiceFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvoiceFormReferenceDataRequested extends InvoiceFormEvent {}

class CreateInvoiceSubmitted extends InvoiceFormEvent {
  final CreateInvoiceRequest request;
  const CreateInvoiceSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateInvoiceSubmitted extends InvoiceFormEvent {
  final String id;
  final UpdateInvoiceRequest request;
  const UpdateInvoiceSubmitted(this.id, this.request);

  @override
  List<Object?> get props => [id, request];
}
