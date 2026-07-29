part of 'locale_bloc.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object> get props => [];
}

class ToggleLocaleEvent extends LocaleEvent {}

class SetLocaleEvent extends LocaleEvent {
  final Locale locale;
  const SetLocaleEvent(this.locale);

  @override
  List<Object> get props => [locale];
}
