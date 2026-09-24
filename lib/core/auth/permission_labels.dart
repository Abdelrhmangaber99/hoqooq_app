import 'package:flutter/widgets.dart';

import '../localization/app_localizations.dart';

const knownPermissionCodes = <String>[
  'employee.create',
  'employee.read',
  'employee.edit',
  'employee.permission.manage',
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
  'finance.firm.read',
  'finance.manage',
  'finance.case.view',
  'notification.read',
  'report.operational.read',
  'dashboard.read',
  'firm.profile.manage',
  'firm.profile.read',
  'audit.read',
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

const legacyPermissionAliases = <String, String>{
  'employee.update': 'employee.edit',
  'employee.delete': 'employee.status.manage',
  'employees.create': 'employee.create',
  'employees.read': 'employee.read',
  'employees.update': 'employee.edit',
  'employees.delete': 'employee.status.manage',
  'employees.permissions': 'employee.permission.manage',
  'users.create': 'employee.create',
  'users.read': 'employee.read',
  'users.update': 'employee.edit',
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
  'finance.read': 'finance.firm.read',
  'finance.update': 'finance.manage',
  'finance.delete': 'finance.manage',
  'notifications.read': 'notification.read',
  'reports.read': 'report.operational.read',
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
