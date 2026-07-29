import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'locale_event.dart';
part 'locale_state.dart';

@lazySingleton
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const String _boxName = 'settings';
  static const String _localeKey = 'locale';

  LocaleBloc() : super(const LocaleState(Locale('en'))) {
    on<ToggleLocaleEvent>((event, emit) async {
      final newLocale = state.locale.languageCode == 'en' 
          ? const Locale('ar') 
          : const Locale('en');
      
      final box = Hive.box(_boxName);
      await box.put(_localeKey, newLocale.languageCode);
      
      emit(LocaleState(newLocale));
    });
    
    on<SetLocaleEvent>((event, emit) {
      emit(LocaleState(event.locale));
    });

    _init();
  }

  void _init() {
    final box = Hive.box(_boxName);
    final savedLocale = box.get(_localeKey, defaultValue: 'en');
    add(SetLocaleEvent(Locale(savedLocale)));
  }
}
