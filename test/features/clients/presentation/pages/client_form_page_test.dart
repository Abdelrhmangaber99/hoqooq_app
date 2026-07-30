import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:hqooq/features/clients/presentation/bloc/client_form_bloc.dart';
import 'package:hqooq/features/clients/presentation/pages/client_form_page.dart';

class MockClientFormBloc extends MockBloc<ClientFormEvent, ClientFormState>
    implements ClientFormBloc {}

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
  late MockClientFormBloc bloc;

  final existingClient = Client(
    id: 'cl1',
    tenantId: 't1',
    clientCode: 'CLI-001',
    type: ClientType.individual,
    fullName: 'Carlos Hernandez',
    status: ClientStatus.active,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    emails: const [],
    phones: const [],
    addresses: const [],
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockClientFormBloc();
    getIt.registerFactory<ClientFormBloc>(() => bloc);
    whenListen(
      bloc,
      const Stream<ClientFormState>.empty(),
      initialState: ClientFormInitial(),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestable({Client? existingClient}) {
    final router = GoRouter(
      initialLocation: '/form',
      routes: [
        GoRoute(
          path: '/form',
          builder: (context, state) =>
              ClientFormPage(existingClient: existingClient),
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

  testWidgets('renders empty fields and the create-mode title', (tester) async {
    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('New Client'), findsOneWidget);
    expect(find.text('Create Client'), findsOneWidget);
  });

  testWidgets('renders pre-filled fields and the edit-mode title', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable(existingClient: existingClient));
    await tester.pumpAndSettle();

    expect(find.text('Edit Client'), findsOneWidget);
    expect(find.text('Carlos Hernandez'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets(
    'shows a loading indicator on the submit button while submitting',
    (tester) async {
      whenListen(
        bloc,
        const Stream<ClientFormState>.empty(),
        initialState: ClientFormSubmitting(),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('shows the failure message in a snackbar on ClientFormFailure', (
    tester,
  ) async {
    whenListen(
      bloc,
      Stream<ClientFormState>.fromIterable([
        const ClientFormFailure('clientCode must be a string'),
      ]),
      initialState: ClientFormInitial(),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('clientCode must be a string'), findsOneWidget);
  });
}
