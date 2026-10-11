import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/auth/permission_codes.dart';
import '../../../../core/errors/failures.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../../../finance/domain/entities/finance_summary.dart';
import '../../../finance/domain/repository/i_finance_repository.dart';
import '../../../hearings/domain/entities/hearing.dart';
import '../../../hearings/domain/entities/hearing_status.dart';
import '../../../hearings/domain/repository/i_hearing_repository.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repository/i_dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// Composes the v2-backed sections used by the web Dashboard. Secondary
/// hearing and finance failures degrade to empty panels so the KPI summary
/// remains useful.
@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(
    this._dashboardRepository,
    this._hearingRepository,
    this._financeRepository,
    this._sessionCubit,
  ) : super(DashboardInitial()) {
    on<FetchDashboardRequested>(_onFetch);
    on<RefreshFinanceSummaryRequested>(_onRefreshFinanceSummary);
  }

  final IDashboardRepository _dashboardRepository;
  final IHearingRepository _hearingRepository;
  final IFinanceRepository _financeRepository;
  final SessionCubit _sessionCubit;

  Future<void> _onFetch(
    FetchDashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final metricsResult = await _dashboardRepository.getMetrics();
    await metricsResult.fold(
      (failure) async => emit(
        DashboardError(
          failure.message,
          isForbidden: failure is ForbiddenFailure,
        ),
      ),
      (metrics) async {
        final sessionState = _sessionCubit.state;
        final user =
            sessionState is SessionAuthenticated ? sessionState.user : null;
        final canViewHearings =
            user?.isFirmAdmin == true ||
            (user?.hasPerm(PermissionCodes.hearingView) ?? false);
        final canViewFinance = _canViewFirmFinance();

        var upcomingHearings = const <Hearing>[];
        if (canViewHearings) {
          final result = await _hearingRepository.getHearings();
          upcomingHearings = result.fold((_) => const <Hearing>[], (hearings) {
            final now = DateTime.now();
            final upcoming =
                hearings
                    .where(
                      (hearing) =>
                          hearing.status == HearingStatus.scheduled &&
                          !hearing.scheduledAt.isBefore(now),
                    )
                    .toList()
                  ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
            return upcoming.take(5).toList(growable: false);
          });
        }

        FinanceSummary? financeSummary;
        if (canViewFinance) {
          final result = await _financeRepository.getSummary();
          financeSummary = result.fold((_) => null, (value) => value);
        }

        emit(
          DashboardLoaded(
            metrics,
            upcomingHearings: upcomingHearings,
            financeSummary: financeSummary,
            financeFilters: _financeFilters ?? const {},
            canViewFinance: canViewFinance,
          ),
        );
      },
    );
  }

  /// Filters applied to the most recent finance summary fetch, so an
  /// unrelated full-dashboard reload re-issues the same filtered request.
  Map<String, dynamic>? _financeFilters;

  Future<void> _onRefreshFinanceSummary(
    RefreshFinanceSummaryRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Re-checked live, not cached from construction: a mid-session
    // revocation of finance.firm.read must both hide the widgets and stop
    // any further aggregate requests (no stale firm-wide data).
    if (!_canViewFirmFinance()) return;

    _financeFilters = event.filters.isEmpty ? null : Map.of(event.filters);

    final current = state;
    if (current is! DashboardLoaded) {
      // No loaded dashboard to update in place — the full fetch flow covers
      // this state and will request finance itself.
      return;
    }
    emit(
      DashboardFinanceLoading(current, filters: _financeFilters ?? const {}),
    );

    final result = await _financeRepository.getSummary(
      queryParameters: _financeFilters,
    );
    result.fold(
      // Failure: keep showing the last successfully loaded aggregates
      // (stale-but-labeled beats blanking a whole dashboard); the next
      // successful fetch replaces them.
      (failure) => emit(DashboardFinanceError(current, failure.message)),
      (summary) => emit(
        current.withFinanceSummary(
          summary,
          filters: _financeFilters ?? const {},
        ),
      ),
    );
  }

  bool _canViewFirmFinance() {
    final sessionState = _sessionCubit.state;
    return sessionState is SessionAuthenticated &&
        (sessionState.isFirmAdmin ||
            sessionState.user.hasPerm(PermissionCodes.financeFirmRead));
  }
}
