import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dartz/dartz.dart' hide State;

import '../../../../core/auth/permission_check.dart';
import '../../../../core/auth/permission_codes.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/hearing.dart';
import '../../domain/repository/i_hearing_repository.dart';
import '../hearing_display_helpers.dart';

class HearingsPage extends StatefulWidget {
  const HearingsPage({super.key});

  @override
  State<HearingsPage> createState() => _HearingsPageState();
}

class _HearingsPageState extends State<HearingsPage> {
  late ApiResult<List<Hearing>> _load;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _load = getIt<IHearingRepository>().getHearings();

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
                      _buildList,
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

  Widget _buildList(List<Hearing> hearings) {
    if (hearings.isEmpty) {
      return EmptyState(
        icon: Icons.gavel_rounded,
        message: context.tr('no_hearings_found'),
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
  const _HearingCard({required this.hearing, required this.onTap});
  final Hearing hearing;
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
                      hearing.caseSummary?.caseNumber ?? context.tr('unknown_case'),
                      style: AppTypography.labelLarge.copyWith(
                        fontFamily: AppTypography.monoFont,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hearing.court?.name ?? context.tr('court_not_selected'),
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
