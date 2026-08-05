import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Labeled dropdown matching the write-form field style used across
/// Case/Hearing/Task forms and `CaseDetailsPage`'s team-assignment sheet.
///
/// Extracted 2026-08-05 (architecture review finding #8) — this exact
/// widget had been hand-copied into 3 form pages plus reimplemented
/// inline (without the shared name) a 4th time in the team-assignment
/// sheet; `backgroundColor` exists specifically because that 4th instance
/// sits on a surface-colored bottom sheet and needs a lighter fill to
/// stay visually distinct from its container.
class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final Iterable<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  final Color backgroundColor;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    this.backgroundColor = AppColors.surface,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: backgroundColor,
              items: items
                  .map(
                    (i) => DropdownMenuItem(value: i, child: Text(labelOf(i))),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
