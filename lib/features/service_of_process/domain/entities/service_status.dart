enum ServiceStatus {
  scheduled,
  completed,
  failed,
  rescheduled,
  cancelled,
  unknown,
}

ServiceStatus serviceStatusFromJson(Object? value) => switch (value) {
  'SCHEDULED' => ServiceStatus.scheduled,
  'IN_PROGRESS' => ServiceStatus.scheduled,
  'SERVED' => ServiceStatus.completed,
  'COMPLETED' => ServiceStatus.completed,
  'FAILED' => ServiceStatus.failed,
  'POSTPONED' => ServiceStatus.rescheduled,
  'RESCHEDULED' => ServiceStatus.rescheduled,
  'CANCELLED' => ServiceStatus.cancelled,
  _ => ServiceStatus.unknown,
};

String serviceStatusToJson(ServiceStatus value) => switch (value) {
  ServiceStatus.scheduled => 'SCHEDULED',
  ServiceStatus.completed => 'SERVED',
  ServiceStatus.failed => 'FAILED',
  ServiceStatus.rescheduled => 'POSTPONED',
  ServiceStatus.cancelled => 'CANCELLED',
  ServiceStatus.unknown => 'UNKNOWN',
};
