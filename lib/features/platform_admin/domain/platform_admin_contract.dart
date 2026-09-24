class PlatformAdminContract {
  const PlatformAdminContract._();

  static List<String> permissionCodes(Object? data) {
    if (data is! Map) return const [];
    final rawCodes = data['codes'];
    if (rawCodes is! List) return const [];
    return rawCodes.whereType<String>().toList()..sort();
  }

  static Map<String, dynamic>? currentSubscription(Map<String, dynamic> firm) {
    final subscriptions = firm['subscriptions'];
    if (subscriptions is! List) return null;
    for (final value in subscriptions.reversed) {
      if (value is Map<String, dynamic> &&
          value['supersededAt'] == null &&
          value['isArchived'] != true) {
        return value;
      }
    }
    return null;
  }

  static Map<String, dynamic> overviewFirm(Object? data) {
    if (data is! Map) return const {};
    final firm = data['firm'];
    return firm is Map<String, dynamic> ? firm : const {};
  }

  static List<Map<String, dynamic>> overviewEmployees(Object? data) {
    if (data is! Map || data['employees'] is! List) return const [];
    return (data['employees'] as List)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static Map<String, dynamic>? overviewSubscription(Object? data) {
    if (data is! Map) return null;
    final subscription = data['currentSubscription'];
    return subscription is Map<String, dynamic> ? subscription : null;
  }
}
