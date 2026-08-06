import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/finance/domain/entities/invoice.dart';
import 'package:hqooq/features/finance/domain/entities/invoice_status.dart';
import 'package:hqooq/features/finance/domain/entities/payment.dart';
import 'package:hqooq/features/finance/domain/entities/payment_method.dart';
import 'package:hqooq/features/finance/presentation/bloc/invoice_details_bloc.dart';
import 'package:hqooq/features/finance/presentation/pages/invoice_details_page.dart';
import 'package:mocktail/mocktail.dart';

class MockInvoiceDetailsBloc
    extends MockBloc<InvoiceDetailsEvent, InvoiceDetailsState>
    implements InvoiceDetailsBloc {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

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
  late MockInvoiceDetailsBloc bloc;
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

  final invoice = Invoice(
    id: 'inv1',
    tenantId: 't1',
    clientId: 'cl1',
    invoiceNumber: 'INV-2026-0001',
    status: InvoiceStatus.partial,
    issueDate: DateTime(2026, 1, 1),
    dueDate: DateTime(2026, 1, 31),
    subtotal: 1000,
    taxTotal: 100,
    grandTotal: 1100,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    payments: [
      Payment(
        id: 'pay1',
        tenantId: 't1',
        invoiceId: 'inv1',
        amount: 500,
        paymentDate: DateTime(2026, 1, 15),
        method: PaymentMethod.cash,
        createdAt: DateTime(2026, 1, 15),
        updatedAt: DateTime(2026, 1, 15),
      ),
    ],
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockInvoiceDetailsBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<InvoiceDetailsBloc>(() => bloc);
    getIt.registerSingleton<SessionCubit>(sessionCubit);
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: false));
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
      home: const InvoiceDetailsPage(invoiceId: 'inv1'),
    );
  }

  testWidgets('shows a loading spinner while InvoiceDetailsLoading', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<InvoiceDetailsState>.empty(),
      initialState: InvoiceDetailsLoading(),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error view on InvoiceDetailsError', (tester) async {
    whenListen(
      bloc,
      const Stream<InvoiceDetailsState>.empty(),
      initialState: const InvoiceDetailsError('Server error'),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Server error'), findsOneWidget);
  });

  testWidgets(
    'renders the invoice overview and payments on InvoiceDetailsLoaded',
    (tester) async {
      whenListen(
        bloc,
        const Stream<InvoiceDetailsState>.empty(),
        initialState: InvoiceDetailsLoaded(invoice),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('INV-2026-0001'), findsOneWidget);
      expect(find.text('500.00'), findsOneWidget);
    },
  );

  testWidgets(
    'hides the edit-invoice button when the user lacks finance.update',
    (tester) async {
      whenListen(
        bloc,
        const Stream<InvoiceDetailsState>.empty(),
        initialState: InvoiceDetailsLoaded(invoice),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('Edit Invoice'), findsNothing);
    },
  );
}
