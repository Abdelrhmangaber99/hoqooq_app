import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

/// A "Select all" checkbox for a permission list, placed directly above it.
///
/// It reports selected only when every code in [keys] is already granted, so
/// the control never claims a complete selection the user did not make.
/// Toggling it grants or clears the whole [keys] list in one tap. It stays
/// disabled when there is nothing to select or when [enabled] is false, e.g.
/// while a save is in flight.
class SelectAllTile extends StatelessWidget {
  const SelectAllTile({
    super.key,
    required this.keys,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  /// Every toggleable code in the list this row controls.
  final Iterable<String> keys;

  /// The currently granted codes.
  final Set<String> selected;

  /// Called with true to grant all of [keys], false to clear them.
  final ValueChanged<bool> onChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final codes = keys.toList(growable: false);
    final allSelected = codes.isNotEmpty && codes.every(selected.contains);

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        context.tr('select_all'),
        style: Theme.of(context).textTheme.titleSmall,
      ),
      value: allSelected,
      onChanged: enabled && codes.isNotEmpty
          ? (value) => onChanged(value ?? false)
          : null,
    );
  }
}
