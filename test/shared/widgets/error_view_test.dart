import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/shared/widgets/error_view.dart';

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

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  Widget buildTestable(Widget child) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: [
        _PreloadedAppLocalizationsDelegate(preloadedEn),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(body: child),
    );
  }

  testWidgets('shows a retry button by default', (tester) async {
    await tester.pumpWidget(
      buildTestable(ErrorView(message: 'Server error', onRetry: () {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('Server error'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets(
    'architecture-review finding #4: hides the retry button and shows a '
    'lock icon when isForbidden is true — retrying a 403 just 403s again',
    (tester) async {
      await tester.pumpWidget(
        buildTestable(
          ErrorView(
            message: "You don't have permission to do this",
            isForbidden: true,
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("You don't have permission to do this"), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    },
  );
}
