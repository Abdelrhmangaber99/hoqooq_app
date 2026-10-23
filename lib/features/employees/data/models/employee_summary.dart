class EmployeeSummary {
  const EmployeeSummary({
    required this.id,
    required this.name,
    required this.email,
    required this.positionLabel,
    this.status = 'ACTIVE',
    this.userId,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String positionLabel;
  final String status;
  final String? userId;
  final String? avatarUrl;

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory EmployeeSummary.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};
    // `EmployeeResponseDto.user` is documented as `{id, email, fullName}`, so
    // an avatar is genuinely optional here — read the single real key
    // (`avatarUrl`, on the nested user or the row itself) and let AppAvatar
    // fall back to initials when the backend does not include one.
    final avatar =
        user['avatarUrl'] ?? json['avatarUrl'] ?? user['avatar_url'] ?? json['avatar_url'];
    return EmployeeSummary(
      id: json['id']?.toString() ?? '',
      name: user['fullName']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      positionLabel: humanize(json['position']?.toString() ?? ''),
      status: (json['status'] ?? user['status'])?.toString() ?? 'ACTIVE',
      userId: (json['userId'] ?? user['id'])?.toString(),
      avatarUrl: avatar == null || avatar.toString().trim().isEmpty ? null : avatar.toString().trim(),
    );
  }

  static String humanize(String value) => value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
      .join(' ');
}
