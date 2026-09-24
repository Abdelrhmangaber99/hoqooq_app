part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  const DashboardLoaded(
    this.metrics, {
    this.upcomingHearings = const [],
    this.financeSummary,
    this.financeFilters = const {},
    this.canViewFinance = false,
  });

  final DashboardMetrics metrics;
  final List<Hearing> upcomingHearings;

  /// Firm-wide aggregates from `GET /finance/summary` — only ever populated
  /// when the session holds `finance.firm.read`. Null after a failed
  /// fetch (the panel degrades to its empty/error state).
  final FinanceSummary? financeSummary;

  /// Filters currently applied to [financeSummary]. Empty = unfiltered.
  final Map<String, dynamic> financeFilters;
  final bool canViewFinance;

  /// Replaces just the finance slice — used by filter reloads so the KPIs
  /// and other panels keep their state instead of flashing to Loading.
  DashboardLoaded withFinanceSummary(
    FinanceSummary summary, {
    Map<String, dynamic> filters = const {},
  }) {
    return DashboardLoaded(
      metrics,
      upcomingHearings: upcomingHearings,
      financeSummary: summary,
      financeFilters: filters,
      canViewFinance: canViewFinance,
    );
  }

  @override
  List<Object?> get props => [
    metrics,
    upcomingHearings,
    financeSummary,
    financeFilters,
    canViewFinance,
  ];
}

/// A firm-finance aggregate fetch is in flight (filter change or manual
/// refresh) while a loaded dashboard remains on screen. Carries the filters
/// being applied so the panel can highlight the active chip.
class DashboardFinanceLoading extends DashboardLoaded {
  // Not const: forwards fields of a runtime `base` instance.
  DashboardFinanceLoading(DashboardLoaded base, {this.filters = const {}})
    : super(
        base.metrics,
        upcomingHearings: base.upcomingHearings,
        financeSummary: base.financeSummary,
        financeFilters: filters,
        canViewFinance: base.canViewFinance,
      );

  /// Filters being requested (may differ from the rendered
  /// [DashboardLoaded.financeFilters] until the fetch completes).
  final Map<String, dynamic> filters;

  @override
  List<Object?> get props => [...super.props, filters];
}

/// A firm-finance aggregate fetch failed while a loaded dashboard remains
/// on screen — the panel keeps rendering the last summary with the error
/// surfaced (message is shown by the page's error layer).
class DashboardFinanceError extends DashboardLoaded {
  // Not const: forwards fields of a runtime `base` instance.
  DashboardFinanceError(DashboardLoaded base, this.error)
    : super(
        base.metrics,
        upcomingHearings: base.upcomingHearings,
        financeSummary: base.financeSummary,
        financeFilters: base.financeFilters,
        canViewFinance: base.canViewFinance,
      );

  final String error;

  @override
  List<Object?> get props => [...super.props, error];
}

class DashboardError extends DashboardState {
  const DashboardError(this.message, {this.isForbidden = false});

  final String message;
  final bool isForbidden;

  @override
  List<Object?> get props => [message, isForbidden];
}
