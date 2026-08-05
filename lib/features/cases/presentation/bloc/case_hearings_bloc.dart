import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../hearings/domain/entities/hearing.dart';
import '../../../hearings/domain/repository/i_hearing_repository.dart';

part 'case_hearings_event.dart';
part 'case_hearings_state.dart';

/// Powers `CaseDetailsPage`'s Hearings section. `GET /hearings` has no
/// `?caseId=` filter (API_CONTRACT.md finding I), so this fetches the full
/// tenant collection and filters client-side by `caseId` — same pattern as
/// M2's `ClientDetailsBloc` filtering cases by `clientId`. A sibling bloc to
/// `CaseDetailsBloc` rather than folded into it, to avoid a 3-way
/// fetch-and-merge bloc (Rule of Three, per the M2 retrospective).
@injectable
class CaseHearingsBloc extends Bloc<CaseHearingsEvent, CaseHearingsState> {
  final IHearingRepository _hearingRepository;

  CaseHearingsBloc(this._hearingRepository) : super(CaseHearingsInitial()) {
    on<FetchCaseHearingsRequested>(_onFetch);
  }

  Future<void> _onFetch(
    FetchCaseHearingsRequested event,
    Emitter<CaseHearingsState> emit,
  ) async {
    emit(CaseHearingsLoading());
    final result = await _hearingRepository.getHearings();
    result.fold(
      (failure) => emit(
        CaseHearingsError(
          failure.message,
          isForbidden: failure is ForbiddenFailure,
        ),
      ),
      (hearings) => emit(
        CaseHearingsLoaded(
          hearings.where((h) => h.caseId == event.caseId).toList(),
        ),
      ),
    );
  }
}
