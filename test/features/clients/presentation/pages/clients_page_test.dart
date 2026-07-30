import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:hqooq/features/clients/presentation/bloc/clients_bloc.dart';
import 'package:hqooq/features/clients/presentation/pages/clients_page.dart';

class MockClientsBloc extends MockBloc<ClientsEvent, ClientsState>
    implements ClientsBloc {}

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
  late MockClientsBloc bloc;

  final client = Client(
    id: 'cl1',
    tenantId: 't1',
    clientCode: 'CLI-001',
    type: ClientType.individual,
    fullName: 'Carlos Hernandez',
    status: ClientStatus.active,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    emails: const ['carlos@example.com'],
    phones: const [],
    addresses: const [],
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockClientsBloc();
    getIt.registerFactory<ClientsBloc>(() => bloc);
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
      home: const ClientsPage(),
    );
  }

  testWidgets('shows a loading spinner while ClientsLoading', (tester) async {
    whenListen(
      bloc,
      const Stream<ClientsState>.empty(),
      initialState: ClientsLoading(),
    );

    await tester.pumpWidget(buildTestable());
    // Not pumpAndSettle: an indeterminate CircularProgressIndicator never
    // settles.
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error view on ClientsError', (tester) async {
    whenListen(
      bloc,
      const Stream<ClientsState>.empty(),
      initialState: const ClientsError('Server error'),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Server error'), findsOneWidget);
  });

  testWidgets('shows the empty state when ClientsLoaded has no clients', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<ClientsState>.empty(),
      initialState: const ClientsLoaded([]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Carlos Hernandez'), findsNothing);
  });

  testWidgets('renders the client list on ClientsLoaded', (tester) async {
    whenListen(
      bloc,
      const Stream<ClientsState>.empty(),
      initialState: ClientsLoaded([client]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Carlos Hernandez'), findsOneWidget);
    expect(find.text('CLI-001'), findsOneWidget);
  });

  testWidgets(
    'typing in the search bar does not throw ProviderNotFoundException '
    '(regression -- the search bar previously used a context positioned '
    'above ClientsBloc\'s own BlocProvider, not below it)',
    (tester) async {
      whenListen(
        bloc,
        const Stream<ClientsState>.empty(),
        initialState: ClientsLoaded([client]),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hernandez');
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
