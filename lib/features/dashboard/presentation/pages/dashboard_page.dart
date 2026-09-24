import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/money.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../hearings/domain/entities/hearing.dart';
import '../../../hearings/presentation/hearing_display_helpers.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardBloc>()..add(FetchDashboardRequested()),
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading || state is DashboardInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DashboardError) {
                return ErrorView(
                  message: state.message,
                  isForbidden: state.isForbidden,
                  onRetry: () => context.read<DashboardBloc>().add(
                    FetchDashboardRequested(),
                  ),
                );
              }
              if (state is DashboardLoaded) {
                return _DashboardContent(state: state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state});

  final DashboardLoaded state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pagePadding = constraints.maxWidth >= 700
            ? AppSpacing.l
            : AppSpacing.m;
        return SingleChildScrollView(
          padding: EdgeInsets.all(pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('dashboard'), style: AppTypography.h1),
              const SizedBox(height: AppSpacing.l),
              _KpiGrid(state: state, availableWidth: constraints.maxWidth),
              const SizedBox(height: AppSpacing.l),
              if (constraints.maxWidth >= 900)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _FinancePanel(state: state)),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: _HearingsPanel(hearings: state.upcomingHearings),
                    ),
                  ],
                )
              else ...[
                _FinancePanel(state: state),
                const SizedBox(height: AppSpacing.m),
                _HearingsPanel(hearings: state.upcomingHearings),
              ],
              const SizedBox(height: AppSpacing.l),
              _Panel(
                title: context.tr('recent_activity'),
                child: EmptyState(
                  icon: Icons.history_rounded,
                  message: context.tr('no_recent_activity'),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.state, required this.availableWidth});

  final DashboardLoaded state;
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    final columns = availableWidth >= 1100
        ? 4
        : availableWidth >= 600
        ? 2
        : 1;
    final totalCases = state.metrics.totalCases > 0
        ? state.metrics.totalCases
        : state.metrics.totalActiveCases;
    final items = [
      _KpiData(
        context.tr('total_cases'),
        totalCases,
        Icons.business_center_outlined,
        AppColors.ink600,
        AppColors.ink50,
      ),
      _KpiData(
        context.tr('active_cases'),
        state.metrics.totalActiveCases,
        Icons.folder_open_outlined,
        AppColors.brass700,
        AppColors.brass50,
      ),
      _KpiData(
        context.tr('pending_tasks'),
        state.metrics.pendingTasks,
        Icons.error_outline_rounded,
        AppColors.brass700,
        AppColors.brass50,
      ),
      _KpiData(
        context.tr('upcoming_hearings'),
        state.metrics.upcomingHearings,
        Icons.calendar_month_outlined,
        AppColors.ink600,
        AppColors.ink50,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppSpacing.m;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _KpiCard(data: item),
              ),
          ],
        );
      },
    );
  }
}

class _KpiData {
  const _KpiData(this.label, this.value, this.icon, this.color, this.tint);

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color tint;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});

  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.tint,
              borderRadius: AppRadius.medium,
            ),
            child: Icon(data.icon, color: data.color, size: 21),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  NumberFormat.decimalPattern(
                    Localizations.localeOf(context).languageCode,
                  ).format(data.value),
                  style: AppTypography.h2,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(data.label, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Firm Finance Dashboard (PRD v2.0 §6.2.11 / §7.8–7.9 BR-029): Total Case
/// Value, Collected, Outstanding, and Paid/Partial/Unpaid case counts — all
/// computed by the backend over the caller's authorized case scope.
///
/// Rendered only when the session holds `finance.firm.read` (checked both
/// when the bloc fetches and re-checked on every filter fetch): without it
/// the whole section disappears — no disabled shell, no data, no requests.
/// Case-level finance users (finance.case.view / finance.payment.record)
/// get nothing here; firm-wide totals require finance.firm.read (BR-028).
/// ACCOUNTANT classification grants nothing by itself.
class _FinancePanel extends StatelessWidget {
  const _FinancePanel({required this.state});

  final DashboardLoaded state;

  /// PRD payment-status filter options (§7.9 BR-029). Selecting one
  /// dispatches a filtered aggregate fetch — totals are recomputed
  /// server-side, never derived from already-loaded data.
  static const _statusFilters = [
    (value: null),
    (value: 'PAID'),
    (value: 'PARTIAL'),
    (value: 'UNPAID'),
  ];

  @override
  Widget build(BuildContext context) {
    // Permission gate: a mid-session revocation of finance.firm.read makes
    // the bloc ignore refresh requests AND this widget vanish, so no stale
    // firm-wide figures can remain visible.
    if (!state.canViewFinance) {
      return const SizedBox.shrink();
    }

    final finance = state.financeSummary;
    final isRefreshing = state is DashboardFinanceLoading;
    final hasError = state is DashboardFinanceError;
    final activeFilter = state.financeFilters['paymentStatus'] as String?;

    return _Panel(
      title: context.tr('finance'),
      action: TextButton(
        onPressed: () => context.go(AppRouter.finance),
        child: Text(context.tr('view_all')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: Text(
                (state as DashboardFinanceError).error,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.rust500,
                ),
              ),
            ),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              for (final filter in _statusFilters)
                _StatusFilterChip(
                  label: filter.value == null
                      ? context.tr('all')
                      : switch (filter.value) {
                          'PAID' => context.tr('paid_in_full'),
                          'PARTIAL' => context.tr('partially_paid'),
                          _ => context.tr('unpaid'),
                        },
                  selected: activeFilter == filter.value,
                  isLoading: isRefreshing && activeFilter == filter.value,
                  onTap: () => context.read<DashboardBloc>().add(
                        RefreshFinanceSummaryRequested(
                          filters: filter.value == null
                              ? const <String, dynamic>{}
                              : {'paymentStatus': filter.value},
                        ),
                      ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          if (finance == null)
            // No aggregates available (first fetch failed): the shared
            // empty state — never fabricate financial activity.
            EmptyState(
              icon: Icons.receipt_long_outlined,
              message: context.tr('no_financial_data'),
            )
          else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 700
                    ? 3
                    : constraints.maxWidth >= 420
                        ? 2
                        : 1;
                final gap = AppSpacing.s;
                final itemWidth =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                final moneyItems = [
                  (
                    context.tr('total_case_fees'),
                    formatMoney(context, finance.totalCaseValue),
                    Icons.business_center_outlined,
                    AppColors.ink800,
                  ),
                  (
                    context.tr('collected'),
                    formatMoney(context, finance.totalCollected),
                    Icons.savings_outlined,
                    AppColors.emerald500,
                  ),
                  (
                    context.tr('outstanding'),
                    formatMoney(context, finance.totalOutstanding),
                    Icons.hourglass_bottom_rounded,
                    AppColors.rust500,
                  ),
                ];
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final item in moneyItems)
                      SizedBox(
                        width: itemWidth,
                        child: _FinanceMoneyCard(
                          label: item.$1,
                          value: item.$2,
                          icon: item.$3,
                          color: item.$4,
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.s),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 420 ? 3 : 1;
                final gap = AppSpacing.s;
                final itemWidth =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                final countItems = [
                  (context.tr('paid_cases'), finance.paidCases),
                  (context.tr('partial_cases'), finance.partialCases),
                  (context.tr('unpaid_cases'), finance.unpaidCases),
                ];
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final item in countItems)
                      SizedBox(
                        width: itemWidth,
                        child: _FinanceCountCard(
                          label: item.$1,
                          value: item.$2,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (isLoading) ...[
            const SizedBox(width: 6),
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 1.6),
            ),
          ],
        ],
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _FinanceMoneyCard extends StatelessWidget {
  const _FinanceMoneyCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.paperSoft,
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.paperLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: color,
              fontFamily: AppTypography.monoFont,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceCountCard extends StatelessWidget {
  const _FinanceCountCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.paperLine),
      ),
      child: Row(
        children: [
          Text(
            '$value',
            style: AppTypography.h3.copyWith(
              fontFamily: AppTypography.monoFont,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _HearingsPanel extends StatelessWidget {
  const _HearingsPanel({required this.hearings});

  final List<Hearing> hearings;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: context.tr('upcoming_hearings'),
      action: TextButton(
        onPressed: () => context.go(AppRouter.hearings),
        child: Text(context.tr('view_all')),
      ),
      padding: EdgeInsets.zero,
      child: hearings.isEmpty
          ? EmptyState(
              icon: Icons.event_busy_outlined,
              message: context.tr('no_hearings_found'),
            )
          : Column(
              children: [
                for (var i = 0; i < hearings.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _HearingRow(hearing: hearings[i]),
                ],
              ],
            ),
    );
  }
}

class _HearingRow extends StatelessWidget {
  const _HearingRow({required this.hearing});

  final Hearing hearing;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final color = hearingStatusColor(hearing.status);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: 12,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              DateFormat.yMd(locale).add_Hm().format(hearing.scheduledAt),
              style: AppTypography.bodySmall.copyWith(
                fontFamily: AppTypography.monoFont,
                color: AppColors.ink700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              hearing.caseSummary?.caseNumber ?? hearing.caseId,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                fontFamily: AppTypography.monoFont,
                color: AppColors.ink700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: AppRadius.small,
            ),
            child: Text(
              hearingStatusLabel(context, hearing.status),
              style: AppTypography.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    this.action,
    this.padding = const EdgeInsets.all(AppSpacing.l),
  });

  final String title;
  final Widget child;
  final Widget? action;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.m,
            ),
            child: Row(
              children: [
                Expanded(child: Text(title, style: AppTypography.h3)),
                if (action != null) action!,
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

const _cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: AppRadius.medium,
  border: Border.fromBorderSide(BorderSide(color: AppColors.paperLine)),
  boxShadow: [
    BoxShadow(color: Color(0x0A0B192F), blurRadius: 14, offset: Offset(0, 4)),
  ],
);
