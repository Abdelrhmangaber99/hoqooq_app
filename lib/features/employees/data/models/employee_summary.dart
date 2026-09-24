class EmployeeSummary {
  const EmployeeSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.positionLabel,
  });

  final String id;
  final String name;
  final String email;
  final String positionLabel;

  factory EmployeeSummary.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};
    return EmployeeSummary(
      id: json['id']?.toString() ?? '',
      name: user['fullName']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      positionLabel: humanize(json['position']?.toString() ?? ''),
    );
  }

  static String humanize(String value) => value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
      .join(' ');
}
