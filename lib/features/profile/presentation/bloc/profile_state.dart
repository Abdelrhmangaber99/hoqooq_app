import 'package:flutter/material.dart';

/// Presentation façade state over the app's existing ThemeBloc and
/// LocaleBloc. Introduces NO second theme/locale source of truth — every
/// value here is derived from those blocs, and every change is delegated
/// to them (the same architecture the reference web app uses: one
/// preference store).
class ProfileState {
  const ProfileState({required this.themeMode, required this.locale});

  final ThemeMode themeMode;
  final Locale locale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileState &&
          other.themeMode == themeMode &&
          other.locale == locale;

  @override
  int get hashCode => Object.hash(themeMode, locale);
}
