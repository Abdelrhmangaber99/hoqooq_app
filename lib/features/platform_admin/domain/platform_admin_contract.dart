class PlatformAdminContract {
  const PlatformAdminContract._();

  static List<String> permissionCodes(Object? data) {
    if (data is! Map) return const [];
    final rawCodes = data['codes'];
    if (rawCodes is! List) return const [];
    return rawCodes.whereType<String>().toList()..sort();
  }

  static Map<String, dynamic>? currentSubscription(Map<String, dynamic> firm) {
    // The deployed platform registry (`GET /tenants`, `GET /tenants/:id`)
    // returns the current subscription as a single object rather than the raw
    // tenant's versioned `subscriptions[]` relation.
    final current = firm['currentSubscription'];
    if (current is Map<String, dynamic>) return current;
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

  /// The firm record from `GET /tenants/:id`.
  ///
  /// The deployed backend answers with a platform overview
  /// `{firm, firmAdmin, currentSubscription}` (and `GET /tenants` returns a
  /// list of the same). Older revisions returned the bare tenant. Both are
  /// accepted here.
  static Map<String, dynamic> overviewFirm(Object? data) {
    if (data is! Map) return const {};
    if (data['firm'] is Map || data['id'] != null) return normalizeTenant(data);
    return const {};
  }

  /// Normalizes the tenant shapes used by deployed API revisions.
  ///
  /// Unwraps the platform registry's `{firm, firmAdmin, currentSubscription}`
  /// wrapper (verified live against the deployed API on 2026-10-11) and carries
  /// `firmAdmin`/`currentSubscription` onto the returned firm, because that
  /// registry is the **only** place a Super Admin can read the Firm Admin — the
  /// deployed backend has no `GET /users` at all, and answers `GET /employees`
  /// for a Super Admin with `403 "Platform accounts cannot access firm legal
  /// resources"`.
  static Map<String, dynamic> normalizeTenant(Object? value) {
    if (value is! Map) return <String, dynamic>{};
    var source = value['tenant'] is Map
        ? Map<String, dynamic>.from(value['tenant'] as Map)
        : Map<String, dynamic>.from(value);
    if (source['firm'] is Map) {
      final admin = source['firmAdmin'];
      final subscription = source['currentSubscription'];
      source = Map<String, dynamic>.from(source['firm'] as Map);
      if (admin is Map) {
        source['firmAdmin'] = Map<String, dynamic>.from(admin);
      }
      if (subscription is Map) {
        source['currentSubscription'] = Map<String, dynamic>.from(subscription);
      }
    }
    final name =
        source['name'] ??
        source['firmName'] ??
        source['tenantName'] ??
        source['displayName'];
    if (name != null && source['name'] == null) source['name'] = name;
    final status = source['status'] ?? source['tenantStatus'];
    if (status != null && source['status'] == null) source['status'] = status;
    return source;
  }

  static List<Map<String, dynamic>> overviewEmployees(Object? data) {
    if (data is! Map) return const [];
    final raw = data['employees'] ?? data['users'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((user) => Map<String, dynamic>.from(user))
        .toList();
  }

  /// Some older deployed revisions return the owner separately from the
  /// employee array. Keep that response compatible with the platform pages.
  static Map<String, dynamic>? overviewAdmin(Object? data) {
    if (data is! Map) return null;
    for (final key in const ['firmAdmin', 'admin', 'ownerUser', 'owner']) {
      final value = data[key];
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static Map<String, dynamic>? overviewSubscription(Object? data) {
    if (data is! Map) return null;
    final subscription = data['currentSubscription'];
    return subscription is Map<String, dynamic> ? subscription : null;
  }

  static List<Map<String, dynamic>> collection(Object? data) {
    final values = data is List
        ? data
        : data is Map && data['items'] is List
        ? data['items'] as List
        : data is Map && data['firms'] is List
        ? data['firms'] as List
        : data is Map && data['data'] is List
        ? data['data'] as List
        : data is Map && data['users'] is List
        ? data['users'] as List
        : data is Map && data['tenants'] is List
        ? data['tenants'] as List
        : const <dynamic>[];
    return values
        .whereType<Map>()
        .map(normalizeTenant)
        .where((tenant) => tenant.isNotEmpty)
        .toList();
  }

  static String? userTenantId(Map<String, dynamic> user) {
    final tenant = user['tenant'];
    return (user['tenantId'] ?? (tenant is Map ? tenant['id'] : null))
        ?.toString();
  }

  static List<Map<String, dynamic>> usersForFirm(Object? data, String firmId) {
    final values = data is List
        ? data
        : data is Map && data['items'] is List
        ? data['items'] as List
        : data is Map && data['users'] is List
        ? data['users'] as List
        : const <dynamic>[];
    return values
        .whereType<Map>()
        .map((user) => Map<String, dynamic>.from(user))
        .where((user) => userTenantId(user) == firmId)
        .toList();
  }
}
