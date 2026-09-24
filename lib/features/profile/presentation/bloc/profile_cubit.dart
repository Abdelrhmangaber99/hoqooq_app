import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/localization/locale_bloc.dart';
import '../../../../core/theme/theme_bloc.dart';
import 'profile_state.dart';

export 'profile_state.dart';

/// Presentation façade over the app's existing ThemeBloc and LocaleBloc.
/// Introduces NO second theme/locale source of truth: state is combined
/// from those blocs and every change is delegated to them (same shape as
/// the reference web app's single preference store).
@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final ThemeBloc _themeBloc;
  final LocaleBloc _localeBloc;

  ProfileCubit(this._themeBloc, this._localeBloc)
      : super(ProfileState(
          themeMode: _themeBloc.state.themeMode,
          locale: _localeBloc.state.locale,
        )) {
    // Stay in sync with the underlying blocs so this state can never drift
    // from the real theme/locale the MaterialApp consumes.
    _themeSub = _themeBloc.stream.listen((_) => _syncFromBlocs());
    _localeSub = _localeBloc.stream.listen((_) => _syncFromBlocs());
  }

  late final StreamSubscription<ThemeState> _themeSub;
  late final StreamSubscription<LocaleState> _localeSub;

  void _syncFromBlocs() {
    emit(ProfileState(
      themeMode: _themeBloc.state.themeMode,
      locale: _localeBloc.state.locale,
    ));
  }

  /// Light / Dark / System — delegated to the existing ThemeBloc, which
  /// persists to the same Hive `settings` box and emits immediately, so
  /// MaterialApp's `themeMode` rebuilds without any restart.
  void setThemeMode(ThemeMode mode) {
    _themeBloc.add(SetThemeEvent(mode));
  }

  /// EN/AR switch — delegated to the existing LocaleBloc (persists to the
  /// same Hive box, emits immediately, RTL follows the locale).
  void toggleLocale() => _localeBloc.add(ToggleLocaleEvent());

  @override
  Future<void> close() {
    _themeSub.cancel();
    _localeSub.cancel();
    return super.close();
  }
}
