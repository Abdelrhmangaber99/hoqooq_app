enum DailyActivityType { hearing, service, meeting, task, unknown }

class DailyActivityItem {
  const DailyActivityItem({
    required this.id,
    required this.type,
    required this.caseId,
    required this.dueAt,
    required this.status,
  });

  final String id;
  final DailyActivityType type;
  final String caseId;
  final DateTime dueAt;
  final String status;

  factory DailyActivityItem.fromJson(Map<String, dynamic> json) =>
      DailyActivityItem(
        id: json['id'] as String,
        type: switch (json['type'] as String?) {
          'HEARING' => DailyActivityType.hearing,
          'SERVICE' => DailyActivityType.service,
          'MEETING' => DailyActivityType.meeting,
          'TASK' => DailyActivityType.task,
          _ => DailyActivityType.unknown,
        },
        caseId: json['caseId'] as String,
        dueAt: DateTime.parse(json['dueAt'] as String),
        status: json['status'] as String? ?? 'UNKNOWN',
      );
}
