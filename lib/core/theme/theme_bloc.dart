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
  static const String _themeKey = 'isDarkMode';

  ThemeBloc() : super(const ThemeState(ThemeMode.dark)) {
    _init();

    on<ToggleThemeEvent>((event, emit) async {
      final isDarkMode = state.themeMode == ThemeMode.dark;
      final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
      
      final box = Hive.box(_boxName);
      await box.put(_themeKey, !isDarkMode);
      
      emit(ThemeState(newMode));
    });

    on<SetThemeEvent>((event, emit) {
      emit(ThemeState(event.themeMode));
    });
  }

  void _init() {
    final box = Hive.box(_boxName);
    final isDarkMode = box.get(_themeKey, defaultValue: true);
    add(SetThemeEvent(isDarkMode ? ThemeMode.dark : ThemeMode.light));
  }
}
