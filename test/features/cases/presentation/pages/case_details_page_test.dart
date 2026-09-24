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
import 'package:hqooq/features/cases/domain/entities/case_access_level.dart';
import 'package:hqooq/features/cases/domain/entities/case_party_snapshot.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/case_team_member.dart';
import 'package:hqooq/features/cases/domain/entities/case_timeline_event.dart';
import 'package:hqooq/features/cases/domain/entities/case_type_lookup.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_details_bloc.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_documents_bloc.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_hearings_bloc.dart';
import 'package:hqooq/features/cases/presentation/pages/case_details_page.dart';
import 'package:hqooq/features/documents/presentation/bloc/document_upload_bloc.dart';
import 'package:hqooq/features/finance/domain/entities/case_finance_detail.dart';
import 'package:hqooq/features/finance/presentation/bloc/case_ledger_bloc.dart';
import 'package:hqooq/features/finance/presentation/bloc/payment_form_bloc.dart';
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

class MockCaseLedgerBloc extends MockBloc<CaseLedgerEvent, CaseLedgerState>
    implements CaseLedgerBloc {}

class MockPaymentFormBloc extends MockBloc<PaymentFormEvent, PaymentFormState>
    implements PaymentFormBloc {}

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
  late MockCaseLedgerBloc caseLedgerBloc;
  late MockPaymentFormBloc paymentFormBloc;
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
    caseLedgerBloc = MockCaseLedgerBloc();
    paymentFormBloc = MockPaymentFormBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<CaseDetailsBloc>(() => bloc);
    getIt.registerFactory<CaseHearingsBloc>(() => hearingsBloc);
    getIt.registerFactory<CaseDocumentsBloc>(() => documentsBloc);
    getIt.registerFactory<DocumentUploadBloc>(() => documentUploadBloc);
    getIt.registerFactory<CaseLedgerBloc>(() => caseLedgerBloc);
    getIt.registerFactory<PaymentFormBloc>(() => paymentFormBloc);
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
    whenListen(
      caseLedgerBloc,
      const Stream<CaseLedgerState>.empty(),
      initialState: const CaseLedgerInitial(),
    );
    whenListen(
      paymentFormBloc,
      const Stream<PaymentFormState>.empty(),
      initialState: const PaymentFormInitial(),
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

  testWidgets('renders the case overview and team', (tester) async {
    // `client.view` needed to render the client-snapshot section.
    when(() => sessionCubit.state).thenReturn(
      SessionAuthenticated(
        user.copyWith(permissions: const ['client.view']),
        isFirmAdmin: false,
      ),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('CASE-2026-00001'), findsWidgets);
    expect(find.text('Civil'), findsOneWidget);
    // Appears twice once `client.view` is granted: once in the header
    // subtitle (always shown) and once in the gated Client-snapshot
    // section below it.
    expect(find.text('Carlos Hernandez'), findsWidgets);
    expect(find.text('District Court'), findsOneWidget);
    await tester.tap(find.text('Team'));
    await tester.pumpAndSettle();
    expect(find.text('Jane Doe'), findsOneWidget);
  });

  testWidgets('renders embedded Case timeline events', (tester) async {
    final caseWithTimeline = legalCase.copyWith(
      timelineEvents: [
        CaseTimelineEvent(
          id: 'event-1',
          caseId: legalCase.id,
          eventType: CaseTimelineEventType.statusChanged,
          actorUserId: user.id,
          previousState: 'DRAFT',
          newState: 'ACTIVE',
          note: 'Case status changed',
          createdAt: DateTime(2026, 8, 16, 10),
        ),
      ],
    );
    whenListen(
      bloc,
      const Stream<CaseDetailsState>.empty(),
      initialState: CaseDetailsLoaded(caseWithTimeline),
    );
    when(() => sessionCubit.state).thenReturn(const SessionUnknown());

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Case Timeline'), findsOneWidget);
    expect(find.text('Case status changed'), findsWidgets);
    expect(find.text('DRAFT → ACTIVE'), findsOneWidget);
  });

  testWidgets('renders gracefully when caseType/team-user are absent (the real '
      'backend never returns caseType -- CasesService does not load that '
      'relation)', (tester) async {
    final degradedCase = legalCase.copyWith(
      caseType: null,
      courtName: null,
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

    // No crash, and unresolved relations fall back gracefully
    expect(find.text('CASE-2026-00001'), findsWidgets);
  });



  testWidgets(
    'tapping the Documents upload icon shows Take Photo / Choose File '
    'options',
    (tester) async {
      final documentUser = user.copyWith(
        permissions: const ['document.view', 'document.upload'],
      );
      when(
        () => sessionCubit.state,
      ).thenReturn(SessionAuthenticated(documentUser, isFirmAdmin: false));

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Documents'));
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
      final documentUser = user.copyWith(
        permissions: const ['document.view', 'document.upload'],
      );
      when(
        () => sessionCubit.state,
      ).thenReturn(SessionAuthenticated(documentUser, isFirmAdmin: false));
      whenListen(
        documentUploadBloc,
        const Stream<DocumentUploadState>.empty(),
        initialState: const DocumentUploadInProgress(0.5),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();
      expect(find.text('Uploading...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'renders the v2 case finance ledger in its permission-gated tab',
    (tester) async {
      when(() => sessionCubit.state).thenReturn(
        SessionAuthenticated(
          user.copyWith(
            permissions: const [
              'finance.case.view',
              'finance.manage',
            ],
          ),
          isFirmAdmin: false,
        ),
      );
      whenListen(
        caseLedgerBloc,
        const Stream<CaseLedgerState>.empty(),
        initialState: const CaseLedgerLoaded(
          CaseFinanceDetail(
            caseId: 'c1',
            agreedFee: 10000,
            payments: [],
          ),
        ),
      );

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Finance'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finance'));
      await tester.pumpAndSettle();

      expect(find.text('Agreed Fee'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
      expect(find.text('Payment History'), findsOneWidget);
      expect(find.text('No payments recorded for this case yet'),
          findsOneWidget);
    },
  );
}
