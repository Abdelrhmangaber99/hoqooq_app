import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/role.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/subscriptions/presentation/bloc/subscription_reactivation_bloc.dart';
import 'package:hqooq/features/subscriptions/presentation/pages/subscription_inactive_page.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionReactivationBloc
    extends
        MockBloc<SubscriptionReactivationEvent, SubscriptionReactivationState>
    implements SubscriptionReactivationBloc {}

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
  late MockSubscriptionReactivationBloc bloc;
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

  final firmAdminUser = user.copyWith(
    roles: const [
      Role(id: 'r1', code: 'FIRM_ADMIN', scope: 'TENANT', permissions: []),
    ],
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockSubscriptionReactivationBloc();
    sessionCubit = MockSessionCubit();
    getIt.registerFactory<SubscriptionReactivationBloc>(() => bloc);
    getIt.registerSingleton<SessionCubit>(sessionCubit);
    whenListen(
      bloc,
      const Stream<SubscriptionReactivationState>.empty(),
      initialState: SubscriptionReactivationInitial(),
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
      home: const SubscriptionInactivePage(),
    );
  }

  testWidgets('shows an explanatory message with no action for a '
      'non-Firm-Admin user', (tester) async {
    when(() => sessionCubit.state).thenReturn(
      SessionSubscriptionInactive(user, message: 'Subscription expired'),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Subscription Inactive'), findsOneWidget);
    expect(find.text('Reactivate Subscription'), findsNothing);
  });

  testWidgets('shows a Reactivate action for a Firm Admin', (tester) async {
    when(() => sessionCubit.state).thenReturn(
      SessionSubscriptionInactive(
        firmAdminUser,
        message: 'Subscription expired',
      ),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Reactivate Subscription'), findsOneWidget);
  });

  testWidgets('shows a loading state on the Reactivate button while '
      'submitting', (tester) async {
    when(() => sessionCubit.state).thenReturn(
      SessionSubscriptionInactive(
        firmAdminUser,
        message: 'Subscription expired',
      ),
    );
    whenListen(
      bloc,
      const Stream<SubscriptionReactivationState>.empty(),
      initialState: SubscriptionReactivationSubmitting(),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
