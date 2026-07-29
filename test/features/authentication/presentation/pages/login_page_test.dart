import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:hqooq/features/authentication/presentation/pages/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

/// Serves the two locales' already-loaded [AppLocalizations] synchronously.
/// The real delegate's `load()` awaits `rootBundle.loadString`, which is
/// flaky across multiple `testWidgets` blocks in one file (the async gap
/// doesn't reliably resolve on the second `pumpWidget` onward). Loading each
/// locale once in `setUpAll` and serving it via `SynchronousFuture` here
/// removes that async gap entirely instead of chasing pump counts.
class _PreloadedAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _PreloadedAppLocalizationsDelegate(this._cache);

  final Map<Locale, AppLocalizations> _cache;

  @override
  bool isSupported(Locale locale) => _cache.containsKey(locale);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(_cache[locale]!);

  @override
  bool shouldReload(_PreloadedAppLocalizationsDelegate old) => false;
}

Widget buildTestable({
  required MockAuthBloc bloc,
  required Locale locale,
  required Map<Locale, AppLocalizations> localizationsCache,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: [
      _PreloadedAppLocalizationsDelegate(localizationsCache),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en'), Locale('ar')],
    home: BlocProvider<AuthBloc>.value(value: bloc, child: const LoginPage()),
  );
}

void main() {
  late MockAuthBloc authBloc;
  late Map<Locale, AppLocalizations> localizationsCache;

  setUpAll(() async {
    final en = AppLocalizations(const Locale('en'));
    await en.load();
    final ar = AppLocalizations(const Locale('ar'));
    await ar.load();
    localizationsCache = {const Locale('en'): en, const Locale('ar'): ar};
  });

  setUp(() {
    authBloc = MockAuthBloc();
  });

  testWidgets('renders the sign-in form in English, LTR', (tester) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(
      buildTestable(
        bloc: authBloc,
        locale: const Locale('en'),
        localizationsCache: localizationsCache,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome\nback.'), findsOneWidget);
    // AppTextField upper-cases its label.
    expect(find.text('EMAIL ADDRESS'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.ltr);
  });

  testWidgets('renders the sign-in form in Arabic, RTL', (tester) async {
    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(
      buildTestable(
        bloc: authBloc,
        locale: const Locale('ar'),
        localizationsCache: localizationsCache,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('مرحباً\nبعودتك.'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);

    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });

  testWidgets(
    'shows a loading spinner on the sign-in button while AuthLoading',
    (tester) async {
      whenListen(
        authBloc,
        const Stream<AuthState>.empty(),
        initialState: AuthLoading(),
      );

      await tester.pumpWidget(
        buildTestable(
          bloc: authBloc,
          locale: const Locale('en'),
          localizationsCache: localizationsCache,
        ),
      );
      // Not pumpAndSettle: the spinner is an indeterminate
      // CircularProgressIndicator, which never settles.
      await tester.pump();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
    },
  );

  testWidgets('shows the failure message in a snackbar on AuthError', (
    tester,
  ) async {
    whenListen(
      authBloc,
      Stream<AuthState>.fromIterable([
        const AuthError('Invalid email or password'),
      ]),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(
      buildTestable(
        bloc: authBloc,
        locale: const Locale('en'),
        localizationsCache: localizationsCache,
      ),
    );
    // Not pumpAndSettle: it would fast-forward past the SnackBar's ~4s
    // auto-dismiss timer and find nothing. A couple of fixed pumps catch it
    // mid-display instead.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Invalid email or password'), findsOneWidget);
  });
}
