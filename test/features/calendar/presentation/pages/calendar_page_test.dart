import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/calendar/domain/entities/calendar_event_type.dart';
import 'package:hqooq/features/calendar/domain/entities/timeline_item.dart';
import 'package:hqooq/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:hqooq/features/calendar/presentation/pages/calendar_page.dart';

class MockCalendarBloc extends MockBloc<CalendarEvent, CalendarState>
    implements CalendarBloc {}

/// Preloaded synchronously — see case_details_page_test.dart / CLAUDE.md for
/// why the real JSON delegate's async load is flaky across multiple
/// testWidgets blocks in one file.
class _PreloadedAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _PreloadedAppLocalizationsDelegate(this._instance);
  final AppLocalizations _instance;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(_instance);

  @override
  bool shouldReload(_PreloadedAppLocalizationsDelegate old) => false;
}

void main() {
  late AppLocalizations preloadedEn;
  late MockCalendarBloc bloc;

  final selectedDate = DateTime(2026, 7, 16);
  final item = TimelineItem.event(
    id: 'e1',
    title: 'Team sync',
    date: DateTime(2026, 7, 16, 9),
    eventType: CalendarEventType.custom,
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockCalendarBloc();
    getIt.registerFactory<CalendarBloc>(() => bloc);
  });

  tearDown(() async {
    await getIt.reset();
  });

  // The month grid's height comfortably fits a real phone's portrait
  // screen, but Flutter's default 800x600 test surface is short/landscape
  // and clips it -- use a phone-sized viewport so this test reflects real
  // device layout instead of the test harness's unusual default aspect
  // ratio.
  void setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildTestable() {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: [
        _PreloadedAppLocalizationsDelegate(preloadedEn),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const CalendarPage(),
    );
  }

  testWidgets('shows a loading spinner while CalendarLoading', (tester) async {
    whenListen(
      bloc,
      const Stream<CalendarState>.empty(),
      initialState: CalendarLoading(),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error view on CalendarError', (tester) async {
    whenListen(
      bloc,
      const Stream<CalendarState>.empty(),
      initialState: const CalendarError('Server error'),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Server error'), findsOneWidget);
  });

  testWidgets('renders the month grid and the selected day\'s real events', (
    tester,
  ) async {
    setPhoneViewport(tester);
    whenListen(
      bloc,
      const Stream<CalendarState>.empty(),
      initialState: CalendarLoaded([item], selectedDate),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('July '), findsOneWidget);
    expect(find.text('Team sync'), findsOneWidget);
  });

  testWidgets('shows the empty state when the selected day has no events', (
    tester,
  ) async {
    setPhoneViewport(tester);
    whenListen(
      bloc,
      const Stream<CalendarState>.empty(),
      initialState: CalendarLoaded(const [], selectedDate),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('No events for this day'), findsOneWidget);
  });

  testWidgets('renders a FAB to create a new custom event', (tester) async {
    setPhoneViewport(tester);
    whenListen(
      bloc,
      const Stream<CalendarState>.empty(),
      initialState: CalendarLoaded([item], selectedDate),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
