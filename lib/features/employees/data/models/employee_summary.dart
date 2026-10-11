class EmployeeSummary {
  const EmployeeSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.positionLabel,
    this.status = 'ACTIVE',
    this.userId,
  });

  final String id;
  final String name;
  final String email;
  final String positionLabel;
  final String status;
  final String? userId;

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory EmployeeSummary.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};
    return EmployeeSummary(
      id: json['id']?.toString() ?? '',
      name: user['fullName']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      positionLabel: humanize(json['position']?.toString() ?? ''),
      status: (json['status'] ?? user['status'])?.toString() ?? 'ACTIVE',
      userId: (json['userId'] ?? user['id'])?.toString(),
    );
  }

  static String humanize(String value) => value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
      .join(' ');
}
