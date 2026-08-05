import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../di/injection.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../bloc/subscription_reactivation_bloc.dart';

/// App-wide blocking screen for BR-010/012, entered whenever `SessionCubit`
/// reports `SessionSubscriptionInactive` (any 402 from `SubscriptionGuard`
/// — reads included, not just writes, so this is a real blocking screen,
/// not a banner-over-degraded-content one — see API_CONTRACT.md finding
/// M). `AppRouter`'s redirect routes here automatically via a
/// `GoRouterRefreshStream` listening to `SessionCubit`.
///
/// Only `FIRM_ADMIN` users see a self-service "Reactivate" action
/// (`POST /subscriptions/activate`) — everyone else sees an explanatory
/// message only. Confirmed scope with the user (2026-08-05): billing
/// self-service isn't extended to non-admin staff.
class SubscriptionInactivePage extends StatelessWidget {
  const SubscriptionInactivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SubscriptionReactivationBloc>(),
      child: const _SubscriptionInactiveView(),
    );
  }
}

class _SubscriptionInactiveView extends StatelessWidget {
  const _SubscriptionInactiveView();

  @override
  Widget build(BuildContext context) {
    final sessionState = getIt<SessionCubit>().state;
    final isFirmAdmin =
        sessionState is SessionSubscriptionInactive &&
        sessionState.user.isFirmAdmin;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child:
            BlocListener<
              SubscriptionReactivationBloc,
              SubscriptionReactivationState
            >(
              listener: (context, state) {
                if (state is SubscriptionReactivationSuccess) {
                  getIt<SessionCubit>().subscriptionReactivated();
                  if (context.mounted) context.go(AppRouter.home);
                } else if (state is SubscriptionReactivationFailure) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_clock_outlined,
                      size: 64,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Text(
                      context.tr('subscription_inactive_title'),
                      style: AppTypography.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      isFirmAdmin
                          ? context.tr('subscription_inactive_admin_message')
                          : context.tr('subscription_inactive_message'),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isFirmAdmin) ...[
                      const SizedBox(height: AppSpacing.xl),
                      BlocBuilder<
                        SubscriptionReactivationBloc,
                        SubscriptionReactivationState
                      >(
                        builder: (context, state) {
                          return AppButton(
                            text: context.tr('reactivate_subscription'),
                            isLoading:
                                state is SubscriptionReactivationSubmitting,
                            onPressed: () => context
                                .read<SubscriptionReactivationBloc>()
                                .add(SubscriptionReactivationSubmitted()),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
