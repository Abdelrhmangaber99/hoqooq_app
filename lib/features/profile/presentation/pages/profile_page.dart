import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import '../../../../core/localization/locale_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(context),
              const SizedBox(height: AppSpacing.l),
              _buildSectionHeader(context.tr('WORKING HOURS')),
              _buildHoursCard(),
              const SizedBox(height: AppSpacing.l),
              _buildSectionHeader(context.tr('app_language').toUpperCase()),
              _buildSettingsGroup([
                _buildLanguageSwitcher(context),
              ]),
              const SizedBox(height: AppSpacing.l),
              _buildSectionHeader(context.tr('notifications').toUpperCase()),
              _buildSettingsGroup([
                _buildToggleRow(context.tr('hearing_reminders'), context.tr('before_court_appearance'), true),
                _buildToggleRow(context.tr('deadline_alerts'), context.tr('filing_response_deadlines'), true),
                _buildToggleRow(context.tr('appointment_reminders'), context.tr('client_meeting_reminders'), false),
              ]),
              const SizedBox(height: AppSpacing.l),
              _buildSectionHeader(context.tr('appearance').toUpperCase()),
              _buildSettingsGroup([
                _buildToggleRow(context.tr('dark_mode'), 'Dark theme active', true, icon: Icons.dark_mode_outlined),
              ]),
              const SizedBox(height: AppSpacing.l),
              _buildSectionHeader(context.tr('security').toUpperCase()),
              _buildSettingsGroup([
                _buildToggleRow(context.tr('biometric_login'), context.tr('face_id_touch_id'), true, icon: Icons.smartphone_outlined),
                _buildLinkRow(context.tr('change_password'), icon: Icons.shield_outlined),
                _buildLinkRow(context.tr('two_factor_auth'), icon: Icons.lock_outline, status: context.tr('on')),
              ]),
              const SizedBox(height: AppSpacing.l),
              _buildSettingsGroup([
                _buildLinkRow(context.tr('privacy_policy'), icon: Icons.description_outlined),
                _buildLinkRow(context.tr('terms_of_service'), icon: Icons.menu_book_outlined),
                _buildLinkRow(context.tr('help_support'), icon: Icons.help_outline),
              ]),
              const SizedBox(height: AppSpacing.l),
              _buildSignOutButton(context),
              const SizedBox(height: AppSpacing.l),
              Center(
                child: Text(
                  'Lexora v2.4.1 · © 2026 Lexora Legal Technologies',
                  style: AppTypography.bodySmall.copyWith(fontSize: 10),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.medium,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Text(
              'JR',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('james_reynolds'), style: AppTypography.h3),
              const SizedBox(height: 2),
              Text(
                '${context.tr('senior_partner')} · ${context.tr('law_firm_name')}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                'james.reynolds@lexora.com',
                style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(fontSize: 10, letterSpacing: 1.2, color: AppColors.textHint),
      ),
    );
  }

  Widget _buildHoursCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Column(
        children: [
          _buildHoursRow('Mon – Fri', '9:00 AM – 6:00 PM', isHighlight: true),
          const Divider(color: AppColors.surfaceLight, height: 24),
          _buildHoursRow('Saturday', '10:00 AM – 2:00 PM', isHighlight: true),
          const Divider(color: AppColors.surfaceLight, height: 24),
          _buildHoursRow('Sunday', 'Closed'),
        ],
      ),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
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
                    Text(context.tr('app_language'), style: AppTypography.bodyMedium),
                    const SizedBox(height: 2),
                    Text(
                      isArabic ? 'العربية' : 'English',
                      style: AppTypography.bodySmall.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<LocaleBloc>().add(ToggleLocaleEvent());
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  isArabic ? context.tr('switch_to_english') : context.tr('switch_to_arabic'),
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

  Widget _buildHoursRow(String day, String time, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: AppTypography.bodyMedium),
        Text(
          time,
          style: AppTypography.bodyMedium.copyWith(
            color: isHighlight ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.m),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) {},
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textHint,
            inactiveTrackColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(String title, {IconData? icon, String? status}) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.m),
          ],
          Text(title, style: AppTypography.bodyMedium),
          const Spacer(),
          if (status != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(status, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
            ),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.textHint),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: AppRadius.medium,
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Text(
            context.tr('sign_out'),
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
