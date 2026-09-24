import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/legal_case.dart';
import '../../domain/entities/case_status.dart';
import '../../domain/repository/i_case_repository.dart';

part 'case_details_event.dart';
part 'case_details_state.dart';

/// Calls the repository directly (`GET /cases/{id}`) rather than through a
/// dedicated use case — a single pass-through call doesn't need that
/// extra layer, same precedent as `AuthBloc.getCurrentUser()` in M1.
@injectable
class CaseDetailsBloc extends Bloc<CaseDetailsEvent, CaseDetailsState> {
  final ICaseRepository _repository;

  CaseDetailsBloc(this._repository) : super(CaseDetailsInitial()) {
    on<FetchCaseDetailsRequested>((event, emit) async {
      emit(CaseDetailsLoading());
      final result = await _repository.getCaseDetails(event.id);
      result.fold(
        (failure) => emit(
          CaseDetailsError(
            failure.message,
            isForbidden: failure is ForbiddenFailure,
          ),
        ),
        (legalCase) => emit(CaseDetailsLoaded(legalCase)),
      );
    });
    on<ChangeCaseStatusRequested>((event, emit) async {
      final current = state;
      if (current is! CaseDetailsLoaded || current.isUpdatingStatus) return;
      emit(current.copyWith(isUpdatingStatus: true));
      final result = await _repository.changeCaseStatus(event.id, event.status);
      result.fold(
        (failure) => emit(
          current.copyWith(
            isUpdatingStatus: false,
            actionError: failure.message,
          ),
        ),
        (legalCase) => emit(CaseDetailsLoaded(legalCase)),
      );
    });
  }
}
