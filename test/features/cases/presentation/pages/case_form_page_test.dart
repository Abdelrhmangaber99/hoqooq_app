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
import 'package:hqooq/features/cases/domain/entities/case_party_snapshot.dart';
import 'package:hqooq/features/cases/domain/entities/case_priority.dart';
import 'package:hqooq/features/cases/domain/entities/case_status.dart';
import 'package:hqooq/features/cases/domain/entities/legal_case.dart';
import 'package:hqooq/features/cases/presentation/bloc/case_form_bloc.dart';
import 'package:hqooq/features/cases/presentation/pages/case_form_page.dart';
import 'package:mocktail/mocktail.dart';

class MockCaseFormBloc extends MockBloc<CaseFormEvent, CaseFormState>
    implements CaseFormBloc {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

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

  final user = User(
    id: 'u1',
    email: 'admin@firm.com',
    fullName: 'Firm Admin',
    status: 'ACTIVE',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    tenant: const TenantRef(id: 't1', name: 'Firm'),
  );

  final legalCase = LegalCase(
    id: 'c1',
    tenantId: 't1',
    caseNumber: 'CASE-2026-00001',
    title: 'Existing case',
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
    courtName: 'District Court',
    governorateId: 'gov-1',
    team: const [],
  );

  setUpAll(() async {
    registerFallbackValue(const LoadCaseFormReferenceDataRequested());
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockCaseFormBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<CaseFormBloc>(() => bloc);
    getIt.registerSingleton<SessionCubit>(sessionCubit);
    when(
      () => sessionCubit.state,
    ).thenReturn(SessionAuthenticated(user, isFirmAdmin: true));
    whenListen(
      bloc,
      const Stream<CaseFormState>.empty(),
      initialState: CaseFormReady(courts: [], caseTypes: const []),
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

  testWidgets('updates without requiring the existing court to be reselected', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable(existingCase: legalCase));
    await tester.pumpAndSettle();
    clearInteractions(bloc);

    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pump();

    final event =
        verify(() => bloc.add(captureAny())).captured.single
            as UpdateCaseSubmitted;
    expect(event.id, 'c1');
    expect(event.request.toJson(), isNot(contains('governorateId')));
    expect(event.request.toJson(), isNot(contains('defaultCourtId')));
    expect(event.request.toJson(), isNot(contains('circuitId')));
  });

  testWidgets('renders the create-mode form with empty fields and a client/'
      'case-type picker', (tester) async {
    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('New Case'), findsOneWidget);
    expect(find.text('Case Information'), findsOneWidget);
    expect(find.textContaining('AGREED FEE'), findsOneWidget);
    expect(find.text('Court (optional)'), findsOneWidget);

    expect(find.text('Responsible Lawyer (optional)'), findsOneWidget);
    expect(find.text('Create Case'), findsOneWidget);
    expect(find.textContaining('CASE-2026-00001'), findsNothing);
  });
}
