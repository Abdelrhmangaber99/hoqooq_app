import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../cases/domain/entities/court.dart';
import '../../../courts/domain/repository/i_court_repository.dart';
import '../../../lookups/domain/entities/lookup.dart';
import '../../../lookups/domain/entities/lookup_kind.dart';
import '../../../lookups/domain/repository/i_lookup_repository.dart';
import '../../data/models/create_service_process_request.dart';
import '../../data/models/update_service_process_request.dart';
import '../../domain/entities/service_process.dart';
import '../../domain/repository/i_service_process_repository.dart';

part 'service_process_form_event.dart';
part 'service_process_form_state.dart';

@injectable
class ServiceProcessFormBloc
    extends Bloc<ServiceProcessFormEvent, ServiceProcessFormState> {
  ServiceProcessFormBloc(
    this._repository,
    this._courtRepository,
    this._lookupRepository,
  ) : super(ServiceProcessFormInitial()) {
    on<LoadServiceProcessFormRequested>(_onLoad);
    on<CreateServiceProcessSubmitted>(_onCreate);
    on<UpdateServiceProcessSubmitted>(_onUpdate);
  }

  final IServiceProcessRepository _repository;
  final ICourtRepository _courtRepository;
  final ILookupRepository _lookupRepository;

  bool _isSubmitting = false;

  Future<void> _onLoad(
    LoadServiceProcessFormRequested event,
    Emitter<ServiceProcessFormState> emit,
  ) async {
    emit(ServiceProcessFormLoading());
    final courtsFuture = _courtRepository.getCourts(event.governorateId);
    final methodsFuture = _lookupRepository.getLookups(
      kind: LookupKind.serviceMethod,
    );
    final courtsResult = await courtsFuture;
    final methodsResult = await methodsFuture;
    emit(
      ServiceProcessFormReady(
        courts: courtsResult.fold((_) => [], (items) => items),
        methods: methodsResult.fold((_) => [], (items) => items),
      ),
    );
  }

  Future<void> _onCreate(
    CreateServiceProcessSubmitted event,
    Emitter<ServiceProcessFormState> emit,
  ) async {
    final current = state;
    if (current is! ServiceProcessFormReady) return;
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(current.copyWith(isSubmitting: true, submitError: null));
    final result = await _repository.create(event.request);
    _isSubmitting = false;
    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (item) => emit(ServiceProcessFormSuccess(item)),
    );
  }

  Future<void> _onUpdate(
    UpdateServiceProcessSubmitted event,
    Emitter<ServiceProcessFormState> emit,
  ) async {
    final current = state;
    if (current is! ServiceProcessFormReady) return;
    if (_isSubmitting) return;
    _isSubmitting = true;
    emit(current.copyWith(isSubmitting: true, submitError: null));
    final result = await _repository.update(event.id, event.request);
    _isSubmitting = false;
    result.fold(
      (failure) => emit(
        current.copyWith(isSubmitting: false, submitError: failure.message),
      ),
      (item) => emit(ServiceProcessFormSuccess(item)),
    );
  }
}
