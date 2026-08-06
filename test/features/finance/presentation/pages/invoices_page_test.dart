import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/permission.dart';
import 'package:hqooq/features/authentication/domain/entities/role.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/finance/domain/entities/invoice.dart';
import 'package:hqooq/features/finance/domain/entities/invoice_status.dart';
import 'package:hqooq/features/finance/presentation/bloc/invoices_bloc.dart';
import 'package:hqooq/features/finance/presentation/pages/invoices_page.dart';
import 'package:mocktail/mocktail.dart';

class MockInvoicesBloc extends MockBloc<InvoicesEvent, InvoicesState>
    implements InvoicesBloc {}

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
  late MockInvoicesBloc bloc;
  late MockSessionCubit sessionCubit;

  final user = User(
    id: 'u1',
    email: 'accountant@firm.com',
    fullName: 'Jane Doe',
    isSuperAdmin: false,
    status: 'ACTIVE',
    mfaEnabled: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    roles: const [
      Role(
        id: 'r1',
        code: 'ACCOUNTANT',
        scope: 'TENANT',
        permissions: [Permission(id: 'p1', code: 'finance.create')],
      ),
    ],
    tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
  );

  final invoice = Invoice(
    id: 'inv1',
    tenantId: 't1',
    clientId: 'cl1',
    invoiceNumber: 'INV-2026-0001',
    status: InvoiceStatus.draft,
    issueDate: DateTime(2026, 1, 1),
    dueDate: DateTime(2026, 1, 31),
    subtotal: 1000,
    taxTotal: 100,
    grandTotal: 1100,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockInvoicesBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<InvoicesBloc>(() => bloc);
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
      home: const InvoicesPage(),
    );
  }

  testWidgets('shows a loading spinner while InvoicesLoading', (tester) async {
    whenListen(
      bloc,
      const Stream<InvoicesState>.empty(),
      initialState: InvoicesLoading(),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error view on InvoicesError', (tester) async {
    whenListen(
      bloc,
      const Stream<InvoicesState>.empty(),
      initialState: const InvoicesError('Server error'),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Server error'), findsOneWidget);
  });

  testWidgets('shows the empty state when InvoicesLoaded has no invoices', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<InvoicesState>.empty(),
      initialState: const InvoicesLoaded([]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('INV-2026-0001'), findsNothing);
  });

  testWidgets('renders the invoice list on InvoicesLoaded', (tester) async {
    whenListen(
      bloc,
      const Stream<InvoicesState>.empty(),
      initialState: InvoicesLoaded([invoice]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('INV-2026-0001'), findsOneWidget);
  });

  testWidgets('shows the new-invoice FAB when the user holds finance.create', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<InvoicesState>.empty(),
      initialState: const InvoicesLoaded([]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('hides the new-invoice FAB when the user lacks finance.create', (
    tester,
  ) async {
    when(() => sessionCubit.state).thenReturn(
      SessionAuthenticated(user.copyWith(roles: const []), isFirmAdmin: false),
    );
    whenListen(
      bloc,
      const Stream<InvoicesState>.empty(),
      initialState: const InvoicesLoaded([]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
