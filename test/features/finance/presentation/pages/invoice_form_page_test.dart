import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/finance/domain/entities/invoice.dart';
import 'package:hqooq/features/finance/domain/entities/invoice_status.dart';
import 'package:hqooq/features/finance/presentation/bloc/invoice_form_bloc.dart';
import 'package:hqooq/features/finance/presentation/pages/invoice_form_page.dart';

class MockInvoiceFormBloc extends MockBloc<InvoiceFormEvent, InvoiceFormState>
    implements InvoiceFormBloc {}

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
  late MockInvoiceFormBloc bloc;

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
    bloc = MockInvoiceFormBloc();
    getIt.registerFactory<InvoiceFormBloc>(() => bloc);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestable({Invoice? existingInvoice}) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: [
        _PreloadedAppLocalizationsDelegate(preloadedEn),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: InvoiceFormPage(existingInvoice: existingInvoice),
    );
  }

  testWidgets('renders empty fields and the create-mode title', (tester) async {
    whenListen(
      bloc,
      const Stream<InvoiceFormState>.empty(),
      initialState: const InvoiceFormReady(clients: [], cases: []),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('New Invoice'), findsOneWidget);
    expect(find.text('Create Invoice'), findsOneWidget);
  });

  testWidgets('renders the edit form with the existing invoice\'s values', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<InvoiceFormState>.empty(),
      initialState: const InvoiceFormReady(clients: [], cases: []),
    );

    await tester.pumpWidget(buildTestable(existingInvoice: invoice));
    await tester.pumpAndSettle();

    expect(find.text('Edit Invoice'), findsOneWidget);
    expect(find.text('INV-2026-0001'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('shows a loading spinner while InvoiceFormLoading', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<InvoiceFormState>.empty(),
      initialState: InvoiceFormLoading(),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
