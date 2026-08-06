part of 'notifications_bloc.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

/// Zero-results is represented by an empty `notifications` list here — the
/// screen decides whether to show the `EmptyState` widget, same precedent
/// as `CasesLoaded`. `actionError` surfaces a failed mark-as-read (single
/// or bulk) without discarding the still-valid `notifications` list —
/// same "transient error alongside good data" pattern as `*FormReady.
/// submitError`.
class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> notifications;
  final String? actionError;

  const NotificationsLoaded(this.notifications, {this.actionError});

  @override
  List<Object?> get props => [notifications, actionError];
}

class NotificationsError extends NotificationsState {
  final String message;
  final bool isForbidden;
  const NotificationsError(this.message, {this.isForbidden = false});

  @override
  List<Object?> get props => [message, isForbidden];
}
