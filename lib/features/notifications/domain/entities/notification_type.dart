import 'package:json_annotation/json_annotation.dart';

/// `type` on `Notification` per API_CONTRACT.md finding S.
///
/// Confirmed exhaustive from the actual backend source
/// (`src/modules/notifications/enums/notification-type.enum.ts`).
enum NotificationType {
  @JsonValue('HEARING_REMINDER')
  hearingReminder,
  @JsonValue('TASK_ASSIGNED')
  taskAssigned,
  @JsonValue('INVOICE_DUE')
  invoiceDue,
  @JsonValue('SYSTEM_ALERT')
  systemAlert,
  @JsonValue('unknown')
  unknown,
}
