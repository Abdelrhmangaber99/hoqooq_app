import '../../../../core/network/api_result.dart';
import '../entities/app_notification.dart';

/// Mirrors API_CONTRACT.md finding S (Notifications). `getNotifications`
/// returns **unread only** — the backend filters `isRead: false`
/// server-side, there's no way to fetch already-read notifications. No
/// creation method — notifications are server-internal only, nothing for
/// this app to `POST`.
abstract class INotificationRepository {
  ApiResult<List<AppNotification>> getNotifications();
  ApiResult<AppNotification> markAsRead(String id);
}
