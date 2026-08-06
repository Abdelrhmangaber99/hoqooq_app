import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repository/i_notification_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// Powers the rebuilt `NotificationsPage`. `GET /notifications/me` returns
/// **unread only** (API_CONTRACT.md finding S) — marking one read removes
/// it from this bloc's local list rather than refetching, since the
/// backend's own response would no longer include it either way; this is
/// exact, not an approximation.
///
/// "Mark all read" (`AllNotificationsMarkedAsReadRequested`) has no bulk
/// backend endpoint — it's N concurrent `PATCH .../read` calls over the
/// currently-loaded list, per the approved M6 plan. A per-item failure
/// leaves that one item in the list (so the user can retry) rather than
/// silently dropping it.
@injectable
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final INotificationRepository _notificationRepository;

  NotificationsBloc(this._notificationRepository)
    : super(NotificationsInitial()) {
    on<FetchNotificationsRequested>(_onFetch);
    on<NotificationMarkedAsReadRequested>(_onMarkAsRead);
    on<AllNotificationsMarkedAsReadRequested>(_onMarkAllAsRead);
  }

  Future<void> _onFetch(
    FetchNotificationsRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    final result = await _notificationRepository.getNotifications();
    result.fold(
      (failure) => emit(
        NotificationsError(
          failure.message,
          isForbidden: failure is ForbiddenFailure,
        ),
      ),
      (notifications) => emit(NotificationsLoaded(notifications)),
    );
  }

  Future<void> _onMarkAsRead(
    NotificationMarkedAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    final result = await _notificationRepository.markAsRead(event.id);
    result.fold(
      (failure) => emit(
        NotificationsLoaded(
          current.notifications,
          actionError: failure.message,
        ),
      ),
      (_) => emit(
        NotificationsLoaded(
          current.notifications.where((n) => n.id != event.id).toList(),
        ),
      ),
    );
  }

  Future<void> _onMarkAllAsRead(
    AllNotificationsMarkedAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded) return;
    if (current.notifications.isEmpty) return;

    final outcomes = await Future.wait(
      current.notifications.map((n) async {
        final result = await _notificationRepository.markAsRead(n.id);
        return result.fold(
          (failure) => (notification: n, errorMessage: failure.message),
          (_) => (notification: n, errorMessage: null),
        );
      }),
    );

    final stillUnread = outcomes
        .where((o) => o.errorMessage != null)
        .map((o) => o.notification)
        .toList();

    emit(
      NotificationsLoaded(
        stillUnread,
        actionError: stillUnread.isEmpty
            ? null
            : outcomes.firstWhere((o) => o.errorMessage != null).errorMessage,
      ),
    );
  }
}
