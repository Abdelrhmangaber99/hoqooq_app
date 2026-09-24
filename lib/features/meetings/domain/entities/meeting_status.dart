enum MeetingStatus { scheduled, completed, cancelled, rescheduled, unknown }

MeetingStatus meetingStatusFromJson(Object? value) => switch (value) {
  'SCHEDULED' => MeetingStatus.scheduled,
  'COMPLETED' => MeetingStatus.completed,
  'CANCELLED' => MeetingStatus.cancelled,
  'RESCHEDULED' => MeetingStatus.rescheduled,
  _ => MeetingStatus.unknown,
};
