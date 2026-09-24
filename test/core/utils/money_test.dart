import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/core/utils/money.dart';

class _PreloadedAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _PreloadedAppLocalizationsDelegate(this._instance);
  final AppLocalizations _instance;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(_instance);

  @override
  bool shouldReload(_PreloadedAppLocalizationsDelegate old) => false;
}

void main() {
  testWidgets('formatMoney output check', (tester) async {
    final enMap = {'currency_sar': 'EGP '};
    final appLoc = AppLocalizations.withMap(const Locale('en'), enMap);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: [
          _PreloadedAppLocalizationsDelegate(appLoc),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            final result = formatMoney(context, 10000.0);
            expect(result, 'EGP 10,000.00');
            return Text(result);
          },
        ),
      ),
    );
  });
}
