import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/session_cubit.dart';
import '../bloc/profile_cubit.dart';

/// Profile & preferences: session user identity, appearance
/// (Light/Dark/System — one ThemeBloc, no second provider), language
/// EN/AR with immediate RTL, and sign-out.
///
/// v1 mock content (working-hours card, notification toggles, biometric /
/// two-factor placeholders, privacy/terms links) was removed per the v2
/// PRD Settings scope — security is limited to a real password change via
/// Settings, and notification preferences are not a v2 feature.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(context.tr('profile')),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(context),
                  const SizedBox(height: AppSpacing.l),
                  _buildSectionHeader(context.tr('appearance').toUpperCase()),
                  _buildSettingsGroup([
                    const _ThemePicker(),
                  ]),
                  const SizedBox(height: AppSpacing.l),
                  _buildSectionHeader(
                      context.tr('app_language').toUpperCase()),
                  _buildSettingsGroup([
                    _buildLanguageSwitcher(context),
                  ]),
                  const SizedBox(height: AppSpacing.l),
                  _buildSectionHeader(context.tr('security').toUpperCase()),
                  _buildSettingsGroup([
                    _buildLinkRow(
                      context,
                      context.tr('change_password'),
                      icon: Icons.shield_outlined,
                      onTap: () => context.push('/settings'),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.l),
                  _buildSignOutButton(context),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, session) {
        final user = session is SessionAuthenticated ? session.user : null;
        final parsedInitials = (user?.fullName ?? '')
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();
        final initials = parsedInitials.isEmpty ? '?' : parsedInitials;
        return Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.medium,
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: AppRadius.medium,
                      child: Image.network(
                        user.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.fullName ?? context.tr('unnamed_employee'),
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          fontSize: 10,
          letterSpacing: 1.2,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.paperLine),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final isArabic = state.locale.languageCode == 'ar';
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              const Icon(Icons.language, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('app_language'),
                        style: AppTypography.bodyMedium),
                    const SizedBox(height: 2),
                    Text(
                      isArabic ? 'العربية' : 'English',
                      style: AppTypography.bodySmall.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.read<ProfileCubit>().toggleLocale(),
                style: TextButton.styleFrom(
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  isArabic
                      ? context.tr('switch_to_english')
                      : context.tr('switch_to_arabic'),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLinkRow(
    BuildContext context,
    String title, {
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.m),
            ],
            Expanded(child: Text(title, style: AppTypography.bodyMedium)),
            const Icon(Icons.chevron_left,
                size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return AppButton(
      text: context.tr('sign_out'),
      icon: Icons.logout,
      onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
      style: AppButtonStyle.secondary,
    );
  }
}

/// Light / Dark / System — driven by the app's single [ProfileCubit]
/// (which wraps the shared ThemeBloc). Segmented control mirrors the
/// reference design's three-way appearance choice; there is no second
/// theme state anywhere.
class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        Widget option(ThemeMode mode, IconData icon, String label) {
          final selected = state.themeMode == mode;
          return Expanded(
            child: InkWell(
              onTap: () =>
                  context.read<ProfileCubit>().setThemeMode(mode),
              borderRadius: AppRadius.small,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.brass100
                      : Colors.transparent,
                  borderRadius: AppRadius.small,
                  border: selected
                      ? Border.all(color: AppColors.brass500)
                      : Border.all(color: Colors.transparent),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: selected
                          ? AppColors.brass800
                          : AppColors.textHint,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: AppTypography.bodySmall.copyWith(
                        color: selected
                            ? AppColors.brass800
                            : AppColors.textHint,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              option(ThemeMode.light, Icons.light_mode_outlined,
                  context.tr('theme_light')),
              const SizedBox(width: AppSpacing.s),
              option(ThemeMode.dark, Icons.dark_mode_outlined,
                  context.tr('theme_dark')),
              const SizedBox(width: AppSpacing.s),
              option(ThemeMode.system, Icons.settings_suggest_outlined,
                  context.tr('theme_system')),
            ],
          ),
        );
      },
    );
  }
}
