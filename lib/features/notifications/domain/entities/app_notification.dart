import 'package:freezed_annotation/freezed_annotation.dart';
import 'notification_type.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// Wire shape for `GET /notifications/me` / `PATCH /notifications/{id}/read`
/// per API_CONTRACT.md finding S.
///
/// Named `AppNotification`, not `Notification`, to avoid clashing with
/// Flutter's own `Notification` class (`package:flutter/widgets.dart`) —
/// same naming-collision precedent as `DocumentItem` (not `Document`,
/// avoiding a `dart:io` clash).
///
/// `NotificationsController` **does** call `plainToInstance(...,
/// {excludeExtraneousValues: true})` on both routes — this shape is
/// reliably enforced, unlike Cases/Hearings/Tasks/Calendar/Finance.
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String userId,
    required String title,
    required String message,
    required bool isRead,
    @JsonKey(unknownEnumValue: NotificationType.unknown)
    required NotificationType type,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
