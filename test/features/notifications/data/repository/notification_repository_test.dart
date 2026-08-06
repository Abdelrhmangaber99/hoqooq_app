import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hqooq/core/errors/failures.dart';
import 'package:hqooq/features/notifications/data/repository/notification_repository.dart';
import 'package:hqooq/features/notifications/domain/entities/notification_type.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late NotificationRepository repository;

  setUp(() {
    dio = MockDio();
    repository = NotificationRepository(dio);
  });

  Response<T> okResponse<T>(String path, T data) {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: 200,
    );
  }

  // Real shape confirmed from Hoqooq-main source (API_CONTRACT.md finding
  // S): NotificationsController DOES call plainToInstance -- this shape is
  // reliably enforced, unlike Cases/Hearings/Tasks/Calendar/Finance.
  Map<String, dynamic> notificationJson({String type = 'HEARING_REMINDER'}) {
    return {
      'id': 'n1',
      'userId': 'u1',
      'title': 'Upcoming hearing',
      'message': 'Hernandez v. State at 9:00 AM',
      'isRead': false,
      'type': type,
      'createdAt': '2026-01-01T00:00:00.000Z',
    };
  }

  group('getNotifications', () {
    test('GETs /notifications/me and parses the full shape', () async {
      when(() => dio.get('/notifications/me')).thenAnswer(
        (_) async => okResponse('/notifications/me', [notificationJson()]),
      );

      final result = await repository.getNotifications();

      verify(() => dio.get('/notifications/me')).called(1);
      result.fold((_) => fail('expected Right'), (notifications) {
        expect(notifications, hasLength(1));
        expect(notifications.first.title, 'Upcoming hearing');
        expect(notifications.first.type, NotificationType.hearingReminder);
        expect(notifications.first.isRead, isFalse);
      });
    });

    test('falls back to unknown for an unrecognized type', () async {
      when(() => dio.get('/notifications/me')).thenAnswer(
        (_) async => okResponse('/notifications/me', [
          notificationJson(type: 'SOMETHING_NEW'),
        ]),
      );

      final result = await repository.getNotifications();

      result.fold((_) => fail('expected Right'), (notifications) {
        expect(notifications.first.type, NotificationType.unknown);
      });
    });

    test('maps a connection error to NetworkFailure', () async {
      when(() => dio.get('/notifications/me')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/notifications/me'),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await repository.getNotifications();

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('markAsRead', () {
    test('PATCHes /notifications/{id}/read with no body', () async {
      when(() => dio.patch('/notifications/n1/read')).thenAnswer(
        (_) async => okResponse('/notifications/n1/read', {
          ...notificationJson(),
          'isRead': true,
        }),
      );

      final result = await repository.markAsRead('n1');

      verify(() => dio.patch('/notifications/n1/read')).called(1);
      result.fold((_) => fail('expected Right'), (notification) {
        expect(notification.isRead, isTrue);
      });
    });

    test(
      'maps a 404 (not the caller\'s own notification) to ServerFailure',
      () async {
        when(() => dio.patch('/notifications/n2/read')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/notifications/n2/read'),
            response: Response(
              requestOptions: RequestOptions(path: '/notifications/n2/read'),
              statusCode: 404,
              data: {
                'message': 'Notification with ID n2 not found for user u1',
              },
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await repository.markAsRead('n2');

        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('expected Left'),
        );
      },
    );
  });
}
