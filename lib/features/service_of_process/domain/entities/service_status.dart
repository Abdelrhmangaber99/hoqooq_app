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
  'COMPLETED' => ServiceStatus.completed,
  'FAILED' => ServiceStatus.failed,
  'RESCHEDULED' => ServiceStatus.rescheduled,
  'CANCELLED' => ServiceStatus.cancelled,
  _ => ServiceStatus.unknown,
};

String serviceStatusToJson(ServiceStatus value) => switch (value) {
  ServiceStatus.scheduled => 'SCHEDULED',
  ServiceStatus.completed => 'COMPLETED',
  ServiceStatus.failed => 'FAILED',
  ServiceStatus.rescheduled => 'RESCHEDULED',
  ServiceStatus.cancelled => 'CANCELLED',
  ServiceStatus.unknown => 'UNKNOWN',
};
