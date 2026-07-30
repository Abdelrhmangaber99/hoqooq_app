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
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/case_type_lookup.dart';
import 'package:hqooq/features/cases/domain/entities/court.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_details_bloc.dart';
import 'package:hqooq/features/cases/presentation/pages/case_details_page.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:mocktail/mocktail.dart';

class MockCaseDetailsBloc extends MockBloc<CaseDetailsEvent, CaseDetailsState>
    implements CaseDetailsBloc {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

/// Preloaded synchronously to avoid the real JSON delegate's async-load
/// flakiness across multiple testWidgets blocks in one file (see
/// login_page_test.dart / CLAUDE.md).
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
  late MockCaseDetailsBloc bloc;
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
    primaryLawyerId: 'u1',
    primaryLawyer: User(
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
    ),
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
    agreedFee: 5000.0,
    team: const [],
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() {
    getIt.reset();
    bloc = MockCaseDetailsBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<CaseDetailsBloc>(() => bloc);
    getIt.registerSingleton<SessionCubit>(sessionCubit);
    whenListen(
      bloc,
      const Stream<CaseDetailsState>.empty(),
      initialState: CaseDetailsLoaded(legalCase),
    );
  });

  tearDown(() {
    getIt.reset();
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
      home: const CaseDetailsPage(caseId: 'c1'),
    );
  }

  testWidgets('hides agreedFee when there is no authenticated session', (
    tester,
  ) async {
    when(() => sessionCubit.state).thenReturn(const SessionUnknown());

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('5000.00'), findsNothing);
    expect(find.text('Agreed Fee'), findsNothing);
  });

  testWidgets('hides agreedFee for an authenticated non-Firm-Admin user '
      '(BR-026 — never shown to everyone by default)', (tester) async {
    final user = legalCase.primaryLawyer;
    when(() => sessionCubit.state).thenReturn(SessionAuthenticated(user));

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    // isFirmAdmin is hardcoded false today (no confirmed role.code value
    // — see CLAUDE.md), so this is the only reachable branch right now.
    // If isFirmAdmin ever becomes real, this test should be extended
    // with a case where it's true and agreedFee IS expected to show.
    expect(user.isFirmAdmin, isFalse);
    expect(find.text('5000.00'), findsNothing);
    expect(find.text('Agreed Fee'), findsNothing);
  });

  testWidgets('renders the case overview and team', (tester) async {
    when(() => sessionCubit.state).thenReturn(const SessionUnknown());

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('CASE-2026-00001'), findsOneWidget);
    expect(find.text('Civil'), findsOneWidget);
    expect(find.text('Carlos Hernandez'), findsOneWidget);
    expect(find.text('District Court'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
  });
}
