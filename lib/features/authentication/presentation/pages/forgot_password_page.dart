import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../domain/repository/i_auth_repository.dart';
import '../bloc/password_recovery_cubit.dart';

/// Forgot-password screen (`POST /auth/forgot-password`), mirroring the
/// reference web app's `/forgot-password` page: email in, generic
/// confirmation out. Reachable while signed out, so it is treated as a
/// public route by the auth guard.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key, this.recoveryCubit});

  /// Injectible for tests; the page otherwise owns its cubit so recovery
  /// state never outlives the screen.
  final PasswordRecoveryCubit? recoveryCubit;

  @override
  Widget build(BuildContext context) {
    final cubit =
        recoveryCubit ?? PasswordRecoveryCubit(getIt<IAuthRepository>());
    return BlocProvider.value(value: cubit, child: const _ForgotPasswordView());
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 384),
              child: BlocBuilder<PasswordRecoveryCubit, PasswordRecoveryState>(
                builder: (context, state) {
                  final submitting = state is RecoverySubmitting;
                  final sent = state is RecoveryEmailSent;
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.large,
                      border: Border.all(color: AppColors.paperLine),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.tr('forgot_password'),
                          style: AppTypography.h2,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          context.tr('forgot_password_help'),
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.l),
                        if (sent)
                          _RecoveryBanner(
                            message: context.tr('reset_link_sent'),
                            icon: Icons.mark_email_read_outlined,
                            background: AppColors.brass100,
                            foreground: AppColors.brass700,
                          )
                        else ...[
                          AppTextField(
                            label: context.tr('email_address'),
                            hint: 'example@lawfirm.com',
                            controller: _emailController,
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          if (state is RecoveryFailure) ...[
                            const SizedBox(height: AppSpacing.m),
                            _RecoveryBanner(
                              message: recoveryMessage(
                                context,
                                state.messageKey,
                              ),
                              icon: Icons.error_outline,
                              background: AppColors.rust100,
                              foreground: AppColors.rust600,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.l),
                          AppButton(
                            text: context.tr('send_reset_link'),
                            isLoading: submitting,
                            onPressed: submitting
                                ? null
                                : () => context
                                      .read<PasswordRecoveryCubit>()
                                      .submitForgotPassword(
                                        _emailController.text,
                                      ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.m),
                        TextButton(
                          onPressed: submitting
                              ? null
                              : () => context.go(AppRouter.login),
                          child: Text(context.tr('back_to_login')),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Key → localized copy for the recovery screens. Unknown keys fall through
/// unchanged so a mistyped key is visible in development rather than hidden.
String recoveryMessage(BuildContext context, String key) {
  switch (key) {
    case 'email_required':
      return context.tr('email_required');
    case 'new_password_required':
      return context.tr('new_password_required');
    case 'password_min_length':
      return context.tr('password_min_length');
    case 'password_mismatch':
      return context.tr('password_mismatch');
    case 'invalid_reset_link':
      return context.tr('invalid_reset_link');
    case 'network_error_message':
      return context.tr('network_error_message');
    default:
      return context.tr('recovery_failed');
  }
}

class _RecoveryBanner extends StatelessWidget {
  const _RecoveryBanner({
    required this.message,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String message;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.large,
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
