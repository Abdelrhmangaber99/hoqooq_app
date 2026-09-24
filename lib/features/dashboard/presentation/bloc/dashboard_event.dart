part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardRequested extends DashboardEvent {}

/// finance.firm.read: reload the firm finance aggregates from the backend
/// with the given PRD filters applied. Changing any filter dispatches this
/// — filtered totals are always recomputed server-side over the caller's
/// authorized case scope, never derived from already-loaded data.
class RefreshFinanceSummaryRequested extends DashboardEvent {
  const RefreshFinanceSummaryRequested({this.filters = const {}});

  /// PRD-supported filter keys: `paymentStatus` (PAID / PARTIAL / UNPAID),
  /// `from` / `to` (ISO date range), `caseTypeId`, `lawyerId`, `courtId`.
  final Map<String, dynamic> filters;

  @override
  List<Object?> get props => [filters];
}
