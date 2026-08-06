import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/finance/domain/entities/financial_analytics.dart';
import 'package:hqooq/features/finance/presentation/bloc/financial_analytics_bloc.dart';
import 'package:hqooq/features/finance/presentation/pages/financial_analytics_page.dart';

class MockFinancialAnalyticsBloc
    extends MockBloc<FinancialAnalyticsEvent, FinancialAnalyticsState>
    implements FinancialAnalyticsBloc {}

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
  late MockFinancialAnalyticsBloc bloc;

  const analytics = FinancialAnalytics(
    totalInvoiced: 125000.5,
    totalPaid: 95000,
    totalOutstanding: 30000.5,
    collectionRatePercentage: 76,
    totalInvoicesCount: 45,
    paidInvoicesCount: 30,
    partialInvoicesCount: 10,
    unpaidInvoicesCount: 5,
    grossRevenue: 95000,
    netProfitEstimate: 95000,
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockFinancialAnalyticsBloc();
    getIt.registerFactory<FinancialAnalyticsBloc>(() => bloc);
  });

  tearDown(() async {
    await getIt.reset();
  });

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
      home: const FinancialAnalyticsPage(),
    );
  }

  testWidgets('shows a loading spinner while FinancialAnalyticsLoading', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<FinancialAnalyticsState>.empty(),
      initialState: FinancialAnalyticsLoading(),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error view on FinancialAnalyticsError', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<FinancialAnalyticsState>.empty(),
      initialState: const FinancialAnalyticsError('Server error'),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Server error'), findsOneWidget);
  });

  testWidgets('renders the metric cards on FinancialAnalyticsLoaded', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<FinancialAnalyticsState>.empty(),
      initialState: const FinancialAnalyticsLoaded(analytics),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('125000.50'), findsOneWidget);
    expect(find.text('76.0%'), findsOneWidget);
  });
}
