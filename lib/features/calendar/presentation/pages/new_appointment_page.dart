import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class NewAppointmentPage extends StatefulWidget {
  const NewAppointmentPage({super.key});

  @override
  State<NewAppointmentPage> createState() => _NewAppointmentPageState();
}

class _NewAppointmentPageState extends State<NewAppointmentPage> {
  final _titleController = TextEditingController();
  final _clientController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedType = 'Hearing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'TITLE',
              hint: 'e.g. Hernandez v. State — Hearing',
              controller: _titleController,
              prefixIcon: Icons.business_center_outlined,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'CLIENT',
              hint: 'Search client...',
              controller: _clientController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'DATE',
                    hint: '07/17/2026',
                    prefixIcon: Icons.calendar_today_outlined,
                    suffixIcon: const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.textHint),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextField(
                    label: 'TIME',
                    hint: '09:00 AM',
                    prefixIcon: Icons.access_time,
                    suffixIcon: const Icon(Icons.history_toggle_off, size: 18, color: AppColors.textHint),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'TYPE',
              style: AppTypography.labelMedium.copyWith(fontSize: 10, color: AppColors.textHint, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            _buildTypeChips(),
            const SizedBox(height: 24),
            AppTextField(
              label: 'COURT / LOCATION',
              hint: 'e.g. District Court — Room 4',
              controller: _locationController,
              prefixIcon: Icons.business_outlined,
            ),
            const SizedBox(height: 24),
            _buildNotesField(),
            const SizedBox(height: 24),
            Text(
              'REMINDERS',
              style: AppTypography.labelMedium.copyWith(fontSize: 10, color: AppColors.textHint, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            _buildRemindersSection(),
            const SizedBox(height: 24),
            Text(
              'ATTACH DOCUMENTS',
              style: AppTypography.labelMedium.copyWith(fontSize: 10, color: AppColors.textHint, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            _buildAttachArea(),
            const SizedBox(height: 40),
            AppButton(
              text: 'Save Appointment',
              onPressed: () => context.pop(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChips() {
    final types = ['Hearing', 'Client Meeting', 'Deposition', 'Filing Deadline', 'Consultation', 'Mediation'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              type,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.black : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOTES',
          style: AppTypography.labelMedium.copyWith(fontSize: 10, color: AppColors.textHint, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.medium,
          ),
          child: TextField(
            controller: _notesController,
            maxLines: null,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Add case notes...',
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Column(
        children: [
          _buildReminderSwitch('30 min before', false),
          const Divider(color: AppColors.surfaceLight, height: 1),
          _buildReminderSwitch('1 hour before', true),
          const Divider(color: AppColors.surfaceLight, height: 1),
          _buildReminderSwitch('1 day before', true),
        ],
      ),
    );
  }

  Widget _buildReminderSwitch(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.notifications_none, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(title, style: AppTypography.bodyMedium),
          const Spacer(),
          Switch(
            value: value,
            onChanged: (_) {},
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.surfaceLight, style: BorderStyle.solid), // Simplified dotted border
      ),
      child: Column(
        children: [
          const Icon(Icons.attach_file, color: AppColors.textHint, size: 32),
          const SizedBox(height: 12),
          Text('Tap to attach documents', style: AppTypography.labelMedium),
          const SizedBox(height: 4),
          Text('PDF, DOCX · up to 50 MB', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
