import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../cases/domain/entities/legal_case.dart';
import '../../../cases/domain/repository/i_case_repository.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/domain/repository/i_client_repository.dart';
import '../../data/models/create_invoice_request.dart';
import '../../data/models/update_invoice_request.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repository/i_finance_repository.dart';

part 'invoice_form_event.dart';
part 'invoice_form_state.dart';

/// Powers both the Create-Invoice and Edit-Invoice screens. Loads
/// Clients/Cases once as reference data for the `clientId`/`caseId`
/// pickers; a failure on either degrades to an empty list rather than
/// failing the whole form (same precedent as `CaseFormBloc`).
///
/// Does not refetch the invoice itself on success — explicit refetch is
/// the caller's job, per the project's standing write-completion
/// convention.
@injectable
class InvoiceFormBloc extends Bloc<InvoiceFormEvent, InvoiceFormState> {
  final IFinanceRepository _financeRepository;
  final IClientRepository _clientRepository;
  final ICaseRepository _caseRepository;

  InvoiceFormBloc(
    this._financeRepository,
    this._clientRepository,
    this._caseRepository,
  ) : super(InvoiceFormInitial()) {
    on<LoadInvoiceFormReferenceDataRequested>(_onLoad);
    on<CreateInvoiceSubmitted>(_onCreate);
    on<UpdateInvoiceSubmitted>(_onUpdate);
  }

  Future<void> _onLoad(
    LoadInvoiceFormReferenceDataRequested event,
    Emitter<InvoiceFormState> emit,
  ) async {
    emit(InvoiceFormLoading());
    final clientsFuture = _clientRepository.getClients();
    final casesFuture = _caseRepository.getCases();
    final clientsResult = await clientsFuture;
    final casesResult = await casesFuture;
    final clients = clientsResult.fold((_) => const <Client>[], (c) => c);
    final cases = casesResult.fold((_) => const <LegalCase>[], (c) => c);
    emit(InvoiceFormReady(clients: clients, cases: cases));
  }

  Future<void> _onCreate(
    CreateInvoiceSubmitted event,
    Emitter<InvoiceFormState> emit,
  ) async {
    final current = state;
    if (current is! InvoiceFormReady) return;

    emit(current.copyWith(isSubmitting: true, submitError: null));
    final result = await _financeRepository.createInvoice(event.request);
    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (invoice) => emit(InvoiceFormSuccess(invoice)),
    );
  }

  Future<void> _onUpdate(
    UpdateInvoiceSubmitted event,
    Emitter<InvoiceFormState> emit,
  ) async {
    final current = state;
    if (current is! InvoiceFormReady) return;

    emit(current.copyWith(isSubmitting: true, submitError: null));
    final result = await _financeRepository.updateInvoice(
      event.id,
      event.request,
    );
    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (invoice) => emit(InvoiceFormSuccess(invoice)),
    );
  }
}
