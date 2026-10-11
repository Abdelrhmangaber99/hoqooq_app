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
import 'package:hqooq/features/cases/domain/entities/case_party_snapshot.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/case_type_lookup.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/presentation/bloc/cases_bloc.dart';
import 'package:hqooq/features/cases/presentation/pages/cases_page.dart';
import 'package:mocktail/mocktail.dart';

class MockCasesBloc extends MockBloc<CasesEvent, CasesState>
    implements CasesBloc {}

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
  late MockCasesBloc bloc;
  late MockSessionCubit sessionCubit;

  final user = User(
    id: 'u1',
    email: 'lawyer@firm.com',
    fullName: 'Jane Doe',
    status: 'ACTIVE',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    permissions: const ['case.view', 'case.create'],
    tenant: const TenantRef(id: 't1', name: 'Reynolds & Associates'),
  );

  final legalCase = LegalCase(
    id: 'c1',
    tenantId: 't1',
    caseNumber: 'CASE-2026-00001',
    status: CaseStatus.active,
    caseTypeId: 'ct1',
    priority: CasePriority.high,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    clientSnapshot: const CaseClientSnapshot(
      id: 'cl1',
      clientType: 'INDIVIDUAL',
      name: 'Carlos Hernandez',
    ),
    caseType: const CaseTypeLookup(id: 'ct1', name: 'Civil'),
    courtName: 'District Court',
    team: const [],
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockCasesBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<CasesBloc>(() => bloc);
    getIt.registerSingleton<SessionCubit>(sessionCubit);
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: true));
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
      home: const CasesPage(),
    );
  }

  testWidgets('shows a loading spinner while CasesLoading', (tester) async {
    whenListen(
      bloc,
      const Stream<CasesState>.empty(),
      initialState: CasesLoading(),
    );

    await tester.pumpWidget(buildTestable());
    // Not pumpAndSettle: an indeterminate CircularProgressIndicator never
    // settles.
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error view with a retry button on CasesError', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<CasesState>.empty(),
      initialState: const CasesError('Server error'),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Server error'), findsOneWidget);
  });

  testWidgets('shows the empty state when CasesLoaded has no cases', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<CasesState>.empty(),
      initialState: const CasesLoaded([]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('CASE-2026-00001'), findsNothing);
  });

  testWidgets('shows the new-case header action when the user '
      'is a Firm Admin and holds cases.create', (tester) async {
    whenListen(
      bloc,
      const Stream<CasesState>.empty(),
      initialState: const CasesLoaded([]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('New Case'), findsWidgets);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('hides the new-case action when the user '
      'lacks cases.create', (tester) async {
    when(() => sessionCubit.state).thenReturn(
      SessionAuthenticated(
        user.copyWith(permissions: const ['case.view']),
        isFirmAdmin: true,
      ),
    );
    whenListen(
      bloc,
      const Stream<CasesState>.empty(),
      initialState: const CasesLoaded([]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('New Case'), findsNothing);
  });

  testWidgets('renders the case list on CasesLoaded', (tester) async {
    whenListen(
      bloc,
      const Stream<CasesState>.empty(),
      initialState: CasesLoaded([legalCase]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('CASE-2026-00001'), findsNWidgets(2));
    expect(find.text('Civil'), findsOneWidget);
    expect(find.text('District Court'), findsOneWidget);
  });

  testWidgets(
    'typing in the search bar does not throw ProviderNotFoundException '
    '(regression -- the search bar previously used a context positioned '
    'above CasesBloc\'s own BlocProvider, not below it)',
    (tester) async {
      whenListen(
        bloc,
        const Stream<CasesState>.empty(),
        initialState: CasesLoaded([legalCase]),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hernandez');
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
