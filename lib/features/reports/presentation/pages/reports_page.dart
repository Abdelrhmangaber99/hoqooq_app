import 'dart:math' as math;

import 'package:dartz/dartz.dart' hide State;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../cases/domain/entities/legal_case.dart';
import '../../../cases/domain/repository/i_case_repository.dart';
import '../../../cases/presentation/case_display_helpers.dart';
import '../../../employees/data/models/employee_summary.dart';
import '../../../finance/domain/entities/case_finance_status.dart';
import '../../../finance/domain/entities/finance_summary.dart';
import '../../../finance/domain/repository/i_finance_repository.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';

/// التقارير (Reports) — mirrors the reference web app's `FinanceReports.jsx`:
/// three tabs over three existing endpoints.
///
/// * القضايا — `GET /cases` (permission `case.view`).
/// * المالية — `GET /finance/summary` (permission `finance.firm.read`),
///   reusing the same firm-wide aggregates the Finance screen shows.
/// * الموظفين — `GET /employees` (permission `employee.read`).
///
/// No new endpoints are introduced; the page is a read-only aggregation.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _tab = 0;

  bool get _isFirmAdmin {
    final session = getIt<SessionCubit>().state;
    return session is SessionAuthenticated && session.user.isFirmAdmin;
  }

  bool get _canViewReports =>
      _isFirmAdmin ||
      currentUserHasPerm(PermissionCodes.financeFirmRead) ||
      currentUserHasPerm(PermissionCodes.reportOperationalRead);

  @override
  Widget build(BuildContext context) {
    if (!_canViewReports) {
      return Scaffold(
        backgroundColor: AppColors.paper,
        body: SafeArea(
          child: ErrorView(
            message: context.tr('no_permission_message'),
            isForbidden: true,
            onRetry: () {},
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('reports'), style: AppTypography.h1),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  _TabChip(
                    label: context.tr('cases'),
                    selected: _tab == 0,
                    onTap: () => setState(() => _tab = 0),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  _TabChip(
                    label: context.tr('finance'),
                    selected: _tab == 1,
                    onTap: () => setState(() => _tab = 1),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  _TabChip(
                    label: context.tr('employees'),
                    selected: _tab == 2,
                    onTap: () => setState(() => _tab = 2),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              Expanded(
                child: switch (_tab) {
                  0 => const _CasesReportTab(),
                  1 => const _FinanceReportTab(),
                  _ => const _EmployeesReportTab(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink800 : AppColors.surface,
      borderRadius: AppRadius.small,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.small,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.ink800 : AppColors.paperLine,
            ),
            borderRadius: AppRadius.small,
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: selected ? Colors.white : AppColors.ink500,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// القضايا
// ---------------------------------------------------------------------------

class _CasesReportTab extends StatefulWidget {
  const _CasesReportTab();

  @override
  State<_CasesReportTab> createState() => _CasesReportTabState();
}

class _CasesReportTabState extends State<_CasesReportTab> {
  late ApiResult<List<LegalCase>> _cases;

  @override
  void initState() {
    super.initState();
    _cases = getIt<ICaseRepository>().getCases();
  }

  void _reload() => setState(() => _cases = getIt<ICaseRepository>().getCases());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<Failure, List<LegalCase>>>(
      future: _cases,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return snapshot.data!.fold(
          (failure) => ErrorView(
            message: failure.message,
            isForbidden: failure is ForbiddenFailure,
            onRetry: _reload,
          ),
          (cases) {
            if (cases.isEmpty) {
              return EmptyState(
                icon: Icons.assignment_outlined,
                message: context.tr('no_cases_found'),
              );
            }
            return ListView.separated(
              itemCount: cases.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.s),
              itemBuilder: (context, index) => _ReportRow(
                leading: _ReportRowIcon(
                  icon: Icons.business_center_outlined,
                ),
                title: caseDisplayName(cases[index]),
                subtitle: <String>[
                  cases[index].clientSnapshot?.name ?? '',
                  legalCaseCourtReference(cases[index]),
                ].where((v) => v.trim().isNotEmpty).join(' • '),
                trailing: _Pill(
                  label: caseStatusLabel(context, cases[index].status),
                  color: caseStatusColor(cases[index].status),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// المالية
// ---------------------------------------------------------------------------

class _FinanceReportTab extends StatefulWidget {
  const _FinanceReportTab();

  @override
  State<_FinanceReportTab> createState() => _FinanceReportTabState();
}

class _FinanceReportTabState extends State<_FinanceReportTab> {
  late ApiResult<FinanceSummary>? _summary;

  /// `/finance/summary` rows carry only caseId/caseNumber; resolve the case's
  /// name from `/cases` so the top-outstanding chart reads as names.
  late final Future<Map<String, LegalCase>> _casesById = _loadCasesById();

  bool get _canViewFinance => currentUserHasPerm(PermissionCodes.financeFirmRead);

  Future<Map<String, LegalCase>> _loadCasesById() async {
    final result = await getIt<ICaseRepository>().getCases();
    return result.fold(
      (_) => const {},
      (cases) => {for (final legalCase in cases) legalCase.id: legalCase},
    );
  }

  @override
  void initState() {
    super.initState();
    _summary = _canViewFinance
        ? getIt<IFinanceRepository>().getSummary()
        : null;
  }

  void _reload() => setState(
    () => _summary = getIt<IFinanceRepository>().getSummary(),
  );

  @override
  Widget build(BuildContext context) {
    if (!_canViewFinance) {
      return EmptyState(message: context.tr('no_finance_permission'));
    }
    return FutureBuilder<Either<Failure, FinanceSummary>>(
      future: _summary,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return snapshot.data!.fold(
          (failure) => ErrorView(
            message: failure.message,
            isForbidden: failure is ForbiddenFailure,
            onRetry: _reload,
          ),
          (summary) => FutureBuilder<Map<String, LegalCase>>(
            future: _casesById,
            builder: (context, casesSnapshot) =>
                _buildSummary(summary, casesSnapshot.data ?? const {}),
          ),
        );
      },
    );
  }

  Widget _buildSummary(
    FinanceSummary summary,
    Map<String, LegalCase> casesById,
  ) {
    final cases = summary.cases
        .where((c) => c.agreedFee > 0)
        .toList()
      ..sort((a, b) => b.remaining.compareTo(a.remaining));
    final topOutstanding = cases.take(5).toList();
    final statusSegments = [
      _DonutSegment(
        label: caseFinanceStatusLabel(context, CaseFinanceStatus.paid),
        value: summary.paidCases,
        color: AppColors.emerald500,
      ),
      _DonutSegment(
        label: caseFinanceStatusLabel(context, CaseFinanceStatus.partial),
        value: summary.partialCases,
        color: AppColors.brass500,
      ),
      _DonutSegment(
        label: caseFinanceStatusLabel(context, CaseFinanceStatus.unpaid),
        value: summary.unpaidCases,
        color: AppColors.rust500,
      ),
    ];
    final currencyFmt = NumberFormat.currency(
      symbol: '${context.tr('currency_sar').trim()} ',
      decimalDigits: 0,
    );

    return ListView(
      children: [
        Row(
          children: [
            _KpiCard(
              label: context.tr('total_case_value'),
              value: currencyFmt.format(summary.totalCaseValue),
              color: AppColors.ink800,
            ),
            const SizedBox(width: AppSpacing.s),
            _KpiCard(
              label: context.tr('total_collected'),
              value: currencyFmt.format(summary.totalCollected),
              color: AppColors.emerald500,
            ),
            const SizedBox(width: AppSpacing.s),
            _KpiCard(
              label: context.tr('total_outstanding'),
              value: currencyFmt.format(summary.totalOutstanding),
              color: AppColors.rust500,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          context.tr('case_payment_status_breakdown'),
          style: AppTypography.h3,
        ),
        const SizedBox(height: AppSpacing.s),
        if (statusSegments.every((segment) => segment.value == 0))
          EmptyState(message: context.tr('no_financial_data'))
        else
          _SectionCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
              child: _PaymentStatusChart(segments: statusSegments),
            ),
          ),
        const SizedBox(height: AppSpacing.l),
        Text(context.tr('top_outstanding_cases'), style: AppTypography.h3),
        const SizedBox(height: AppSpacing.s),
        if (topOutstanding.isEmpty)
          EmptyState(message: context.tr('no_financial_data'))
        else
          _SectionCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
              child: _TopOutstandingChart(
                rows: topOutstanding,
                names: {
                  for (final row in topOutstanding)
                    row.caseId: casesById[row.caseId] == null
                        ? row.caseNumber
                        : legalCaseCourtReference(casesById[row.caseId]!),
                },
                currencyFmt: currencyFmt,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.l),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.paperLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                maxLines: 1,
                style: AppTypography.h3.copyWith(
                  color: color,
                  fontFamily: AppTypography.monoFont,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutSegment {
  const _DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

/// Payment-status doughnut — the Flutter equivalent of the reference web
/// page's Recharts doughnut (same three statuses, same colors). Drawn with a
/// [CustomPainter] so no charting dependency is pulled into the app for one
/// chart.
class _PaymentStatusChart extends StatelessWidget {
  const _PaymentStatusChart({required this.segments});

  final List<_DonutSegment> segments;

  static const double _diameter = 138;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<int>(0, (sum, segment) => sum + segment.value);
    return Row(
      children: [
        SizedBox(
          width: _diameter,
          height: _diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size.square(_diameter),
                painter: _DonutPainter(segments: segments),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$total',
                    style: AppTypography.h2.copyWith(
                      fontFamily: AppTypography.monoFont,
                    ),
                  ),
                  Text(context.tr('cases'), style: AppTypography.bodySmall),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final segment in segments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: segment.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          segment.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.ink600,
                          ),
                        ),
                      ),
                      Text(
                        '${segment.value}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontFamily: AppTypography.monoFont,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments});

  final List<_DonutSegment> segments;

  static const double _strokeWidth = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<int>(0, (sum, segment) => sum + segment.value);
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - _strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    if (total <= 0) {
      paint.color = AppColors.ink100;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    // Start at 12 o'clock and sweep clockwise, inserting a thin white gap
    // between slices like the web doughnut's `paddingAngle`.
    const gap = 0.03;
    var start = -math.pi / 2;
    for (final segment in segments) {
      if (segment.value <= 0) continue;
      final sweep = (segment.value / total) * 2 * math.pi;
      paint.color = segment.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start + gap / 2,
        math.max(sweep - gap, gap / 2),
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.segments != segments;
}

/// Top outstanding cases — the Flutter equivalent of the web page's Recharts
/// horizontal bar chart (case number + amount, longest bar = most owed).
class _TopOutstandingChart extends StatelessWidget {
  const _TopOutstandingChart({
    required this.rows,
    required this.names,
    required this.currencyFmt,
  });

  final List<CaseFinanceSummaryRow> rows;
  final Map<String, String> names;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    final maxRemaining = rows.fold<double>(
      0,
      (max, row) => row.remaining > max ? row.remaining : max,
    );
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == rows.length - 1 ? 0 : AppSpacing.m,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        names[rows[i].caseId] ?? rows[i].caseNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.ink700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currencyFmt.format(rows[i].remaining),
                      style: AppTypography.bodySmall.copyWith(
                        color: i == 0 ? AppColors.ink800 : AppColors.brass700,
                        fontFamily: AppTypography.monoFont,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fraction = maxRemaining <= 0
                        ? 0.0
                        : (rows[i].remaining / maxRemaining).clamp(0.0, 1.0);
                    return Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.ink50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 8,
                          width: constraints.maxWidth * fraction,
                          decoration: BoxDecoration(
                            color: i == 0
                                ? AppColors.ink800
                                : AppColors.brass500,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// الموظفين
// ---------------------------------------------------------------------------

class _EmployeesReportTab extends StatefulWidget {
  const _EmployeesReportTab();

  @override
  State<_EmployeesReportTab> createState() => _EmployeesReportTabState();
}

class _EmployeesReportTabState extends State<_EmployeesReportTab> {
  late Future<List<EmployeeSummary>>? _employees;

  bool get _canViewEmployees =>
      currentUserHasPerm(PermissionCodes.employeeRead);

  @override
  void initState() {
    super.initState();
    _employees = _canViewEmployees ? _loadEmployees() : null;
  }

  void _reload() => setState(() => _employees = _loadEmployees());

  Future<List<EmployeeSummary>> _loadEmployees() async {
    final response = await getIt<Dio>().get('/employees');
    final rows = response.data as List<dynamic>;
    return rows
        .map((row) => EmployeeSummary.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!_canViewEmployees) {
      return EmptyState(message: context.tr('employee_read_permission_required'));
    }
    return FutureBuilder<List<EmployeeSummary>>(
      future: _employees,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(
            message: context.tr('could_not_load_employees'),
            onRetry: _reload,
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final employees = snapshot.data!;
        if (employees.isEmpty) {
          return EmptyState(
            icon: Icons.groups_outlined,
            message: context.tr('no_employees_found'),
          );
        }
        return ListView.separated(
          itemCount: employees.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
          itemBuilder: (context, index) {
            final employee = employees[index];
            return _ReportRow(
              leading: _ReportRowIcon(
                icon: Icons.person_outline_rounded,
                label: employee.name,
              ),
              title: employee.name.isEmpty
                  ? context.tr('unnamed_employee')
                  : employee.name,
              subtitle: <String>[
                employee.email,
                employee.positionLabel,
              ].where((v) => v.trim().isNotEmpty).join(' • '),
              trailing: _Pill(
                label: employee.isActive
                    ? context.tr('active')
                    : context.tr('inactive'),
                color: employee.isActive
                    ? AppColors.emerald500
                    : AppColors.textSecondary,
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared row building blocks
// ---------------------------------------------------------------------------

class _ReportRowIcon extends StatelessWidget {
  const _ReportRowIcon({required this.icon, this.label});

  final IconData icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final initial = (label ?? '').trim();
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.ink100,
        borderRadius: AppRadius.small,
      ),
      child: initial.isEmpty
          ? Icon(icon, size: 19, color: AppColors.ink600)
          : Text(
              initial.characters.first.toUpperCase(),
              style: AppTypography.labelLarge.copyWith(color: AppColors.ink600),
            ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.paperLine),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.ink500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.s),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: AppTypography.bodySmall.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.medium,
      border: Border.all(color: AppColors.paperLine),
    ),
    child: child,
  );
}
