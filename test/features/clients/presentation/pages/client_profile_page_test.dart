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
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/case_type_lookup.dart';
import 'package:hqooq/features/cases/domain/entities/court.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:hqooq/features/clients/presentation/bloc/client_details_bloc.dart';
import 'package:hqooq/features/clients/presentation/pages/client_profile_page.dart';
import 'package:mocktail/mocktail.dart';

class MockClientDetailsBloc
    extends MockBloc<ClientDetailsEvent, ClientDetailsState>
    implements ClientDetailsBloc {}

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
  late MockClientDetailsBloc bloc;
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
    roles: const [
      Role(
        id: 'r1',
        code: 'LAWYER',
        scope: 'TENANT',
        permissions: [Permission(id: 'p1', code: 'clients.update')],
      ),
    ],
    tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
  );

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

  final legalCase = LegalCase(
    id: 'c1',
    tenantId: 't1',
    caseNumber: 'CASE-2026-00001',
    status: CaseStatus.active,
    clientId: 'cl1',
    caseTypeId: 'ct1',
    priority: CasePriority.high,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    client: client,
    caseType: const CaseTypeLookup(id: 'ct1', name: 'Civil'),
    defaultCourtId: 'co1',
    defaultCourt: Court(
      id: 'co1',
      name: 'District Court',
      type: 'FIRST_INSTANCE',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    team: const [],
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockClientDetailsBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<ClientDetailsBloc>(() => bloc);
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
      home: const ClientProfilePage(clientId: 'cl1'),
    );
  }

  testWidgets('shows a loading spinner while ClientDetailsLoading', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<ClientDetailsState>.empty(),
      initialState: ClientDetailsLoading(),
    );

    await tester.pumpWidget(buildTestable());
    // Not pumpAndSettle: an indeterminate CircularProgressIndicator never
    // settles.
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error view on ClientDetailsError', (tester) async {
    whenListen(
      bloc,
      const Stream<ClientDetailsState>.empty(),
      initialState: const ClientDetailsError('Server error'),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Server error'), findsOneWidget);
  });

  testWidgets(
    'renders the client profile and case list on ClientDetailsLoaded',
    (tester) async {
      whenListen(
        bloc,
        const Stream<ClientDetailsState>.empty(),
        initialState: ClientDetailsLoaded(client, [legalCase]),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('Carlos Hernandez'), findsOneWidget);
      expect(find.text('carlos@example.com'), findsOneWidget);
      expect(find.text('CASE-2026-00001'), findsOneWidget);
    },
  );

  testWidgets(
    'shows the no-cases message when ClientDetailsLoaded has an empty case list',
    (tester) async {
      whenListen(
        bloc,
        const Stream<ClientDetailsState>.empty(),
        initialState: ClientDetailsLoaded(client, const []),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('Carlos Hernandez'), findsOneWidget);
      expect(find.text('CASE-2026-00001'), findsNothing);
    },
  );
}
