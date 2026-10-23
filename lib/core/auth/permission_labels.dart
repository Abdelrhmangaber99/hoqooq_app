import 'package:flutter/widgets.dart';

import '../localization/app_localizations.dart';

/// The code set the **deployed** v3 backend issues (see
/// `permission_codes.dart` for the seven that were renamed from v2). Used by
/// the localization tests to prove every grantable capability has a real
/// bilingual label, and by nothing at runtime — the server's
/// `GET /permissions` catalog is always authoritative for display.
const knownPermissionCodes = <String>[
  'employee.create',
  'employee.view',
  'employee.manage',
  'employee.status.manage',
  'client.view',
  'client.edit',
  'opponent.view',
  'opponent.edit',
  'platform.reference.manage',
  'reference.read',
  'case.create',
  'case.view',
  'case.edit',
  'case.status.manage',
  'case.access.manage',
  'hearing.create',
  'hearing.view',
  'hearing.edit',
  'hearing.assign',
  'hearing.complete',
  'service.create',
  'service.view',
  'service.edit',
  'service.assign',
  'service.complete',
  'meeting.create',
  'meeting.view',
  'meeting.edit',
  'meeting.assign',
  'meeting.complete',
  'document.upload',
  'document.view',
  'document.download',
  'document.edit',
  'document.manage',
  'task.create',
  'task.view',
  'task.update',
  'task.complete',
  'task.assign',
  'calendar.manage',
  'calendar.read',
  'finance.payment.record',
  'finance.firm.view',
  'finance.manage',
  'finance.view',
  'notification.read',
  'report.view',
  'dashboard.read',
  'firm.profile.manage',
  'firm.profile.read',
  'audit.view',
  'platform.firm.create',
  'platform.firm.read',
  'platform.firm.status.manage',
  'platform.subscription.manage',
  'platform.firm_admin.permission.manage',
  'platform.user.metadata.read',
  'platform.user.status.manage',
  'platform.plan.manage',
  'platform.audit.read',
];

String permissionTranslationKey(String permissionCode) =>
    'permission_${permissionCode.trim().toLowerCase().replaceAll('.', '_')}';

/// The codes the **desktop app's** employee permission editor deliberately
/// withholds, mirrored here so both clients offer the Firm Admin exactly the
/// same checkbox set.
///
/// Taken from the shipped bundle's own list:
/// `['meeting.','calendar.','notification.','reference.','firm.profile.',
/// 'platform.','system.']` as prefixes, plus the four exact codes below.
/// Everything else (case / client / opponent / hearing / service / document /
/// task / finance) is grantable per employee.
///
/// The reason these are not per-employee grants: the dashboard and calendar
/// are available to every employee unconditionally, the notification and
/// reference codes are ambient reads, `firm.profile.*` and `settings` are
/// Firm-Admin-only surfaces, and `platform.*`/`system.*` are rejected outright
/// by the backend when granted to a firm account.
const _nonGrantablePrefixes = <String>[
  'meeting.',
  'calendar.',
  'notification.',
  'reference.',
  'firm.profile.',
  'platform.',
  'system.',
];

const _nonGrantableCodes = <String>{
  'dashboard.read',
  'report.view',
  'audit.view',
  'employee.status.manage',
};

/// Whether the employee permission editor should offer [permissionCode] as a
/// per-employee grant. Membership is decided on the **canonical** code so a
/// catalog still carrying a pre-rename spelling is filtered identically.
bool isEmployeeGrantablePermission(String permissionCode) {
  final canonical = canonicalPermissionCode(permissionCode);
  if (_nonGrantableCodes.contains(canonical)) return false;
  return !_nonGrantablePrefixes.any(canonical.startsWith);
}

/// Folds every code the backend has ever issued onto the code the deployed
/// v3 catalog grants today. Two generations are covered: the pre-`v2`
/// plural/CRUD spellings (`cases.read`, `settings.update`) and the v2
/// spellings that the v3 release renamed outright (`employee.read` ->
/// `employee.view`, `finance.firm.read` -> `finance.firm.view`, …).
///
/// Every value here must also appear in [knownPermissionCodes] and carry a
/// `permission_<code>` label in both languages — `arabic_localization_test`
/// enforces exactly that, which is what keeps a renamed code from silently
/// degrading into a raw dotted string in the UI.
const legacyPermissionAliases = <String, String>{
  // v2.0 -> v3.0 renames.
  'employee.read': 'employee.view',
  'employee.edit': 'employee.manage',
  'employee.permission.manage': 'employee.manage',
  'finance.firm.read': 'finance.firm.view',
  'finance.case.view': 'finance.view',
  'report.operational.read': 'report.view',
  'audit.read': 'audit.view',
  // Pre-v2 CRUD spellings.
  'employee.update': 'employee.manage',
  'employee.delete': 'employee.status.manage',
  'employees.create': 'employee.create',
  'employees.read': 'employee.view',
  'employees.update': 'employee.manage',
  'employees.delete': 'employee.status.manage',
  'employees.permissions': 'employee.manage',
  'users.create': 'employee.create',
  'users.read': 'employee.view',
  'users.update': 'employee.manage',
  'users.delete': 'employee.status.manage',
  'cases.create': 'case.create',
  'cases.read': 'case.view',
  'cases.update': 'case.edit',
  'cases.delete': 'case.status.manage',
  'cases.assign': 'case.access.manage',
  'case.read': 'case.view',
  'case.update': 'case.edit',
  'case.delete': 'case.status.manage',
  'case.assign': 'case.access.manage',
  'clients.create': 'client.edit',
  'clients.read': 'client.view',
  'clients.update': 'client.edit',
  'clients.delete': 'client.edit',
  'client.create': 'client.edit',
  'client.read': 'client.view',
  'client.update': 'client.edit',
  'client.delete': 'client.edit',
  'opponents.create': 'opponent.edit',
  'opponents.read': 'opponent.view',
  'opponents.update': 'opponent.edit',
  'opponents.delete': 'opponent.edit',
  'opponent.create': 'opponent.edit',
  'opponent.read': 'opponent.view',
  'opponent.update': 'opponent.edit',
  'opponent.delete': 'opponent.edit',
  'courts.create': 'platform.reference.manage',
  'courts.read': 'reference.read',
  'courts.update': 'platform.reference.manage',
  'courts.delete': 'platform.reference.manage',
  'hearings.create': 'hearing.create',
  'hearings.read': 'hearing.view',
  'hearings.update': 'hearing.edit',
  'hearings.delete': 'hearing.complete',
  'hearings.assign': 'hearing.assign',
  'hearing.read': 'hearing.view',
  'hearing.update': 'hearing.edit',
  'hearing.delete': 'hearing.complete',
  'documents.create': 'document.upload',
  'documents.read': 'document.view',
  'documents.download': 'document.download',
  'documents.update': 'document.edit',
  'documents.delete': 'document.manage',
  'document.create': 'document.upload',
  'document.read': 'document.view',
  'document.update': 'document.edit',
  'document.delete': 'document.manage',
  'tasks.create': 'task.create',
  'tasks.read': 'task.view',
  'tasks.update': 'task.update',
  'tasks.delete': 'task.complete',
  'tasks.assign': 'task.assign',
  'task.read': 'task.view',
  'task.delete': 'task.complete',
  'finance.create': 'finance.payment.record',
  'finance.read': 'finance.firm.view',
  'finance.update': 'finance.manage',
  'finance.delete': 'finance.manage',
  'notifications.read': 'notification.read',
  'reports.read': 'report.view',
  'settings.create': 'firm.profile.manage',
  'settings.read': 'firm.profile.read',
  'settings.update': 'firm.profile.manage',
  'settings.delete': 'firm.profile.manage',
  'lookups.read': 'reference.read',
  'system.tenants.create': 'platform.firm.create',
  'system.tenants.read': 'platform.firm.read',
  'system.tenants.delete': 'platform.firm.status.manage',
  'system.subscriptions.manage': 'platform.subscription.manage',
  'system.firm_admin.permissions': 'platform.firm_admin.permission.manage',
  'system.users.read': 'platform.user.metadata.read',
  'system.users.manage': 'platform.user.status.manage',
  'system.plans.manage': 'platform.plan.manage',
  'system.audit.read': 'platform.audit.read',
};

String canonicalPermissionCode(String permissionCode) {
  final normalized = permissionCode.trim().toLowerCase();
  return legacyPermissionAliases[normalized] ?? normalized;
}

/// Collapses a server-supplied permission catalog to one entry per capability
/// for display, while keeping codes the caller actually holds.
///
/// The backend's `permissions` table still carries both the legacy and the
/// current code for many capabilities (`employees.read` *and* `employee.read`,
/// `finance.create` *and* `finance.payment.record`, …), so a raw catalog
/// renders the same permission as several identical-looking rows.
/// [legacyPermissionAliases] folds them onto one canonical capability.
///
/// The returned code is **always one that appeared in the input** — the server
/// validates a granted permission against the exact code it stores, so
/// substituting a manufactured canonical code for a legacy one would be
/// rejected when the caller only holds the legacy form. The current code wins
/// when the catalog contains it; otherwise the legacy one is kept.
List<String> normalizePermissionCodes(Iterable<String> codes) {
  final present = <String>[];
  final presentSet = <String>{};
  for (final raw in codes) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || !presentSet.add(trimmed)) continue;
    present.add(trimmed);
  }

  final chosen = <String, String>{};
  final order = <String>[];
  for (final code in present) {
    final canonical = canonicalPermissionCode(code);
    if (!chosen.containsKey(canonical)) {
      order.add(canonical);
      chosen[canonical] = code;
    } else if (chosen[canonical] != canonical && code == canonical) {
      // Prefer the current code over a legacy alias when both are present.
      chosen[canonical] = code;
    }
  }
  return [for (final canonical in order) chosen[canonical]!];
}

String permissionLabel(BuildContext context, String permissionCode) {
  final canonical = canonicalPermissionCode(permissionCode);
  final key = permissionTranslationKey(canonical);
  final translated = context.tr(key);
  if (translated != key) return translated;

  return _fallbackPermissionLabel(context, canonical);
}

String _fallbackPermissionLabel(BuildContext context, String permissionCode) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final parts = permissionCode
      .split(RegExp(r'[._]+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) return context.tr('unknown_permission');
  if (!isArabic) {
    return parts
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' — ');
  }

  const arabicParts = <String, String>{
    'employee': 'الموظفون',
    'employees': 'الموظفون',
    'user': 'المستخدمون',
    'users': 'المستخدمون',
    'role': 'الأدوار',
    'roles': 'الأدوار',
    'case': 'القضايا',
    'cases': 'القضايا',
    'client': 'الموكلون',
    'clients': 'الموكلون',
    'opponent': 'الخصوم',
    'opponents': 'الخصوم',
    'hearing': 'الجلسات',
    'hearings': 'الجلسات',
    'service': 'الإعلانات القضائية',
    'meeting': 'الاجتماعات',
    'document': 'المستندات',
    'documents': 'المستندات',
    'task': 'المهام',
    'tasks': 'المهام',
    'calendar': 'التقويم',
    'finance': 'المالية',
    'notification': 'الإشعارات',
    'notifications': 'الإشعارات',
    'report': 'التقارير',
    'reports': 'التقارير',
    'dashboard': 'لوحة المعلومات',
    'firm': 'المكتب',
    'reference': 'البيانات المرجعية',
    'audit': 'سجل التدقيق',
    'platform': 'المنصة',
    'system': 'النظام',
    'create': 'إنشاء',
    'read': 'عرض',
    'view': 'عرض',
    'edit': 'تعديل',
    'update': 'تحديث',
    'delete': 'حذف',
    'manage': 'إدارة',
    'assign': 'إسناد',
    'complete': 'إكمال',
    'upload': 'رفع',
    'download': 'تنزيل',
    'status': 'الحالة',
    'access': 'الوصول',
    'permission': 'الصلاحيات',
    'permissions': 'الصلاحيات',
    'profile': 'الملف',
    'payment': 'الدفعات',
    'record': 'تسجيل',
    'subscription': 'الاشتراكات',
    'plan': 'الخطط',
    'metadata': 'البيانات',
    'operational': 'التشغيلية',
  };

  final localized = parts
      .map((part) => arabicParts[part] ?? '')
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  return localized.isEmpty
      ? context.tr('unknown_permission')
      : localized.join(' — ');
}
