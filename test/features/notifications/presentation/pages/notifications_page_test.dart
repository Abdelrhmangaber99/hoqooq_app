import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/localization/app_localizations.dart';
import 'package:hqooq/di/injection.dart';
import 'package:hqooq/features/notifications/domain/entities/app_notification.dart';
import 'package:hqooq/features/notifications/domain/entities/notification_type.dart';
import 'package:hqooq/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:hqooq/features/notifications/presentation/pages/notifications_page.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsBloc
    extends MockBloc<NotificationsEvent, NotificationsState>
    implements NotificationsBloc {}

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
  late MockNotificationsBloc bloc;

  final notification = AppNotification(
    id: 'n1',
    userId: 'u1',
    title: 'Upcoming hearing',
    message: 'Hernandez v. State at 9:00 AM',
    isRead: false,
    type: NotificationType.hearingReminder,
    createdAt: DateTime(2026, 1, 1, 9),
  );

  setUpAll(() async {
    preloadedEn = AppLocalizations(const Locale('en'));
    await preloadedEn.load();
  });

  setUp(() async {
    await getIt.reset();
    bloc = MockNotificationsBloc();
    getIt.registerFactory<NotificationsBloc>(() => bloc);
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
      home: const NotificationsPage(),
    );
  }

  testWidgets('shows a loading spinner while NotificationsLoading', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<NotificationsState>.empty(),
      initialState: NotificationsLoading(),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error view on NotificationsError', (tester) async {
    whenListen(
      bloc,
      const Stream<NotificationsState>.empty(),
      initialState: const NotificationsError('Server error'),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Server error'), findsOneWidget);
  });

  testWidgets('shows the empty state and hides mark-all when there are no '
      'notifications', (tester) async {
    whenListen(
      bloc,
      const Stream<NotificationsState>.empty(),
      initialState: const NotificationsLoaded([]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Mark all read'), findsNothing);
  });

  testWidgets('renders the notification list and mark-all action', (
    tester,
  ) async {
    whenListen(
      bloc,
      const Stream<NotificationsState>.empty(),
      initialState: NotificationsLoaded([notification]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    expect(find.text('Upcoming hearing'), findsOneWidget);
    expect(find.text('Hernandez v. State at 9:00 AM'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);
  });

  testWidgets('tapping a notification dispatches mark-as-read', (tester) async {
    whenListen(
      bloc,
      const Stream<NotificationsState>.empty(),
      initialState: NotificationsLoaded([notification]),
    );

    await tester.pumpWidget(buildTestable());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upcoming hearing'));
    await tester.pump();

    verify(
      () => bloc.add(const NotificationMarkedAsReadRequested('n1')),
    ).called(1);
  });
}
