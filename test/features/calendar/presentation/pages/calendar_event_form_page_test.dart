import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/calendar/presentation/bloc/calendar_event_form_bloc.dart';
import 'package:hqooq/features/calendar/presentation/pages/calendar_event_form_page.dart';
import 'package:mocktail/mocktail.dart';

class MockCalendarEventFormBloc
    extends MockBloc<CalendarEventFormEvent, CalendarEventFormState>
    implements CalendarEventFormBloc {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

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
  late MockCalendarEventFormBloc bloc;
  late MockSessionCubit sessionCubit;

  final user = User(
    id: 'u1',
    email: 'lawyer@firm.com',
    fullName: 'Jane Doe',
    isSuperAdmin: false,
    status: 'ACTIVE',
    mfaEnabled: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    roles: const [],
    tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockCalendarEventFormBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<CalendarEventFormBloc>(() => bloc);
    getIt.registerSingleton<SessionCubit>(sessionCubit);
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: false));
    whenListen(
      bloc,
      const Stream<CalendarEventFormState>.empty(),
      initialState: CalendarEventFormInitial(),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestable() {
    final router = GoRouter(
      initialLocation: '/form',
      routes: [
        GoRoute(
          path: '/form',
          builder: (context, state) => const CalendarEventFormPage(),
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

  testWidgets('renders the new-event form with empty fields', (tester) async {
    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('New Event'), findsOneWidget);
    expect(find.text('Create Event'), findsOneWidget);
    expect(find.text('All Day'), findsOneWidget);
  });

  testWidgets('shows a validation error when title is left empty', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    final submitButton = find.text('Create Event');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('This field is required'), findsOneWidget);
  });

  testWidgets('shows a loading indicator on the submit button while '
      'Submitting', (tester) async {
    whenListen(
      bloc,
      const Stream<CalendarEventFormState>.empty(),
      initialState: CalendarEventFormSubmitting(),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
