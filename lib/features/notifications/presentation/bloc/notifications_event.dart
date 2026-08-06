part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationsRequested extends NotificationsEvent {}

class NotificationMarkedAsReadRequested extends NotificationsEvent {
  final String id;
  const NotificationMarkedAsReadRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class AllNotificationsMarkedAsReadRequested extends NotificationsEvent {}
