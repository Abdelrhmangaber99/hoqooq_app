import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/firm_display_helpers.dart';
import '../bloc/subscription_cubit.dart';
import '../bloc/subscription_state.dart';

/// Read-only subscription & firm view. The subscription in effect and all
/// firm data come from the shared [SubscriptionCubit] — the same singleton
/// stream the settings page and the main-layout sidebar observe — so a plan
/// change, activation, or cancellation performed on the platform side (or a
/// firm-info save in settings) is reflected here the moment the cubit's
/// state updates. No local duplicate fetch, no manual refresh.
///
/// Per the PRD and the reference web app, plan/cycle changes and
/// activate/deactivate are platform (`system.subscriptions.manage`)
/// operations done by the Super Admin on the Firms page — this page never
/// offers them, so no disabled/dead buttons are exposed here.
class SubscriptionInfoPage extends StatefulWidget {
  const SubscriptionInfoPage({super.key, this.subscriptionCubit});

  final SubscriptionCubit? subscriptionCubit;

  @override
  State<SubscriptionInfoPage> createState() => _SubscriptionInfoPageState();
}

class _SubscriptionInfoPageState extends State<SubscriptionInfoPage> {
  late final SubscriptionCubit _cubit =
      widget.subscriptionCubit ?? getIt<SubscriptionCubit>();

  @override
  void initState() {
    super.initState();
    // Re-read on entry so a plan change or cancellation performed outside
    // this screen (platform admin console, another session) is reflected
    // here the moment it opens. Quiet: the already-loaded data stays on
    // screen while the authoritative payload is fetched.
    _cubit.refreshQuietly();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = _cubit;
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(context.tr('subscription'))),
        body: SafeArea(
          child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
            builder: (context, state) {
              if (state is SubscriptionLoading ||
                  state is SubscriptionInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is SubscriptionError) {
                return ErrorView(
                  message: state.message,
                  onRetry: () => cubit.fetchSubscription(),
                );
              }
              final loaded = state as SubscriptionLoaded;
              return _buildContent(context, loaded);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SubscriptionLoaded state) {
    final firm = state.firm;
    final activeSubscription = state.activeSubscription;
    final plan = activeSubscription?['plan'] as Map?;

    if (activeSubscription == null &&
        (firm['subscriptions'] as List?) == null) {
      return const EmptyState(message: 'لا توجد بيانات اشتراك');
    }

    final currencyFmt = NumberFormat.currency(
      symbol: '${context.tr('currency_sar').trim()} ',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 448),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan card — mirrors the reference app's Subscription page:
            // brass-tinted plan block, status block, firm rows.
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.large,
                border: Border.all(color: AppColors.paperLine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (plan != null && activeSubscription != null) ...[
                    _planBlock(context, plan, activeSubscription, currencyFmt),
                    const SizedBox(height: AppSpacing.m),
                  ] else ...[
                    _noPlanBlock(context),
                    const SizedBox(height: AppSpacing.m),
                  ],
                  if (activeSubscription != null) ...[
                    _statusBlock(context, activeSubscription),
                    const SizedBox(height: AppSpacing.l),
                  ],
                  Text(
                    context.tr('subscribed_firm_details'),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _buildInfoRow(
                    context,
                    Icons.business_outlined,
                    context.tr('firm_name'),
                    firm['name'] as String? ?? '—',
                  ),
                  const SizedBox(height: AppSpacing.m),
                  _buildInfoRow(
                    context,
                    Icons.email_outlined,
                    context.tr('email_address'),
                    firm['contactEmail'] as String? ?? '—',
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: AppSpacing.l),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.m),
                      decoration: BoxDecoration(
                        color: AppColors.rust100,
                        borderRadius: AppRadius.large,
                      ),
                      child: Text(
                        state.error!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.rust600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planBlock(
    BuildContext context,
    Map<dynamic, dynamic> plan,
    Map<String, dynamic> subscription,
    NumberFormat currencyFmt,
  ) {
    final billingCycle = subscription['billingCycle'] as String? ?? 'MONTHLY';
    final price = billingCycle == 'YEARLY'
        ? plan['priceYearly']
        : plan['priceMonthly'];
    final cycleLabel = billingCycle == 'YEARLY'
        ? context.tr('yearly')
        : context.tr('monthly');
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.brass100,
        borderRadius: AppRadius.small,
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.brass700),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan['name'] as String? ?? context.tr('plan'),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.brass800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${currencyFmt.format((price as num?)?.toDouble() ?? 0)} / $cycleLabel',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.brass800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noPlanBlock(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.paperSoft,
        borderRadius: AppRadius.small,
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, color: AppColors.textHint),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              context.tr('no_active_plan'),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBlock(BuildContext context, Map<String, dynamic> subscription) {
    final status = (subscription['status'] as String? ?? 'INACTIVE')
        .toUpperCase();
    final isActive = status == 'ACTIVE';
    final color = isActive ? AppColors.emerald600 : AppColors.brass700;
    final background = isActive ? AppColors.emerald100 : AppColors.brass100;
    final periodEnd = subscription['currentPeriodEnd'] != null
        ? DateTime.tryParse(subscription['currentPeriodEnd'] as String)
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.small,
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle_outline : Icons.timer_outlined,
            color: color,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscriptionStatusLabel(context, status),
                  style: AppTypography.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (periodEnd != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${context.tr('subscription_ends_on')} ${DateFormat.yMd(Localizations.localeOf(context).languageCode).format(periodEnd)}',
                    style: AppTypography.bodySmall.copyWith(color: color),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
