import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/case_status.dart';
import '../../domain/entities/legal_case.dart';
import '../../domain/usecases/get_cases_use_case.dart';

part 'cases_event.dart';
part 'cases_state.dart';

/// No query parameters are documented on `GET /cases` (API_CONTRACT.md
/// §8), so status filtering and search are both done client-side here
/// over the full fetched list — per PLAN.md M2 decision #5.
@injectable
class CasesBloc extends Bloc<CasesEvent, CasesState> {
  final GetCasesUseCase _getCasesUseCase;

  List<LegalCase> _allCases = [];
  CaseStatus? _statusFilter;
  String _searchQuery = '';

  CasesBloc(this._getCasesUseCase) : super(CasesInitial()) {
    on<FetchCasesRequested>(_onFetch);
    on<CasesStatusFilterChanged>(_onStatusFilterChanged);
    on<CasesSearchChanged>(_onSearchChanged);
  }

  Future<void> _onFetch(
    FetchCasesRequested event,
    Emitter<CasesState> emit,
  ) async {
    emit(CasesLoading());
    final result = await _getCasesUseCase.execute();
    result.fold((failure) => emit(CasesError(failure.message)), (cases) {
      _allCases = cases;
      emit(_buildLoadedState());
    });
  }

  void _onStatusFilterChanged(
    CasesStatusFilterChanged event,
    Emitter<CasesState> emit,
  ) {
    _statusFilter = event.status;
    emit(_buildLoadedState());
  }

  void _onSearchChanged(CasesSearchChanged event, Emitter<CasesState> emit) {
    _searchQuery = event.query;
    emit(_buildLoadedState());
  }

  CasesState _buildLoadedState() {
    var filtered = _allCases;
    if (_statusFilter != null) {
      filtered = filtered.where((c) => c.status == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (c) =>
                c.caseNumber.toLowerCase().contains(query) ||
                c.client.fullName.toLowerCase().contains(query),
          )
          .toList();
    }
    return CasesLoaded(
      filtered,
      statusFilter: _statusFilter,
      searchQuery: _searchQuery,
    );
  }
}
