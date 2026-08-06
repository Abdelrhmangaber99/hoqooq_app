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
import 'package:hqooq/features/cases/domain/entities/case_access_level.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/case_team_member.dart';
import 'package:hqooq/features/cases/domain/entities/case_type_lookup.dart';
import 'package:hqooq/features/cases/domain/entities/court.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_details_bloc.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_documents_bloc.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_financial_summary_bloc.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_hearings_bloc.dart';
import 'package:hqooq/features/cases/presentation/pages/case_details_page.dart';
import 'package:hqooq/features/clients/domain/entities/client.dart';
import 'package:hqooq/features/clients/domain/entities/client_status.dart';
import 'package:hqooq/features/clients/domain/entities/client_type.dart';
import 'package:hqooq/features/documents/presentation/bloc/document_upload_bloc.dart';
import 'package:hqooq/features/finance/domain/entities/payment_status.dart';
import 'package:hqooq/features/finance/domain/entities/single_case_financial_detail.dart';
import 'package:mocktail/mocktail.dart';

class MockCaseDetailsBloc extends MockBloc<CaseDetailsEvent, CaseDetailsState>
    implements CaseDetailsBloc {}

class MockCaseHearingsBloc
    extends MockBloc<CaseHearingsEvent, CaseHearingsState>
    implements CaseHearingsBloc {}

class MockCaseDocumentsBloc
    extends MockBloc<CaseDocumentsEvent, CaseDocumentsState>
    implements CaseDocumentsBloc {}

class MockDocumentUploadBloc
    extends MockBloc<DocumentUploadEvent, DocumentUploadState>
    implements DocumentUploadBloc {}

class MockCaseFinancialSummaryBloc
    extends MockBloc<CaseFinancialSummaryEvent, CaseFinancialSummaryState>
    implements CaseFinancialSummaryBloc {}

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
  late MockCaseHearingsBloc hearingsBloc;
  late MockCaseDocumentsBloc documentsBloc;
  late MockDocumentUploadBloc documentUploadBloc;
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
    team: [
      CaseTeamMember(
        id: 'ct-1',
        accessLevel: CaseAccessLevel.fullAccess,
        userId: user.id,
        user: user,
      ),
    ],
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockCaseDetailsBloc();
    hearingsBloc = MockCaseHearingsBloc();
    documentsBloc = MockCaseDocumentsBloc();
    documentUploadBloc = MockDocumentUploadBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<CaseDetailsBloc>(() => bloc);
    getIt.registerFactory<CaseHearingsBloc>(() => hearingsBloc);
    getIt.registerFactory<CaseDocumentsBloc>(() => documentsBloc);
    getIt.registerFactory<DocumentUploadBloc>(() => documentUploadBloc);
    getIt.registerSingleton<SessionCubit>(sessionCubit);
    whenListen(
      bloc,
      const Stream<CaseDetailsState>.empty(),
      initialState: CaseDetailsLoaded(legalCase),
    );
    whenListen(
      hearingsBloc,
      const Stream<CaseHearingsState>.empty(),
      initialState: const CaseHearingsLoaded([]),
    );
    whenListen(
      documentsBloc,
      const Stream<CaseDocumentsState>.empty(),
      initialState: const CaseDocumentsLoaded([]),
    );
    whenListen(
      documentUploadBloc,
      const Stream<DocumentUploadState>.empty(),
      initialState: DocumentUploadInitial(),
    );
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
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: false));

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('5000.00'), findsNothing);
    expect(find.text('Agreed Fee'), findsNothing);
  });

  testWidgets('shows agreedFee for an authenticated Firm Admin', (
    tester,
  ) async {
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: true));

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('5000.00'), findsOneWidget);
    expect(find.text('Agreed Fee'), findsOneWidget);
  });

  testWidgets('hides the Financials section when the user lacks finance.read '
      '(gated on finance.read, not isFirmAdmin -- Accountant needs this too)', (
    tester,
  ) async {
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: true));

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Financials'), findsNothing);
  });

  testWidgets('shows the Financials section for a user holding finance.read', (
    tester,
  ) async {
    final accountant = user.copyWith(
      roles: const [
        Role(
          id: 'r1',
          code: 'ACCOUNTANT',
          scope: 'TENANT',
          permissions: [Permission(id: 'p1', code: 'finance.read')],
        ),
      ],
    );
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(accountant, isFirmAdmin: false));
    final financialSummaryBloc = MockCaseFinancialSummaryBloc();
    getIt.registerFactory<CaseFinancialSummaryBloc>(() => financialSummaryBloc);
    whenListen(
      financialSummaryBloc,
      const Stream<CaseFinancialSummaryState>.empty(),
      initialState: const CaseFinancialSummaryLoaded(
        SingleCaseFinancialDetail(
          caseId: 'c1',
          caseNumber: 'CASE-2026-00001',
          clientName: 'Carlos Hernandez',
          totalInvoiced: 15000,
          totalPaid: 10000,
          outstandingBalance: 5000,
          paymentStatus: PaymentStatus.partial,
          invoices: [],
        ),
      ),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Financials'), findsOneWidget);
    expect(find.text('5000.00'), findsOneWidget);
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

  testWidgets('renders gracefully when caseType/team-user are absent (the real '
      'backend never returns caseType -- CasesService does not load that '
      'relation)', (tester) async {
    final degradedCase = legalCase.copyWith(
      caseType: null,
      defaultCourt: null,
      team: [
        const CaseTeamMember(
          id: 'ct-1',
          accessLevel: CaseAccessLevel.fullAccess,
          userId: 'u2',
        ),
      ],
    );
    whenListen(
      bloc,
      const Stream<CaseDetailsState>.empty(),
      initialState: CaseDetailsLoaded(degradedCase),
    );
    when(() => sessionCubit.state).thenReturn(const SessionUnknown());

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    // No crash, and unresolved relations fall back to a placeholder or the
    // raw id rather than throwing a null-cast error.
    expect(find.text('CASE-2026-00001'), findsOneWidget);
    expect(find.text('Unknown'), findsWidgets);
    expect(find.text('u2'), findsOneWidget);
  });

  testWidgets(
    'tapping the Documents upload icon shows Take Photo / Choose File '
    'options',
    (tester) async {
      when(() => sessionCubit.state).thenReturn(const SessionUnknown());

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      final uploadIcon = find.byIcon(Icons.add_circle_outline);
      await tester.ensureVisible(uploadIcon);
      await tester.pumpAndSettle();
      await tester.tap(uploadIcon);
      await tester.pumpAndSettle();

      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose File'), findsOneWidget);
    },
  );

  testWidgets(
    'shows a progress bar while DocumentUploadBloc reports an in-progress '
    'upload',
    (tester) async {
      when(() => sessionCubit.state).thenReturn(const SessionUnknown());
      whenListen(
        documentUploadBloc,
        const Stream<DocumentUploadState>.empty(),
        initialState: const DocumentUploadInProgress(0.5),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      expect(find.text('Uploading...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    },
  );
}
