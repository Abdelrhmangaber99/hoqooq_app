import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

/// Labeled tap-to-pick date/date-time display matching the write-form
/// field style used across Case/Hearing forms — both the date-only and
/// date-time variants (`hearing_form_page.dart`'s old `_buildDateTimeField`
/// had an identical body to `case_form_page.dart`'s `_buildDateField`,
/// differing only in which `DateFormat` the caller passed in) collapse
/// into this one widget. See `AppDropdownField`'s doc comment for the
/// same extraction rationale (architecture review finding #8).
class AppDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.dateFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value != null ? dateFormat.format(value!) : '—',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}
