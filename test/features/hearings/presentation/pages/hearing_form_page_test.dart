import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/cases/domain/entities/court.dart';
import 'package:hqooq/features/hearings/domain/entities/hearing.dart';
import 'package:hqooq/features/hearings/domain/entities/hearing_status.dart';
import 'package:hqooq/features/hearings/presentation/bloc/hearing_form_bloc.dart';
import 'package:hqooq/features/hearings/presentation/pages/hearing_form_page.dart';

class MockHearingFormBloc extends MockBloc<HearingFormEvent, HearingFormState>
    implements HearingFormBloc {}

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
  late MockHearingFormBloc bloc;

  final hearing = Hearing(
    id: 'h1',
    caseId: 'c1',
    courtId: 'co1',
    hearingTypeId: 'ht1',
    scheduledAt: DateTime(2026, 2, 1, 9),
    judgeName: 'Judge Smith',
    status: HearingStatus.scheduled,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final court = Court(
    id: 'co1',
    name: 'District Court',
    type: 'FIRST_INSTANCE',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockHearingFormBloc();
    getIt.registerFactory<HearingFormBloc>(() => bloc);
    whenListen(
      bloc,
      const Stream<HearingFormState>.empty(),
      initialState: HearingFormReady(courts: [court], hearingTypes: const []),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestable({Hearing? existingHearing}) {
    final router = GoRouter(
      initialLocation: '/form',
      routes: [
        GoRoute(
          path: '/form',
          builder: (context, state) =>
              HearingFormPage(caseId: 'c1', existingHearing: existingHearing),
        ),
      ],
    );
    return MaterialApp.router(
      routerConfig: router,
      locale: const Locale('en'),
      localizationsDelegates: [
        _PreloadedAppLocalizationsDelegate(preloadedEn),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
    );
  }

  testWidgets('renders the edit form with the existing hearing\'s values', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable(existingHearing: hearing));
    await tester.pumpAndSettle();

    expect(find.text('Edit Hearing'), findsOneWidget);
    expect(find.text('Judge Smith'), findsOneWidget);
    expect(find.text('District Court'), findsOneWidget);
  });

  testWidgets('shows a loading indicator while reference data loads', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<HearingFormState>.empty(),
      initialState: HearingFormLoading(),
    );

    await tester.pumpWidget(buildTestable(existingHearing: hearing));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the submit error in a snackbar', (tester) async {
    whenListen(
      bloc,
      Stream<HearingFormState>.fromIterable([
        HearingFormReady(
          courts: [court],
          hearingTypes: const [],
          submitError: 'scheduledAt is invalid',
        ),
      ]),
      initialState: HearingFormReady(courts: [court], hearingTypes: const []),
    );

    await tester.pumpWidget(buildTestable(existingHearing: hearing));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('scheduledAt is invalid'), findsOneWidget);
  });

  testWidgets('renders the create-mode form with a hearing-type picker '
      'and empty fields', (tester) async {
    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('New Hearing'), findsOneWidget);
    expect(find.text('Create Hearing'), findsOneWidget);
    expect(find.text('Judge Smith'), findsNothing);
  });
}
