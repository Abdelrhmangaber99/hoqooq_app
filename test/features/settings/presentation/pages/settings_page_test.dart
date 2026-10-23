import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/domain/repository/i_auth_repository.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:hqooq/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:hqooq/features/settings/presentation/pages/settings_page.dart';
import 'package:hqooq/features/subscriptions/presentation/bloc/subscription_cubit.dart';
import 'package:mocktail/mocktail.dart';

User _firmAdminUser() => User(
  id: 'u1',
  email: 'a@b.com',
  fullName: 'A B',
  status: 'ACTIVE',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
  accountType: 'FIRM_ADMIN',
  permissions: const ['firm.profile.manage'],
);

class MockDio extends Mock implements Dio {}

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

class _PreloadedAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _PreloadedAppLocalizationsDelegate(this._cache);

  final Map<Locale, AppLocalizations> _cache;

  @override
  bool isSupported(Locale locale) => _cache.containsKey(locale);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(_cache[locale]!);

  @override
  bool shouldReload(_PreloadedAppLocalizationsDelegate old) => false;
}

void main() {
  late MockDio dio;
  late MockAuthRepository authRepository;
  late MockProfileCubit profileCubit;
  late SessionCubit sessionCubit;
  late Map<Locale, AppLocalizations> localizationsCache;

  Map<String, dynamic> firmPayload({
    String name = 'Old Firm Name',
    String? logoUrl,
  }) => {
    'id': 'firm-1',
    'name': name,
    'address': 'Old address',
    'contactEmail': 'old@firm.com',
    if (logoUrl != null) 'logoUrl': logoUrl,
    'updatedAt': '2026-09-01T00:00:00.000Z',
    'subscriptions': [
      {
        'id': 'sub-1',
        'status': 'ACTIVE',
        'billingCycle': 'MONTHLY',
        'supersededAt': null,
        'isArchived': false,
        'plan': {'id': 'p1', 'name': 'Basic'},
      },
    ],
  };

  Response<T> ok<T>(String path, T data) => Response<T>(
    requestOptions: RequestOptions(path: path),
    data: data,
    statusCode: 200,
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final en = AppLocalizations(const Locale('en'));
    await en.load();
    final ar = AppLocalizations(const Locale('ar'));
    await ar.load();
    localizationsCache = {const Locale('en'): en, const Locale('ar'): ar};

    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(FormData());
    registerFallbackValue(ThemeMode.system);
  });

  setUp(() async {
    await getIt.reset();
    dio = MockDio();
    authRepository = MockAuthRepository();
    profileCubit = MockProfileCubit();

    when(() => profileCubit.state).thenReturn(
      const ProfileState(themeMode: ThemeMode.system, locale: Locale('en')),
    );
    when(() => profileCubit.stream).thenAnswer(
      (_) => Stream.value(
        const ProfileState(themeMode: ThemeMode.system, locale: Locale('en')),
      ),
    );

    getIt.registerLazySingleton<Dio>(() => dio);
    sessionCubit = SessionCubit();
    // SubscriptionCubit loads the firm record from the session, so it needs
    // that cubit. The registration is lazy — it is constructed when the screen
    // under test first resolves it, by which point the session exists.
    getIt.registerLazySingleton<SubscriptionCubit>(
      () => SubscriptionCubit(dio, sessionCubit),
    );
    sessionCubit.authenticated(_firmAdminUser(), 'token', isFirmAdmin: true);
    getIt.registerLazySingleton<SessionCubit>(() => sessionCubit);
    getIt.registerLazySingleton<ProfileCubit>(() => profileCubit);
    getIt.registerFactory<SettingsCubit>(
      () => SettingsCubit(authRepository, sessionCubit),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestable() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(authRepository, sessionCubit),
        ),
        BlocProvider<ProfileCubit>.value(value: profileCubit),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: [
          _PreloadedAppLocalizationsDelegate(localizationsCache),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('ar')],
        home: const SettingsPage(),
      ),
    );
  }

  Future<void> withLargeSurface(
    WidgetTester tester,
    Future<void> Function() body,
  ) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await body();
  }

  group('firm info panel — immediate refresh after save', () {
    testWidgets(
      'shows the new firm name in state-driven UI right after a successful '
      'save, with no reload or navigation',
      (tester) async {
        await withLargeSurface(tester, () async {
          when(
            () => dio.get('/tenants/my-firm'),
          ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
          when(
            () => dio.get('/subscriptions/plans'),
          ).thenAnswer((_) async => ok('/subscriptions/plans', <dynamic>[]));

          await tester.pumpWidget(buildTestable());
          await tester.pumpAndSettle();

          expect(find.text('Old Firm Name'), findsOneWidget);

          when(
            () => dio.patch('/tenants/my-firm', data: any(named: 'data')),
          ).thenAnswer((_) async => ok('/tenants/my-firm', null));
          when(() => dio.get('/tenants/my-firm')).thenAnswer(
            (_) async =>
                ok('/tenants/my-firm', firmPayload(name: 'New Firm Name')),
          );

          await tester.enterText(
            find.byType(TextFormField).first,
            'New Firm Name',
          );
          await tester.tap(find.text('Save Changes'));
          await tester.pumpAndSettle();

          expect(find.text('Changes saved successfully'), findsOneWidget);
          // The sidebar renders the firm name, so the sanctioned UI is the
          // authoritative confirmation that the refetched payload replaced
          // the displayed one without a reload or navigation.
          expect(find.text('New Firm Name'), findsOneWidget);
          expect(find.text('Old Firm Name'), findsNothing);
          // Three reads: the session-driven load that now backs the sidebar's
          // workspace identity, the panel's own entry fetch, and the refetch
          // after the save — the last being the behaviour under test.
          verify(() => dio.get('/tenants/my-firm')).called(3);
        });
      },
    );

    testWidgets(
      'keeps the form and shows the server error when the save fails',
      (tester) async {
        await withLargeSurface(tester, () async {
          when(
            () => dio.get('/tenants/my-firm'),
          ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
          when(
            () => dio.get('/subscriptions/plans'),
          ).thenAnswer((_) async => ok('/subscriptions/plans', <dynamic>[]));

          await tester.pumpWidget(buildTestable());
          await tester.pumpAndSettle();

          when(
            () => dio.patch('/tenants/my-firm', data: any(named: 'data')),
          ).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/tenants/my-firm'),
              response: Response(
                requestOptions: RequestOptions(path: '/tenants/my-firm'),
                statusCode: 403,
                data: {'message': 'Insufficient permissions'},
              ),
              type: DioExceptionType.badResponse,
            ),
          );

          await tester.tap(find.text('Save Changes'));
          await tester.pumpAndSettle();

          expect(find.text('Changes saved successfully'), findsNothing);
          expect(find.text('Insufficient permissions'), findsOneWidget);
          expect(find.text('Old Firm Name'), findsOneWidget);
        });
      },
    );
  });

  group('personal profile panel', () {
    Future<void> openPersonalProfilePanel(WidgetTester tester) async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      when(
        () => dio.get('/subscriptions/plans'),
      ).thenAnswer((_) async => ok('/subscriptions/plans', <dynamic>[]));

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Personal Information').first);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'shows current user data, saves changes and updates session state',
      (tester) async {
        await withLargeSurface(tester, () async {
          await openPersonalProfilePanel(tester);

          expect(find.text('AB'), findsOneWidget);
          expect(
            find.byWidgetPredicate(
              (w) => w is TextFormField && w.controller?.text == 'A B',
            ),
            findsOneWidget,
          );

          // No avatar field exists in this panel: the backend exposes no
          // avatar upload route, and an empty value would clear a value the
          // user never saw. `avatarUrl`/`phone` are therefore omitted from the
          // request entirely rather than sent blank.
          expect(find.text('AVATAR URL'), findsNothing);

          final updatedUser = _firmAdminUser().copyWith(
            fullName: 'Updated Name',
          );

          when(
            () => authRepository.updateProfile(
              userId: 'u1',
              fullName: 'Updated Name',
            ),
          ).thenAnswer((_) async => Right(updatedUser));

          final nameField = find.byType(TextFormField).first;
          await tester.enterText(nameField, 'Updated Name');

          await tester.tap(find.text('Save Changes'));
          await tester.pumpAndSettle();

          expect(find.text('Profile updated successfully'), findsOneWidget);
          expect(
            (sessionCubit.state as SessionAuthenticated).user.fullName,
            'Updated Name',
          );
        });
      },
    );
  });

  group('appearance & language preferences panel', () {
    Future<void> openPreferencesPanel(WidgetTester tester) async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      when(
        () => dio.get('/subscriptions/plans'),
      ).thenAnswer((_) async => ok('/subscriptions/plans', <dynamic>[]));

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Appearance & Language').first);
      await tester.pumpAndSettle();
    }

    testWidgets('no longer offers a theme switch — the app is light-only', (
      tester,
    ) async {
      await withLargeSurface(tester, () async {
        await openPreferencesPanel(tester);

        expect(find.text('Light'), findsNothing);
        expect(find.text('Dark'), findsNothing);
        expect(find.text('System'), findsNothing);
        verifyNever(() => profileCubit.setThemeMode(any()));
      });
    });

    testWidgets('switching language invokes profileCubit.toggleLocale', (
      tester,
    ) async {
      await withLargeSurface(tester, () async {
        await openPreferencesPanel(tester);

        await tester.tap(find.byType(OutlinedButton));
        await tester.pumpAndSettle();

        verify(() => profileCubit.toggleLocale()).called(1);
      });
    });
  });

  group('subscription section', () {
    // The standalone Subscription page was folded into Settings, so this panel
    // is now the only place the firm's plan and status are shown.
    Future<void> openSubscriptionPanel(WidgetTester tester) async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      when(
        () => dio.get('/subscriptions/plans'),
      ).thenAnswer((_) async => ok('/subscriptions/plans', <dynamic>[]));

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Subscription plan & billing'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders the plan, cycle and status from the firm record', (
      tester,
    ) async {
      await withLargeSurface(tester, () async {
        await openSubscriptionPanel(tester);

        expect(find.text('Basic'), findsOneWidget);
        expect(find.text('Active'), findsOneWidget);
        expect(find.textContaining('Monthly'), findsOneWidget);
        // Still an inline section, not a pushed page.
        expect(find.text('Subscription plan & billing'), findsOneWidget);
      });
    });
  });

  group('password panel', () {
    Future<void> openPasswordPanel(WidgetTester tester) async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      when(
        () => dio.get('/subscriptions/plans'),
      ).thenAnswer((_) async => ok('/subscriptions/plans', <dynamic>[]));

      await tester.pumpWidget(buildTestable());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change Password').first);
      await tester.pumpAndSettle();
    }

    testWidgets('shows the success state and clears the fields after a '
        'successful change', (tester) async {
      await withLargeSurface(tester, () async {
        await openPasswordPanel(tester);

        when(
          () => authRepository.changePassword(
            oldPassword: 'current1',
            newPassword: 'longenough1',
          ),
        ).thenAnswer((_) async => const Right(null));

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'current1');
        await tester.enterText(fields.at(1), 'longenough1');
        await tester.enterText(fields.at(2), 'longenough1');
        await tester.tap(find.text('Change Password').last);
        await tester.pumpAndSettle();

        expect(find.text('Password changed successfully'), findsOneWidget);
        final textField = tester.widget<TextFormField>(fields.at(0));
        expect(textField.controller!.text, isEmpty);
      });
    });

    testWidgets('shows the wrong-current-password error and keeps typed '
        'values for correction', (tester) async {
      await withLargeSurface(tester, () async {
        await openPasswordPanel(tester);

        when(
          () => authRepository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer(
          (_) async => const Left(UnauthorizedFailure('Wrong password')),
        );

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'wrong-current');
        await tester.enterText(fields.at(1), 'longenough1');
        await tester.enterText(fields.at(2), 'longenough1');
        await tester.tap(find.text('Change Password').last);
        await tester.pumpAndSettle();

        expect(find.text('The current password is incorrect'), findsOneWidget);
        expect(find.text('Password changed successfully'), findsNothing);
        expect(
          tester.widget<TextFormField>(fields.at(1)).controller!.text,
          'longenough1',
        );
      });
    });

    testWidgets('shows the mismatch error without a network call', (
      tester,
    ) async {
      await withLargeSurface(tester, () async {
        await openPasswordPanel(tester);

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'current1');
        await tester.enterText(fields.at(1), 'longenough1');
        await tester.enterText(fields.at(2), 'different1');
        await tester.tap(find.text('Change Password').last);
        await tester.pumpAndSettle();

        expect(find.text('The new passwords do not match'), findsOneWidget);
        verifyNever(
          () => authRepository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          ),
        );
      });
    });
  });
}
