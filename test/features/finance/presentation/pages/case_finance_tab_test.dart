import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/finance/data/models/create_payment_request.dart';
import 'package:hqooq/features/finance/domain/entities/case_finance_detail.dart';
import 'package:hqooq/features/finance/domain/entities/payment_method.dart';
import 'package:hqooq/features/finance/domain/entities/payment_record.dart';
import 'package:hqooq/features/finance/domain/repository/i_finance_repository.dart';
import 'package:hqooq/features/finance/presentation/bloc/case_ledger_bloc.dart';
import 'package:hqooq/features/finance/presentation/bloc/payment_form_bloc.dart';
import 'package:hqooq/features/finance/presentation/pages/case_finance_tab.dart';
import 'package:hqooq/shared/widgets/error_view.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceRepository extends Mock implements IFinanceRepository {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockCaseLedgerBloc extends MockBloc<CaseLedgerEvent, CaseLedgerState>
    implements CaseLedgerBloc {}

class MockPaymentFormBloc extends MockBloc<PaymentFormEvent, PaymentFormState>
    implements PaymentFormBloc {}

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
  late AppLocalizations preloadedEn;
  late AppLocalizations preloadedAr;
  late MockSessionCubit sessionCubit;
  late MockCaseLedgerBloc ledgerBloc;
  late MockPaymentFormBloc paymentFormBloc;

  final sessionUser = User(
    id: 'u1',
    email: 'acc@firm.com',
    fullName: 'Accountant Ali',
    status: 'ACTIVE',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    tenant: const TenantRef(id: 't1', name: 'Demo Law Firm'),
  );

  const noFeeDetail = CaseFinanceDetail(
    caseId: 'c1',
    agreedFee: null,
    payments: [],
  );

  const feeDetail = CaseFinanceDetail(
    caseId: 'c1',
    agreedFee: 10000,
    payments: [],
  );

  final partiallyPaidDetail = CaseFinanceDetail(
    caseId: 'c1',
    agreedFee: 10000,
    payments: [
      PaymentRecord(
        id: 'p1',
        caseId: 'c1',
        amount: 4000,
        paidAt: DateTime(2026, 8, 20),
        method: PaymentMethod.bankTransfer,
        reference: 'TRX-88991',
        note: 'First installment',
        recordedByName: 'Accountant Ali',
      ),
    ],
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(
      const CreatePaymentRequest(
        amount: 0,
        paidAt: '1970-01-01',
        method: PaymentMethod.cash,
      ),
    );
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
    preloadedAr = AppLocalizations(const Locale('ar'));
    await preloadedAr.load();
  });

  setUp(() async {
    sessionCubit = MockSessionCubit();
    ledgerBloc = MockCaseLedgerBloc();
    paymentFormBloc = MockPaymentFormBloc();
    getIt.registerSingleton<SessionCubit>(sessionCubit);
    when(() => sessionCubit.state).thenReturn(const SessionUnknown());
    when(() => ledgerBloc.state).thenReturn(const CaseLedgerLoading());
    when(() => paymentFormBloc.state).thenReturn(const PaymentFormInitial());
  });

  tearDown(() async {
    await ledgerBloc.close();
    await paymentFormBloc.close();
    await getIt.reset();
  });

  Widget buildTestable({Locale locale = const Locale('en')}) {
    final instance = locale.languageCode == 'ar' ? preloadedAr : preloadedEn;
    return MaterialApp(
      locale: locale,
      localizationsDelegates: [
        _PreloadedAppLocalizationsDelegate(instance),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<CaseLedgerBloc>.value(value: ledgerBloc),
            BlocProvider<PaymentFormBloc>.value(value: paymentFormBloc),
          ],
          child: const CaseFinanceTab(caseId: 'c1'),
        ),
      ),
    );
  }

  void stubSession(List<String> permissions) {
    when(() => sessionCubit.state).thenReturn(
      SessionAuthenticated(
        sessionUser.copyWith(permissions: permissions),
        isFirmAdmin: false,
      ),
    );
  }

  void stubLedgerState(CaseLedgerState state) {
    when(() => ledgerBloc.state).thenReturn(state);
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('loading / error / empty states', () {
    testWidgets('shows a spinner while the ledger loads', (tester) async {
      stubSession(['finance.view']);
      stubLedgerState(const CaseLedgerLoading());

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ErrorView), findsNothing);
    });

    testWidgets('shows the shared ErrorView with retry on fetch failure', (
      tester,
    ) async {
      stubSession(['finance.view']);
      stubLedgerState(
        const CaseLedgerError(
          message: 'No internet connection',
          isForbidden: false,
        ),
      );

      await tester.pumpWidget(buildTestable());
      await settle(tester);

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('swaps retry for a lock on a forbidden fetch', (tester) async {
      stubSession(['finance.view']);
      stubLedgerState(
        const CaseLedgerError(
          message: 'Insufficient permissions',
          isForbidden: true,
        ),
      );

      await tester.pumpWidget(buildTestable());
      await settle(tester);

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets(
      'empty case shows agreed fee, paid 0, remaining, no history, and the '
      'record action for finance.payment.record',
      (tester) async {
        stubSession(['finance.view', 'finance.payment.record']);
        stubLedgerState(const CaseLedgerLoaded(feeDetail));

        await tester.pumpWidget(buildTestable());
        await settle(tester);

        expect(find.text('Agreed Fee'), findsOneWidget);
        expect(find.text('Paid'), findsOneWidget);
        expect(find.text('Remaining'), findsOneWidget);
        expect(find.text('Payment History'), findsOneWidget);
        expect(find.text('EGP 0.00'), findsOneWidget);
        expect(find.text('EGP 10,000.00'), findsNWidgets(2));
        expect(find.text('Unpaid'), findsOneWidget);
        expect(
          find.text('No payments recorded for this case yet'),
          findsOneWidget,
        );
        expect(find.text('Record First Payment'), findsOneWidget);
      },
    );

    testWidgets(
      'no-fee state renders the not-set badge, em-dash fee/remaining, '
      'guidance, and NO write actions',
      (tester) async {
        // The server rejects payment creation until `agreed_fee` is set, and
        // the Case Finance API has no agreed-fee route — so the tab must not
        // offer either action. It explains where the fee is set instead.
        stubSession([
          'finance.view',
          'finance.manage',
          'finance.payment.record',
        ]);
        stubLedgerState(const CaseLedgerLoaded(noFeeDetail));

        await tester.pumpWidget(buildTestable());
        await settle(tester);

        expect(find.text('No agreed fee set'), findsOneWidget);
        expect(find.text('—'), findsNWidgets(2));
        expect(find.text('EGP 0.00'), findsOneWidget);
        expect(
          find.textContaining('No agreed fee is recorded for this case yet'),
          findsOneWidget,
        );
        expect(find.text('Set Agreed Fee'), findsNothing);
        expect(find.text('Update Agreed Fee'), findsNothing);
        expect(
          find.text('Record First Payment'),
          findsNothing,
          reason: 'recording is impossible server-side until a fee exists',
        );
      },
    );

    testWidgets('payment history shows the PRD fields for each record', (
      tester,
    ) async {
      stubSession(['finance.view']);
      stubLedgerState(CaseLedgerLoaded(partiallyPaidDetail));

      await tester.pumpWidget(buildTestable());
      await settle(tester);

      expect(find.text('EGP 4,000.00'), findsNWidgets(2));
      expect(find.text('Bank Transfer'), findsOneWidget);
      expect(find.textContaining('2026-08-20'), findsOneWidget);
      expect(find.textContaining('TRX-88991'), findsOneWidget);
      expect(find.textContaining('First installment'), findsOneWidget);
      expect(find.textContaining('Accountant Ali'), findsOneWidget);
      expect(find.text('Partially Paid'), findsOneWidget);
    });
  });

  group('permission visibility', () {
    testWidgets(
      'finance.view only: finance data renders but no write actions',
      (tester) async {
        stubSession(['finance.view']);
        stubLedgerState(const CaseLedgerLoaded(feeDetail));

        await tester.pumpWidget(buildTestable());
        await settle(tester);

        expect(find.text('Agreed Fee'), findsOneWidget);
        expect(find.text('Record Payment'), findsNothing);
        expect(find.text('Set Agreed Fee'), findsNothing);
        expect(find.text('Update Agreed Fee'), findsNothing);
      },
    );

    testWidgets(
      'finance.payment.record shows Record Payment, not fee management',
      (tester) async {
        stubSession(['finance.view', 'finance.payment.record']);
        stubLedgerState(const CaseLedgerLoaded(feeDetail));

        await tester.pumpWidget(buildTestable());
        await settle(tester);

        expect(find.text('Record First Payment'), findsOneWidget);
        expect(find.text('Set Agreed Fee'), findsNothing);
        expect(find.text('Update Agreed Fee'), findsNothing);
      },
    );

    testWidgets('finance.manage offers reversal, no fee editing, and no Record '
        'Payment on a fully-paid case', (tester) async {
      stubSession(['finance.view', 'finance.manage']);
      stubLedgerState(
        CaseLedgerLoaded(
          CaseFinanceDetail(
            caseId: 'c1',
            agreedFee: 4000,
            payments: [
              PaymentRecord(
                id: 'p1',
                caseId: 'c1',
                amount: 4000,
                paidAt: DateTime(2026, 8, 20),
                method: PaymentMethod.cash,
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(buildTestable());
      await settle(tester);

      expect(find.text('Record Payment'), findsNothing);
      expect(find.text('Set Agreed Fee'), findsNothing);
      expect(
        find.text('Update Agreed Fee'),
        findsNothing,
        reason: 'the agreed fee is edited on the Case form, not this tab',
      );
      expect(find.text('Paid in Full'), findsOneWidget);
      expect(
        find.text('Reverse payment'),
        findsOneWidget,
        reason: 'finance.manage keeps the reversal action',
      );
    });
  });

  group('record payment dialog', () {
    Future<void> openDialog(WidgetTester tester) async {
      final button = find.text('Record Payment').evaluate().isNotEmpty
          ? find.text('Record Payment')
          : (find.text('Record First Payment').evaluate().isNotEmpty
                ? find.text('Record First Payment')
                : (find.text('تسجيل دفعة').evaluate().isNotEmpty
                      ? find.text('تسجيل دفعة')
                      : find.text('تسجيل أول دفعة')));
      await tester.tap(button);
      await settle(tester);
    }

    Finder amountFieldInDialog() => find
        .descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        )
        .first;

    testWidgets('amount is required and must be positive', (tester) async {
      stubSession(['finance.view', 'finance.payment.record']);
      stubLedgerState(const CaseLedgerLoaded(feeDetail));

      await tester.pumpWidget(buildTestable());
      await settle(tester);
      await openDialog(tester);

      await tester.tap(find.text('Confirm'));
      await settle(tester);
      expect(find.text('Please enter a valid amount'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.enterText(amountFieldInDialog(), '0');
      await tester.tap(find.text('Confirm'));
      await settle(tester);
      expect(find.text('Please enter a valid amount'), findsOneWidget);
    });

    testWidgets('rejects amounts exceeding the remaining balance', (
      tester,
    ) async {
      stubSession(['finance.view', 'finance.payment.record']);
      stubLedgerState(CaseLedgerLoaded(partiallyPaidDetail));

      await tester.pumpWidget(buildTestable());
      await settle(tester);
      await openDialog(tester);

      await tester.enterText(amountFieldInDialog(), '9999');
      await tester.tap(find.text('Confirm'));
      await settle(tester);

      expect(find.text('Amount exceeds the remaining balance'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('arabic / rtl', () {
    testWidgets('renders the finance tab in Arabic with RTL directionality', (
      tester,
    ) async {
      stubSession(['finance.view', 'finance.payment.record']);
      stubLedgerState(CaseLedgerLoaded(partiallyPaidDetail));

      await tester.pumpWidget(buildTestable(locale: const Locale('ar')));
      await settle(tester);

      final directionality = tester.widget<Directionality>(
        find.byType(Directionality).first,
      );
      expect(directionality.textDirection, TextDirection.rtl);

      expect(find.text('الأتعاب المتفق عليها'), findsOneWidget);
      expect(find.text('المتبقي'), findsOneWidget);
      expect(find.text('سجل الدفعات'), findsOneWidget);
      expect(find.text('تسجيل دفعة'), findsOneWidget);
      expect(find.text('مدفوع جزئياً'), findsOneWidget);
      expect(find.text('تحويل بنكي'), findsOneWidget);
    });

    testWidgets('shows the Arabic validation error inside the record dialog', (
      tester,
    ) async {
      stubSession(['finance.view', 'finance.payment.record']);
      stubLedgerState(const CaseLedgerLoaded(feeDetail));

      await tester.pumpWidget(buildTestable(locale: const Locale('ar')));
      await settle(tester);
      await tester.tap(find.text('تسجيل أول دفعة'));
      await settle(tester);
      await tester.tap(find.text('تأكيد'));
      await settle(tester);

      expect(find.text('الرجاء إدخال مبلغ صحيح'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
