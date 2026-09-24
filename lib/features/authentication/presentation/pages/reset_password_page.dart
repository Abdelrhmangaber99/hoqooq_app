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
import 'forgot_password_page.dart' show recoveryMessage;

/// Reset-password screen (`POST /auth/reset-password`), the second half of
/// the recovery flow the reference web app serves at `/reset-password`.
///
/// [token] comes from the emailed link's query string. A missing token is
/// not an error the user caused — the screen says the link is invalid and
/// keeps the submit disabled rather than posting an empty token.
class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key, required this.token, this.recoveryCubit});

  final String token;

  /// Injectible for tests.
  final PasswordRecoveryCubit? recoveryCubit;

  @override
  Widget build(BuildContext context) {
    final cubit =
        recoveryCubit ?? PasswordRecoveryCubit(getIt<IAuthRepository>());
    return BlocProvider.value(
      value: cubit,
      child: _ResetPasswordView(token: token),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView({required this.token});

  final String token;

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  bool get _hasToken => widget.token.isNotEmpty;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
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
                  final done = state is RecoveryPasswordReset;
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
                          context.tr('set_new_password'),
                          style: AppTypography.h2,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          context.tr('reset_password_help'),
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.l),
                        if (!_hasToken) ...[
                          _banner(
                            context,
                            message: context.tr('invalid_reset_link'),
                            icon: Icons.link_off_rounded,
                            background: AppColors.rust100,
                            foreground: AppColors.rust600,
                          ),
                        ] else if (done) ...[
                          _banner(
                            context,
                            message: context.tr('password_reset_success'),
                            icon: Icons.check_circle_outline,
                            background: AppColors.brass100,
                            foreground: AppColors.brass700,
                          ),
                        ] else ...[
                          AppTextField(
                            label: context.tr('new_password'),
                            controller: _passwordController,
                            obscureText: _obscure,
                            keyboardType: TextInputType.visiblePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.ink300,
                                size: 19,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          AppTextField(
                            label: context.tr('confirm_new_password'),
                            controller: _confirmController,
                            obscureText: _obscure,
                            keyboardType: TextInputType.visiblePassword,
                          ),
                          if (state is RecoveryFailure) ...[
                            const SizedBox(height: AppSpacing.m),
                            _banner(
                              context,
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
                            text: context.tr('update_password'),
                            isLoading: submitting,
                            onPressed: submitting
                                ? null
                                : () => context
                                      .read<PasswordRecoveryCubit>()
                                      .submitResetPassword(
                                        token: widget.token,
                                        newPassword: _passwordController.text,
                                        confirmPassword:
                                            _confirmController.text,
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

  Widget _banner(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color background,
    required Color foreground,
  }) {
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
