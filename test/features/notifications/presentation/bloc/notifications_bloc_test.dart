import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/notifications/domain/entities/app_notification.dart';
import 'package:hqooq/features/notifications/domain/entities/notification_type.dart';
import 'package:hqooq/features/notifications/domain/repository/i_notification_repository.dart';
import 'package:hqooq/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock
    implements INotificationRepository {}

void main() {
  late MockNotificationRepository repository;

  AppNotification buildNotification(String id) {
    return AppNotification(
      id: id,
      userId: 'u1',
      title: 'Title $id',
      message: 'Message $id',
      isRead: false,
      type: NotificationType.hearingReminder,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  final notificationA = buildNotification('n1');
  final notificationB = buildNotification('n2');

  setUp(() {
    repository = MockNotificationRepository();
  });

  blocTest<NotificationsBloc, NotificationsState>(
    'emits [Loading, Loaded] on a successful GET /notifications/me',
    build: () {
      when(
        () => repository.getNotifications(),
      ).thenAnswer((_) async => Right([notificationA, notificationB]));
      return NotificationsBloc(repository);
    },
    act: (bloc) => bloc.add(FetchNotificationsRequested()),
    expect: () => [
      isA<NotificationsLoading>(),
      NotificationsLoaded([notificationA, notificationB]),
    ],
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'emits [Loading, Error] surfacing isForbidden when the fetch 403s',
    build: () {
      when(
        () => repository.getNotifications(),
      ).thenAnswer((_) async => const Left(ForbiddenFailure()));
      return NotificationsBloc(repository);
    },
    act: (bloc) => bloc.add(FetchNotificationsRequested()),
    expect: () => [
      isA<NotificationsLoading>(),
      isA<NotificationsError>().having(
        (s) => s.isForbidden,
        'isForbidden',
        true,
      ),
    ],
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'removes the marked notification from the local list on success -- '
    'GET /notifications/me would no longer return it either way',
    build: () {
      when(
        () => repository.getNotifications(),
      ).thenAnswer((_) async => Right([notificationA, notificationB]));
      when(
        () => repository.markAsRead('n1'),
      ).thenAnswer((_) async => Right(notificationA));
      return NotificationsBloc(repository);
    },
    act: (bloc) async {
      bloc.add(FetchNotificationsRequested());
      await Future.delayed(Duration.zero);
      bloc.add(const NotificationMarkedAsReadRequested('n1'));
    },
    expect: () => [
      isA<NotificationsLoading>(),
      NotificationsLoaded([notificationA, notificationB]),
      NotificationsLoaded([notificationB]),
    ],
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'keeps the list unchanged and surfaces actionError when mark-as-read '
    'fails',
    build: () {
      when(
        () => repository.getNotifications(),
      ).thenAnswer((_) async => Right([notificationA]));
      when(
        () => repository.markAsRead('n1'),
      ).thenAnswer((_) async => const Left(ServerFailure('network hiccup')));
      return NotificationsBloc(repository);
    },
    act: (bloc) async {
      bloc.add(FetchNotificationsRequested());
      await Future.delayed(Duration.zero);
      bloc.add(const NotificationMarkedAsReadRequested('n1'));
    },
    expect: () => [
      isA<NotificationsLoading>(),
      NotificationsLoaded([notificationA]),
      NotificationsLoaded([notificationA], actionError: 'network hiccup'),
    ],
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'mark-all clears every notification when every PATCH succeeds',
    build: () {
      when(
        () => repository.getNotifications(),
      ).thenAnswer((_) async => Right([notificationA, notificationB]));
      when(
        () => repository.markAsRead(any()),
      ).thenAnswer((_) async => Right(notificationA));
      return NotificationsBloc(repository);
    },
    act: (bloc) async {
      bloc.add(FetchNotificationsRequested());
      await Future.delayed(Duration.zero);
      bloc.add(AllNotificationsMarkedAsReadRequested());
    },
    expect: () => [
      isA<NotificationsLoading>(),
      NotificationsLoaded([notificationA, notificationB]),
      const NotificationsLoaded([]),
    ],
  );

  blocTest<NotificationsBloc, NotificationsState>(
    'mark-all leaves failed items in the list so the user can retry',
    build: () {
      when(
        () => repository.getNotifications(),
      ).thenAnswer((_) async => Right([notificationA, notificationB]));
      when(
        () => repository.markAsRead('n1'),
      ).thenAnswer((_) async => Right(notificationA));
      when(
        () => repository.markAsRead('n2'),
      ).thenAnswer((_) async => const Left(ServerFailure('failed')));
      return NotificationsBloc(repository);
    },
    act: (bloc) async {
      bloc.add(FetchNotificationsRequested());
      await Future.delayed(Duration.zero);
      bloc.add(AllNotificationsMarkedAsReadRequested());
    },
    expect: () => [
      isA<NotificationsLoading>(),
      NotificationsLoaded([notificationA, notificationB]),
      NotificationsLoaded([notificationB], actionError: 'failed'),
    ],
  );
}
