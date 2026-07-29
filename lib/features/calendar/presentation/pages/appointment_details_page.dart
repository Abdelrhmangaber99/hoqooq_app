import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';

class AppointmentDetailsPage extends StatelessWidget {
  const AppointmentDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('calendar')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainCard(context),
            const SizedBox(height: AppSpacing.l),
            _buildInfoTiles(context),
            const SizedBox(height: AppSpacing.l),
            _buildSectionHeader(context.tr('notes')),
            _buildNotesBox(),
            const SizedBox(height: AppSpacing.l),
            _buildSectionHeader(context.tr('reminders')),
            _buildRemindersList(),
            const SizedBox(height: AppSpacing.l),
            _buildSectionHeader(context.tr('documents'), action: '+ Add'),
            _buildDocumentsList(),
            const SizedBox(height: AppSpacing.xl),
            _buildFooterActions(context),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBadge('Hearing', Colors.green),
              _buildBadge('Upcoming', AppColors.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text('Hernandez v. State', style: AppTypography.h2),
          Text('Case #2026-CR-4471', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              _buildDateTimeInfo(context.tr('date'), 'Thu, Jul 16, 2026'),
              const SizedBox(width: AppSpacing.xl),
              _buildDateTimeInfo(context.tr('time'), '09:00 – 10:00 AM'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.labelMedium.copyWith(color: color, fontSize: 10),
      ),
    );
  }

  Widget _buildDateTimeInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium.copyWith(fontSize: 10, color: AppColors.textHint)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.labelLarge.copyWith(fontSize: 13)),
      ],
    );
  }

  Widget _buildInfoTiles(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.person_outline,
            label: context.tr('client').toUpperCase(),
            value: 'Carlos Hernandez',
            subtitle: 'carlos@hernandez.com',
            showArrow: true,
          ),
          const Divider(color: AppColors.surfaceLight, height: 1),
          _buildInfoTile(icon: Icons.business_outlined, label: 'COURT', value: 'District Court — Room 4'),
          const Divider(color: AppColors.surfaceLight, height: 1),
          _buildInfoTile(
            icon: Icons.location_on_outlined,
            label: context.tr('address').toUpperCase(),
            value: '555 Justice Ave, Floor 3',
            subtitle: 'New York, NY 10013',
          ),
          const Divider(color: AppColors.surfaceLight, height: 1),
          _buildInfoTile(icon: Icons.tag, label: 'CASE NUMBER', value: '#2026-CR-4471'),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    bool showArrow = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelMedium.copyWith(fontSize: 10, color: AppColors.textHint)),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.bodyMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                ],
              ],
            ),
          ),
          if (showArrow) const Icon(Icons.chevron_right, size: 16, color: AppColors.textHint),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.h3),
          if (action != null)
            Text(action, style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNotesBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Text(
        'Pre-trial hearing regarding admissibility of digital evidence. Bring chain of custody documentation and forensic expert\'s affidavit. DA filed motion to suppress — prepare counter-arguments.',
        style: AppTypography.bodySmall.copyWith(height: 1.5, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildRemindersList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Column(
        children: [
          _buildReminderItem('1 hour before'),
          const Divider(color: AppColors.surfaceLight, height: 1),
          _buildReminderItem('1 day before'),
        ],
      ),
    );
  }

  Widget _buildReminderItem(String text) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          const Icon(Icons.notifications_none, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(text, style: AppTypography.bodyMedium),
          const Spacer(),
          const Icon(Icons.check_circle_outline, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return Column(
      children: [
        _buildDocumentItem('Motion_to_Suppress.pdf', '2.4 MB · Jul 14'),
        const SizedBox(height: 8),
        _buildDocumentItem('Evidence_Chain_Custody.pdf', '1.1 MB · Jul 12'),
        const SizedBox(height: 8),
        _buildDocumentItem('Forensic_Affidavit.docx', '890 KB · Jul 10'),
      ],
    );
  }

  Widget _buildDocumentItem(String name, String info) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.labelMedium),
                Text(info, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
              ],
            ),
          ),
          const Icon(Icons.file_download_outlined, size: 20, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: AppRadius.medium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(context.tr('call'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: AppRadius.medium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                Text(context.tr('address'), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
