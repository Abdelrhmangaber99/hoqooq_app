import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/features/authentication/domain/entities/tenant_ref.dart';
import 'package:hqooq/features/authentication/domain/entities/user.dart';
import 'package:hqooq/features/authentication/presentation/bloc/session_cubit.dart';
import 'package:hqooq/features/subscriptions/presentation/bloc/subscription_cubit.dart';
import 'package:hqooq/features/subscriptions/presentation/bloc/subscription_state.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late SessionCubit sessionCubit;
  late SubscriptionCubit cubit;

  User firmUser({String tenantId = 'firm-1'}) => User(
    id: 'u1',
    email: 'admin@firm.com',
    fullName: 'Jane Doe',
    status: 'ACTIVE',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    accountType: 'FIRM_ADMIN',
    tenant: TenantRef(id: tenantId, name: 'Firm'),
  );

  const activePlan = {
    'id': 'plan-basic',
    'name': 'Basic',
    'priceMonthly': 200,
    'priceYearly': 2000,
  };
  const premiumPlan = {
    'id': 'plan-premium',
    'name': 'Premium',
    'priceMonthly': 500,
    'priceYearly': 5000,
  };

  Map<String, dynamic> firmPayload({
    String status = 'ACTIVE',
    String planId = 'plan-basic',
    String? name = 'Old Firm Name',
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
        'status': status,
        'billingCycle': 'MONTHLY',
        'supersededAt': null,
        'isArchived': false,
        'currentPeriodEnd': '2026-12-01T00:00:00.000Z',
        'plan': planId == 'plan-premium' ? premiumPlan : activePlan,
      },
    ],
  };

  Response<T> ok<T>(String path, T data) => Response<T>(
    requestOptions: RequestOptions(path: path),
    data: data,
    statusCode: 200,
  );

  void stubPlans() {
    when(
      () => dio.get('/subscriptions/plans'),
    ).thenAnswer((_) async => ok('/subscriptions/plans', [premiumPlan]));
  }

  setUp(() {
    dio = MockDio();
    sessionCubit = SessionCubit();
    cubit = SubscriptionCubit(dio, sessionCubit);
  });

  tearDown(() => cubit.close());

  // The firm record backs the sidebar's workspace name and logo, so it has to
  // exist as soon as a session does — not only after some screen that happens
  // to fetch it is opened.
  group('session-driven firm loading', () {
    test('signing in loads the firm record', () async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      stubPlans();

      sessionCubit.authenticated(firmUser(), 'token', isFirmAdmin: true);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<SubscriptionLoaded>());
      expect((cubit.state as SubscriptionLoaded).firm['id'], 'firm-1');
    });

    test('signing out clears the previous session\'s firm', () async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      stubPlans();

      sessionCubit.authenticated(firmUser(), 'token', isFirmAdmin: true);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, isA<SubscriptionLoaded>());

      sessionCubit.unauthenticated();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, isA<SubscriptionInitial>());
    });

    test('a token refresh re-emitting the session does not refetch', () async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      stubPlans();

      sessionCubit.authenticated(firmUser(), 'token', isFirmAdmin: true);
      await Future<void>.delayed(Duration.zero);
      clearInteractions(dio);

      // Same tenant: the loaded record already matches.
      sessionCubit.authenticated(firmUser(), 'new-token', isFirmAdmin: true);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => dio.get('/tenants/my-firm'));
    });

    test('a platform administrator never requests a firm record', () async {
      final superAdmin = User(
        id: 'sa',
        email: 'sa@platform.com',
        fullName: 'System Admin',
        status: 'ACTIVE',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        accountType: 'SUPER_ADMIN',
      );

      sessionCubit.authenticated(superAdmin, 'token', isFirmAdmin: false);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => dio.get('/tenants/my-firm'));
      expect(cubit.state, isA<SubscriptionInitial>());
    });
  });

  group('fetchSubscription', () {
    test(
      'emits Loaded with the non-superseded subscription row and status',
      () async {
        when(
          () => dio.get('/tenants/my-firm'),
        ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
        stubPlans();

        await cubit.fetchSubscription();

        final state = cubit.state;
        expect(state, isA<SubscriptionLoaded>());
        final loaded = state as SubscriptionLoaded;
        expect(loaded.firm['name'], 'Old Firm Name');
        expect(loaded.activeSubscription!['status'], 'ACTIVE');
        expect(loaded.availablePlans, hasLength(1));
      },
    );

    test('emits SubscriptionError on failure', () async {
      when(() => dio.get('/tenants/my-firm')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/tenants/my-firm'),
          response: Response(
            requestOptions: RequestOptions(path: '/tenants/my-firm'),
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      stubPlans();

      await cubit.fetchSubscription();

      expect(cubit.state, isA<SubscriptionError>());
    });
  });

  group('changePlan — immediate state synchronization', () {
    test('after a successful PATCH the loaded state shows the NEW plan '
        'immediately, without a manual reload', () async {
      // Initial fetch: Basic plan, ACTIVE.
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      stubPlans();
      await cubit.fetchSubscription();

      // The PATCH succeeds; the refetch now returns the Premium plan row.
      when(
        () => dio.patch(
          '/subscriptions/firm-1',
          data: any(
            named: 'data',
            that: isA<Map<String, dynamic>>()
                .having((m) => m['planId'], 'planId', 'plan-premium')
                .having((m) => m['billingCycle'], 'billingCycle', 'MONTHLY'),
          ),
        ),
      ).thenAnswer((_) async => ok('/subscriptions/firm-1', null));
      when(() => dio.get('/tenants/my-firm')).thenAnswer(
        (_) async =>
            ok('/tenants/my-firm', firmPayload(planId: 'plan-premium')),
      );

      final result = await cubit.changePlan(
        planId: 'plan-premium',
        billingCycle: 'MONTHLY',
      );

      expect(result, isTrue);
      final loaded = cubit.state as SubscriptionLoaded;
      expect(
        loaded.activeSubscription!['plan']['id'],
        'plan-premium',
        reason: 'the subscription displayed must be the new plan immediately',
      );
      expect(loaded.activeSubscription!['status'], 'ACTIVE');
      expect(loaded.isMutating, isFalse);
      verify(() => dio.get('/tenants/my-firm')).called(2);
    });

    test('emits isMutating during the request and keeps prior data on '
        'failure with an inline error (no data loss)', () async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      stubPlans();
      await cubit.fetchSubscription();

      when(
        () => dio.patch('/subscriptions/firm-1', data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/subscriptions/firm-1'),
          response: Response(
            requestOptions: RequestOptions(path: '/subscriptions/firm-1'),
            statusCode: 403,
            data: {'message': 'Insufficient permissions'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await cubit.changePlan(
        planId: 'plan-premium',
        billingCycle: 'MONTHLY',
      );

      expect(result, isFalse);
      final loaded = cubit.state as SubscriptionLoaded;
      // Still shows the OLD plan — never falsely updated.
      expect(loaded.activeSubscription!['plan']['id'], 'plan-basic');
      expect(loaded.isMutating, isFalse);
      expect(loaded.error, isNotNull);
    });
  });

  group('deactivateSubscription — immediate state synchronization', () {
    test('after a successful POST the state shows the server-returned '
        'CANCELLED status immediately', () async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      stubPlans();
      await cubit.fetchSubscription();

      when(
        () => dio.post('/subscriptions/firm-1/deactivate'),
      ).thenAnswer((_) async => ok('/subscriptions/firm-1/deactivate', null));
      // The authoritative status now comes back CANCELLED.
      when(() => dio.get('/tenants/my-firm')).thenAnswer(
        (_) async => ok('/tenants/my-firm', firmPayload(status: 'CANCELLED')),
      );

      final result = await cubit.deactivateSubscription();

      expect(result, isTrue);
      final loaded = cubit.state as SubscriptionLoaded;
      expect(
        loaded.activeSubscription!['status'],
        'CANCELLED',
        reason: 'the stale ACTIVE state must be replaced immediately',
      );
      expect(loaded.isMutating, isFalse);
    });

    test('keeps the previous status visible on failure', () async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      stubPlans();
      await cubit.fetchSubscription();

      when(() => dio.post('/subscriptions/firm-1/deactivate')).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: '/subscriptions/firm-1/deactivate',
          ),
          response: Response(
            requestOptions: RequestOptions(
              path: '/subscriptions/firm-1/deactivate',
            ),
            statusCode: 403,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await cubit.deactivateSubscription();

      expect(result, isFalse);
      final loaded = cubit.state as SubscriptionLoaded;
      expect(loaded.activeSubscription!['status'], 'ACTIVE');
      expect(loaded.error, isNotNull);
    });
  });

  group('saveFirmInfo — immediate state synchronization', () {
    test('after a successful PATCH the new name/address/email appear in '
        'state immediately (settings + sidebar)', () async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      stubPlans();
      await cubit.fetchSubscription();

      when(
        () => dio.patch('/tenants/my-firm', data: any(named: 'data')),
      ).thenAnswer((_) async => ok('/tenants/my-firm', null));
      when(() => dio.get('/tenants/my-firm')).thenAnswer(
        (_) async => ok('/tenants/my-firm', firmPayload(name: 'New Firm Name')),
      );

      final result = await cubit.saveFirmInfo(
        name: 'New Firm Name',
        address: 'New address',
        contactEmail: 'new@firm.com',
      );

      expect(result, isTrue);
      final loaded = cubit.state as SubscriptionLoaded;
      expect(loaded.firm['name'], 'New Firm Name');
      expect(loaded.isMutating, isFalse);
      expect(loaded.error, isNull);
    });

    test('on failure keeps old values and surfaces the error', () async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      stubPlans();
      await cubit.fetchSubscription();

      when(
        () => dio.patch('/tenants/my-firm', data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/tenants/my-firm'),
          response: Response(
            requestOptions: RequestOptions(path: '/tenants/my-firm'),
            statusCode: 400,
            data: {'message': 'name is too long'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await cubit.saveFirmInfo(
        name: 'New Firm Name',
        address: 'a',
        contactEmail: 'b',
      );

      expect(result, isFalse);
      final loaded = cubit.state as SubscriptionLoaded;
      expect(loaded.firm['name'], 'Old Firm Name');
      expect(loaded.error, 'name is too long');
    });
  });

  group('uploadFirmLogo — cache-safe immediate refresh', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hoqooq_logo_test');
    });

    tearDown(() async {
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    });

    test('after a successful upload the new logoUrl is in state and the '
        'old URL is gone', () async {
      when(() => dio.get('/tenants/my-firm')).thenAnswer(
        (_) async =>
            ok('/tenants/my-firm', firmPayload(logoUrl: '/files/logo-old.png')),
      );
      stubPlans();
      await cubit.fetchSubscription();

      final logoFile = File('${tempDir.path}/logo.png');
      await logoFile.writeAsBytes(List.filled(64, 1));

      when(
        () => dio.post('/tenants/my-firm/logo', data: any(named: 'data')),
      ).thenAnswer((_) async => ok('/tenants/my-firm/logo', null));
      when(() => dio.get('/tenants/my-firm')).thenAnswer(
        (_) async =>
            ok('/tenants/my-firm', firmPayload(logoUrl: '/files/logo-new.png')),
      );

      final result = await cubit.uploadFirmLogo(logoFile.path);

      expect(result, isTrue);
      final loaded = cubit.state as SubscriptionLoaded;
      expect(loaded.firm['logoUrl'], '/files/logo-new.png');
      expect(loaded.firm['logoUrl'], isNot('/files/logo-old.png'));
    });

    test('rejects files over 5MB without a network call', () async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      stubPlans();
      await cubit.fetchSubscription();

      final logoFile = File('${tempDir.path}/too-big.png');
      await logoFile.writeAsBytes(List.filled(5 * 1024 * 1024 + 1, 0));

      final result = await cubit.uploadFirmLogo(logoFile.path);

      expect(result, isFalse);
      verifyNever(() => dio.post(any(), data: any(named: 'data')));
    });
  });

  group('refreshQuietly — screen-entry synchronization', () {
    test('replaces loaded data with the fresh payload without emitting a '
        'full-screen Loading state', () async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      stubPlans();
      await cubit.fetchSubscription();

      // A plan change performed outside this screen (platform admin
      // console, another session) now shows up on refetch.
      when(() => dio.get('/tenants/my-firm')).thenAnswer(
        (_) async =>
            ok('/tenants/my-firm', firmPayload(planId: 'plan-premium')),
      );

      final states = <SubscriptionState>[];
      final subscription = cubit.stream.listen(states.add);
      await cubit.refreshQuietly();
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(
        states.whereType<SubscriptionLoading>(),
        isEmpty,
        reason: 'already-rendered data must not be blanked on entry',
      );
      final loaded = cubit.state as SubscriptionLoaded;
      expect(loaded.activeSubscription!['plan']['id'], 'plan-premium');
    });

    test('falls back to a full fetch when nothing is loaded yet', () async {
      when(
        () => dio.get('/tenants/my-firm'),
      ).thenAnswer((_) async => ok('/tenants/my-firm', firmPayload()));
      stubPlans();

      await cubit.refreshQuietly();

      expect(cubit.state, isA<SubscriptionLoaded>());
      verify(() => dio.get('/tenants/my-firm')).called(1);
    });
  });

  group('extractActiveSubscription', () {
    test('picks the non-superseded, non-archived row', () {
      final firm = {
        'subscriptions': [
          {
            'id': 'old',
            'supersededAt': '2026-08-01T00:00:00.000Z',
            'status': 'CANCELLED',
          },
          {
            'id': 'current',
            'supersededAt': null,
            'isArchived': false,
            'status': 'ACTIVE',
          },
        ],
      };

      expect(
        SubscriptionCubit.extractActiveSubscription(firm)!['id'],
        'current',
      );
    });

    test('returns null for a firm with no subscription history', () {
      expect(
        SubscriptionCubit.extractActiveSubscription({'subscriptions': []}),
        isNull,
      );
    });
  });
}
