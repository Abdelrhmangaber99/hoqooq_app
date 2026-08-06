import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/finance/domain/entities/case_financial_summary.dart';
import 'package:hqooq/features/finance/domain/entities/payment_status.dart';
import 'package:hqooq/features/finance/presentation/bloc/cases_financial_summary_bloc.dart';
import 'package:hqooq/features/finance/presentation/pages/cases_financial_summary_page.dart';

class MockCasesFinancialSummaryBloc
    extends MockBloc<CasesFinancialSummaryEvent, CasesFinancialSummaryState>
    implements CasesFinancialSummaryBloc {}

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
  late MockCasesFinancialSummaryBloc bloc;

  const summary = CaseFinancialSummary(
    caseId: 'c1',
    caseNumber: 'CASE-2026-00001',
    clientName: 'Carlos Hernandez',
    totalInvoiced: 15000,
    totalPaid: 10000,
    outstandingBalance: 5000,
    paymentStatus: PaymentStatus.partial,
    invoicesCount: 2,
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockCasesFinancialSummaryBloc();
    getIt.registerFactory<CasesFinancialSummaryBloc>(() => bloc);
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
      home: const CasesFinancialSummaryPage(),
    );
  }

  testWidgets('shows a loading spinner while CasesFinancialSummaryLoading', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<CasesFinancialSummaryState>.empty(),
      initialState: CasesFinancialSummaryLoading(),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no cases', (tester) async {
    whenListen(
      bloc,
      const Stream<CasesFinancialSummaryState>.empty(),
      initialState: const CasesFinancialSummaryLoaded([]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('CASE-2026-00001'), findsNothing);
  });

  testWidgets('renders the case financial summary list', (tester) async {
    whenListen(
      bloc,
      const Stream<CasesFinancialSummaryState>.empty(),
      initialState: const CasesFinancialSummaryLoaded([summary]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('CASE-2026-00001'), findsOneWidget);
    expect(find.text('Carlos Hernandez'), findsOneWidget);
  });
}
