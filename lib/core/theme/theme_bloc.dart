import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'theme_event.dart';
part 'theme_state.dart';

@lazySingleton
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _boxName = 'settings';
  static const String _themeKey = 'themeMode';

  ThemeBloc() : super(const ThemeState(ThemeMode.light)) {
    on<ToggleThemeEvent>((event, emit) async {
      final isDarkMode = state.themeMode == ThemeMode.dark;
      final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
      
      final box = Hive.box(_boxName);
      await box.put(_themeKey, newMode == ThemeMode.dark ? 'dark' : 'light');
      
      emit(ThemeState(newMode));
    });

    on<SetThemeEvent>((event, emit) async {
      final box = Hive.box(_boxName);
      String modeStr = 'light';
      if (event.themeMode == ThemeMode.dark) modeStr = 'dark';
      if (event.themeMode == ThemeMode.system) modeStr = 'system';
      await box.put(_themeKey, modeStr);
      emit(ThemeState(event.themeMode));
    });

    _init();
  }

  void _init() {
    try {
      final box = Hive.box(_boxName);
      final savedMode = box.get(_themeKey, defaultValue: 'light');
      ThemeMode mode = ThemeMode.light;
      if (savedMode == 'dark' || savedMode == true) mode = ThemeMode.dark;
      if (savedMode == 'system') mode = ThemeMode.system;
      add(SetThemeEvent(mode));
    } catch (_) {}
  }
}
