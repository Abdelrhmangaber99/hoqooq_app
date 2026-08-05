import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/court.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_form_bloc.dart';
import 'package:hqooq/features/cases/presentation/pages/case_form_page.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:mocktail/mocktail.dart';

class MockCaseFormBloc extends MockBloc<CaseFormEvent, CaseFormState>
    implements CaseFormBloc {}

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
  late MockCaseFormBloc bloc;
  late MockSessionCubit sessionCubit;

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
    client: Client(
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
    ),
    defaultCourtId: 'co1',
    team: const [],
  );

  final court = Court(
    id: 'co1',
    name: 'District Court',
    type: 'FIRST_INSTANCE',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockCaseFormBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<CaseFormBloc>(() => bloc);
    getIt.registerSingleton<SessionCubit>(sessionCubit);
    when(() => sessionCubit.state).thenReturn(const SessionUnknown());
    whenListen(
      bloc,
      const Stream<CaseFormState>.empty(),
      initialState: CaseFormReady(
        courts: [court],
        users: const [],
        clients: const [],
        caseTypes: const [],
      ),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestable({LegalCase? existingCase}) {
    final router = GoRouter(
      initialLocation: '/form',
      routes: [
        GoRoute(
          path: '/form',
          builder: (context, state) => CaseFormPage(existingCase: existingCase),
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

  testWidgets('renders the edit form with the existing case\'s values', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable(existingCase: legalCase));
    await tester.pumpAndSettle();

    expect(find.text('Edit Case'), findsOneWidget);
    expect(find.textContaining('CASE-2026-00001'), findsOneWidget);
    expect(find.text('District Court'), findsOneWidget);
  });

  testWidgets('hides agreedFee for a non-Firm-Admin session', (tester) async {
    await tester.pumpWidget(buildTestable(existingCase: legalCase));
    await tester.pumpAndSettle();

    expect(find.text('AGREED FEE'), findsNothing);
  });

  testWidgets('shows agreedFee for an authenticated Firm Admin', (
    tester,
  ) async {
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
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: true));

    await tester.pumpWidget(buildTestable(existingCase: legalCase));
    await tester.pumpAndSettle();

    expect(find.text('AGREED FEE'), findsOneWidget);
  });

  testWidgets('shows a loading indicator while reference data loads', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<CaseFormState>.empty(),
      initialState: CaseFormLoading(),
    );

    await tester.pumpWidget(buildTestable(existingCase: legalCase));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders the create-mode form with empty fields and a client/'
      'case-type picker', (tester) async {
    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('New Case'), findsOneWidget);
    expect(find.text('Create Case'), findsOneWidget);
    expect(find.textContaining('CASE-2026-00001'), findsNothing);
  });
}
