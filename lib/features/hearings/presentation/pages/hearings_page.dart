import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dartz/dartz.dart' hide State;

import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/router/app_route_observer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../cases/domain/entities/case_status.dart';
import '../../../cases/domain/entities/court.dart';
import '../../../cases/domain/entities/legal_case.dart';
import '../../../cases/domain/repository/i_case_repository.dart';
import '../../../cases/presentation/case_display_helpers.dart';
import '../../domain/entities/hearing.dart';
import '../../domain/repository/i_hearing_repository.dart';
import '../hearing_display_helpers.dart';

class HearingsPage extends StatefulWidget {
  const HearingsPage({super.key});

  @override
  State<HearingsPage> createState() => _HearingsPageState();
}

class _HearingsPageState extends State<HearingsPage> with RouteAware {
  late ApiResult<List<Hearing>> _load;

  /// `GET /cases`, so a card can show its Case's court number + year instead
  /// of the internal generated number its own payload carries.
  late final Future<Map<String, LegalCase>> _casesById = loadCasesById();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscribeToAppRouteObserver(context, this);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// A hearing form (or a case's hearing list) was closed: re-read the
  /// hearings, whichever way it was left.
  @override
  void didPopNext() {
    if (mounted) setState(_reload);
  }

  void _reload() => _load = getIt<IHearingRepository>().getHearings();

  bool get _canCreate => currentUserHasPerm(PermissionCodes.hearingCreate);

  /// Schedules a hearing straight from the hearings list (mirrors the web
  /// app's "جدولة جلسة" modal): pick a Case first, then reuse the shared
  /// hearing form, seeded with the chosen case's governorate so its court
  /// cascade opens already scoped.
  Future<void> _openScheduleHearing() async {
    final selectedCase = await showModalBottomSheet<LegalCase>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _CasePickerSheet(),
    );
    if (selectedCase == null || !mounted) return;
    await context.push(
      AppRouter.newHearing(
        caseId: selectedCase.id,
        governorateId: selectedCase.governorateId,
      ),
    );
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserHasPerm(PermissionCodes.hearingView)) {
      return Scaffold(
        body: ErrorView(
          message: context.tr('no_permission_message'),
          isForbidden: true,
          onRetry: () {},
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.paper,
      floatingActionButton: _canCreate
          ? FloatingActionButton.extended(
              onPressed: _openScheduleHearing,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.tr('schedule_hearing')),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('hearings'), style: AppTypography.h2),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<Either<Failure, List<Hearing>>>(
                  future: _load,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return snapshot.data!.fold(
                      (failure) => ErrorView(
                        message: failure.message,
                        onRetry: () => setState(_reload),
                      ),
                      (hearings) => FutureBuilder<Map<String, LegalCase>>(
                        future: _casesById,
                        builder: (context, casesSnapshot) => _buildList(
                          casesSnapshot.data ?? const <String, LegalCase>{},
                          hearings,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    Map<String, LegalCase> casesById,
    List<Hearing> hearings,
  ) {
    if (hearings.isEmpty) {
      return EmptyState(
        icon: Icons.gavel_rounded,
        message: context.tr('no_hearings_found'),
        // Employees receive only hearings on Cases they hold a `hearing.view`
        // grant for, or that are assigned to them directly.
        hint: currentUserIsEmployee()
            ? context.tr('no_shared_records_hint')
            : null,
      );
    }
    final sorted = [...hearings]
      ..sort((left, right) => left.scheduledAt.compareTo(right.scheduledAt));
    final today = DateTime.now();
    final todayCount = sorted.where((hearing) {
      final date = hearing.scheduledAt.toLocal();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.brass100,
            border: Border.all(color: AppColors.brass500.withValues(alpha: .2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.brass800,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('todays_hearings'),
                style: AppTypography.labelLarge,
              ),
              const Spacer(),
              _HearingCount(count: todayCount),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: 9),
            itemBuilder: (context, index) => _HearingCard(
              hearing: sorted[index],
              casesById: casesById,
              onTap: () =>
                  context.go('${AppRouter.cases}/${sorted[index].caseId}'),
            ),
          ),
        ),
      ],
    );
  }
}

class _HearingCard extends StatelessWidget {
  const _HearingCard({
    required this.hearing,
    required this.casesById,
    required this.onTap,
  });
  final Hearing hearing;
  final Map<String, LegalCase> casesById;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = hearingStatusColor(hearing.status);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.ink100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  color: AppColors.ink600,
                  size: 21,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hearing.caseSummary == null
                          ? context.tr('unknown_case')
                          : courtReferenceForSummary(
                              casesById,
                              hearing.caseSummary,
                            ),
                      style: AppTypography.labelLarge.copyWith(
                        fontFamily: AppTypography.monoFont,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hearing.court?.labelFor(
                            Localizations.localeOf(context).languageCode,
                          ) ??
                          context.tr('court_not_selected'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hearing.scheduledAt.toLocal().toString().substring(0, 16),
                      style: AppTypography.bodySmall.copyWith(
                        fontFamily: AppTypography.monoFont,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hearingStatusLabel(context, hearing.status),
                  style: AppTypography.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HearingCount extends StatelessWidget {
  const _HearingCount({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white54,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '$count',
      style: AppTypography.labelMedium.copyWith(color: AppColors.brass800),
    ),
  );
}

/// Case selector shown before scheduling a hearing from the hearings list —
/// the same first step the web app's "جدولة جلسة" modal takes (pick the
/// case, which also drives the court cascade's governorate).
class _CasePickerSheet extends StatefulWidget {
  const _CasePickerSheet();

  @override
  State<_CasePickerSheet> createState() => _CasePickerSheetState();
}

class _CasePickerSheetState extends State<_CasePickerSheet> {
  late ApiResult<List<LegalCase>> _cases;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _cases = getIt<ICaseRepository>().getCases();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.m,
          right: AppSpacing.m,
          top: AppSpacing.m,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.m,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('select_case'), style: AppTypography.h3),
            const SizedBox(height: AppSpacing.m),
            TextField(
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: context.tr('search_cases'),
                prefixIcon: const Icon(Icons.search_rounded, size: 19),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: FutureBuilder<Either<Failure, List<LegalCase>>>(
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
                      onRetry: () {},
                    ),
                    (cases) {
                      // A hearing can only be scheduled on an active case, so
                      // the picker lists active cases only (unlike the web
                      // modal, which offers every case).
                      final filtered = cases
                          .where((c) => c.status == CaseStatus.active)
                          .where((c) {
                            if (_query.isEmpty) return true;
                            return c.caseNumber.toLowerCase().contains(_query) ||
                                legalCaseCourtReference(
                                  c,
                                ).toLowerCase().contains(_query) ||
                                (c.clientSnapshot?.name.toLowerCase().contains(
                                      _query,
                                    ) ??
                                    false);
                          })
                          .toList();
                      if (filtered.isEmpty) {
                        return EmptyState(
                          icon: Icons.business_center_outlined,
                          message: context.tr('no_cases_found'),
                        );
                      }
                      return ListView.separated(
                        controller: scrollController,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.s),
                        itemBuilder: (context, index) {
                          final legalCase = filtered[index];
                          return Material(
                            color: AppColors.paperSoft,
                            borderRadius: AppRadius.medium,
                            child: InkWell(
                              borderRadius: AppRadius.medium,
                              onTap: () =>
                                  Navigator.of(context).pop(legalCase),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.m),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            legalCaseCourtReference(legalCase),
                                            style: AppTypography.labelLarge
                                                .copyWith(
                                                  fontFamily:
                                                      AppTypography.monoFont,
                                                ),
                                          ),
                                          if (legalCase.clientSnapshot !=
                                              null) ...[
                                            const SizedBox(height: 3),
                                            Text(
                                              legalCase
                                                  .clientSnapshot!
                                                  .name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.ink500,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_left_rounded,
                                      color: AppColors.ink300,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
