import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../domain/repository/i_auth_repository.dart';
import '../bloc/account_activation_cubit.dart';
import '../bloc/session_cubit.dart';

/// Account activation screen (`POST /auth/activate`), reached when a Firm Admin
/// or Employee opens their activation link (`/activate?token=...`).
class ActivateAccountPage extends StatelessWidget {
  const ActivateAccountPage({
    super.key,
    required this.token,
    this.activationCubit,
  });

  final String token;
  final AccountActivationCubit? activationCubit;

  @override
  Widget build(BuildContext context) {
    final cubit =
        activationCubit ?? AccountActivationCubit(getIt<IAuthRepository>());
    return BlocProvider.value(
      value: cubit,
      child: _ActivateAccountView(token: token),
    );
  }
}

class _ActivateAccountView extends StatefulWidget {
  const _ActivateAccountView({required this.token});

  final String token;

  @override
  State<_ActivateAccountView> createState() => _ActivateAccountViewState();
}

class _ActivateAccountViewState extends State<_ActivateAccountView> {
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

  void _handleSuccess(
    BuildContext context,
    AccountActivationSuccess state,
  ) async {
    final authResponse = state.authResponse;
    if (authResponse != null) {
      // Auto-login if backend returned tokens
      await getIt<TokenStorage>().saveRefreshToken(authResponse.refreshToken);
      if (context.mounted) {
        getIt<SessionCubit>().updateAccessToken(authResponse.accessToken);
        final userResult = await getIt<IAuthRepository>().getCurrentUser();
        if (context.mounted) {
          userResult.fold(
            (_) => context.go(AppRouter.login),
            (user) {
              getIt<SessionCubit>().updateUser(user);
              final targetRoute =
                  user.isSuperAdmin ? AppRouter.firms : AppRouter.home;
              context.go(targetRoute);
            },
          );
        }
      }
    }
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
              child: BlocConsumer<AccountActivationCubit, AccountActivationState>(
                listener: (context, state) {
                  if (state is AccountActivationSuccess) {
                    _handleSuccess(context, state);
                  }
                },
                builder: (context, state) {
                  final submitting = state is AccountActivationSubmitting;
                  final done = state is AccountActivationSuccess;
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
                          context.tr('activate_account'),
                          style: AppTypography.h2,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          context.tr('activation_help'),
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.l),
                        if (!_hasToken) ...[
                          _banner(
                            context,
                            message: context.tr('invalid_activation_link'),
                            icon: Icons.link_off_rounded,
                            background: AppColors.rust100,
                            foreground: AppColors.rust600,
                          ),
                        ] else if (done && state.authResponse == null) ...[
                          _banner(
                            context,
                            message: context.tr('account_activated_success'),
                            icon: Icons.check_circle_outline,
                            background: AppColors.brass100,
                            foreground: AppColors.brass700,
                          ),
                          const SizedBox(height: AppSpacing.l),
                          AppButton(
                            text: context.tr('back_to_login'),
                            onPressed: () => context.go(AppRouter.login),
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
                          if (state is AccountActivationFailure) ...[
                            const SizedBox(height: AppSpacing.m),
                            _banner(
                              context,
                              message: context.tr(state.messageKey),
                              icon: Icons.error_outline,
                              background: AppColors.rust100,
                              foreground: AppColors.rust600,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.l),
                          AppButton(
                            text: context.tr('activate_account'),
                            isLoading: submitting,
                            onPressed: submitting
                                ? null
                                : () => context
                                      .read<AccountActivationCubit>()
                                      .submitActivation(
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
