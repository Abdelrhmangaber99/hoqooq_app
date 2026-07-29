import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';

class ClientProfilePage extends StatelessWidget {
  const ClientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('client_profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: AppSpacing.l),
            _buildContactInfo(context),
            const SizedBox(height: AppSpacing.l),
            _buildSectionHeader(context.tr('active_cases'), badge: '2 cases'),
            const SizedBox(height: AppSpacing.m),
            _buildCaseItem('Hernandez v. State', '#2026-CR-4471', context.tr('active'), 'Criminal'),
            const SizedBox(height: AppSpacing.m),
            _buildCaseItem('Hernandez Property', '#2025-CV-3812', context.tr('active'), 'Civil'),
            const SizedBox(height: AppSpacing.l),
            _buildSectionHeader(context.tr('recent_appointments')),
            const SizedBox(height: AppSpacing.m),
            // ... more components
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Text(
                'CH',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text('Carlos Hernandez', style: AppTypography.h2),
          const SizedBox(height: 4),
          Text('Criminal Defense', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Client since 2024', style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontSize: 10)),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              _buildActionButton(Icons.phone_outlined, context.tr('call')),
              const SizedBox(width: 12),
              _buildActionButton(Icons.email_outlined, context.tr('email')),
              const SizedBox(width: 12),
              _buildActionButton(Icons.calendar_today_outlined, context.tr('book'), isPrimary: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {bool isPrimary = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.medium,
          border: isPrimary ? null : Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isPrimary ? Colors.black : AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isPrimary ? Colors.black : AppColors.primary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.phone_outlined, context.tr('phone'), '+1 (212) 555-0147'),
          const Divider(color: AppColors.surfaceLight, height: 24),
          _buildInfoRow(Icons.email_outlined, context.tr('email').toUpperCase(), 'carlos@hernandez.com'),
          const Divider(color: AppColors.surfaceLight, height: 24),
          _buildInfoRow(Icons.location_on_outlined, context.tr('address'), '88 Canal St, New York, NY'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.m),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.labelMedium.copyWith(fontSize: 10, color: AppColors.textHint)),
            const SizedBox(height: 2),
            Text(value, style: AppTypography.bodyMedium),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? badge}) {
    return Row(
      children: [
        Text(title, style: AppTypography.h3),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Text(
            badge,
            style: AppTypography.bodySmall.copyWith(color: AppColors.primary, fontSize: 10),
          ),
        ],
      ],
    );
  }

  Widget _buildCaseItem(String title, String id, String status, String type) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.labelLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
              Text(type, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
