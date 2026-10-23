import '../../../authentication/domain/entities/user.dart';

enum CaseCapabilityGroup {
  caseData,
  parties,
  documents,
  hearings,
  services,
  meetings,
  tasks,
  access,

  /// Case-level finance capabilities (PRD v2.0 §7.8 BR-028). Selectable
  /// independently of every other group — e.g. an employee can receive
  /// `finance.view` + `finance.payment.record` without `document.view`.
  /// Firm-wide finance (`finance.firm.view`) is deliberately absent here:
  /// it is a firm-level base permission, not a Case grant.
  finance,
}

class CaseCapabilityDefinition {
  const CaseCapabilityDefinition({
    required this.code,
    required this.basePermission,
    required this.group,
  });

  final String code;
  final String basePermission;
  final CaseCapabilityGroup group;
}

/// Mirrors the backend `CaseCapability` enum and its base-permission mapping.
/// A grant may only be offered when the delegating user holds its base
/// permission; the backend performs the same check authoritatively.
abstract final class CaseCapabilities {
  static const definitions = <CaseCapabilityDefinition>[
    CaseCapabilityDefinition(
      code: 'case.view',
      basePermission: 'case.view',
      group: CaseCapabilityGroup.caseData,
    ),
    CaseCapabilityDefinition(
      code: 'case.edit',
      basePermission: 'case.edit',
      group: CaseCapabilityGroup.caseData,
    ),
    CaseCapabilityDefinition(
      code: 'case.status.manage',
      basePermission: 'case.status.manage',
      group: CaseCapabilityGroup.caseData,
    ),
    CaseCapabilityDefinition(
      code: 'client.view',
      basePermission: 'client.view',
      group: CaseCapabilityGroup.parties,
    ),
    CaseCapabilityDefinition(
      code: 'client.edit',
      basePermission: 'client.edit',
      group: CaseCapabilityGroup.parties,
    ),
    CaseCapabilityDefinition(
      code: 'opponent.view',
      basePermission: 'opponent.view',
      group: CaseCapabilityGroup.parties,
    ),
    CaseCapabilityDefinition(
      code: 'opponent.edit',
      basePermission: 'opponent.edit',
      group: CaseCapabilityGroup.parties,
    ),
    CaseCapabilityDefinition(
      code: 'document.view',
      basePermission: 'document.view',
      group: CaseCapabilityGroup.documents,
    ),
    CaseCapabilityDefinition(
      code: 'document.download',
      basePermission: 'document.download',
      group: CaseCapabilityGroup.documents,
    ),
    CaseCapabilityDefinition(
      code: 'document.upload',
      basePermission: 'document.upload',
      group: CaseCapabilityGroup.documents,
    ),
    CaseCapabilityDefinition(
      code: 'document.edit',
      basePermission: 'document.edit',
      group: CaseCapabilityGroup.documents,
    ),
    CaseCapabilityDefinition(
      code: 'document.manage',
      basePermission: 'document.manage',
      group: CaseCapabilityGroup.documents,
    ),
    CaseCapabilityDefinition(
      code: 'hearing.view',
      basePermission: 'hearing.view',
      group: CaseCapabilityGroup.hearings,
    ),
    CaseCapabilityDefinition(
      code: 'hearing.create',
      basePermission: 'hearing.create',
      group: CaseCapabilityGroup.hearings,
    ),
    CaseCapabilityDefinition(
      code: 'hearing.edit',
      basePermission: 'hearing.edit',
      group: CaseCapabilityGroup.hearings,
    ),
    CaseCapabilityDefinition(
      code: 'hearing.assign',
      basePermission: 'hearing.assign',
      group: CaseCapabilityGroup.hearings,
    ),
    CaseCapabilityDefinition(
      code: 'hearing.complete',
      basePermission: 'hearing.complete',
      group: CaseCapabilityGroup.hearings,
    ),
    CaseCapabilityDefinition(
      code: 'service.view',
      basePermission: 'service.view',
      group: CaseCapabilityGroup.services,
    ),
    CaseCapabilityDefinition(
      code: 'service.create',
      basePermission: 'service.create',
      group: CaseCapabilityGroup.services,
    ),
    CaseCapabilityDefinition(
      code: 'service.edit',
      basePermission: 'service.edit',
      group: CaseCapabilityGroup.services,
    ),
    CaseCapabilityDefinition(
      code: 'service.assign',
      basePermission: 'service.assign',
      group: CaseCapabilityGroup.services,
    ),
    CaseCapabilityDefinition(
      code: 'service.complete',
      basePermission: 'service.complete',
      group: CaseCapabilityGroup.services,
    ),
    CaseCapabilityDefinition(
      code: 'meeting.view',
      basePermission: 'meeting.view',
      group: CaseCapabilityGroup.meetings,
    ),
    CaseCapabilityDefinition(
      code: 'meeting.create',
      basePermission: 'meeting.create',
      group: CaseCapabilityGroup.meetings,
    ),
    CaseCapabilityDefinition(
      code: 'meeting.edit',
      basePermission: 'meeting.edit',
      group: CaseCapabilityGroup.meetings,
    ),
    CaseCapabilityDefinition(
      code: 'meeting.assign',
      basePermission: 'meeting.assign',
      group: CaseCapabilityGroup.meetings,
    ),
    CaseCapabilityDefinition(
      code: 'meeting.complete',
      basePermission: 'meeting.complete',
      group: CaseCapabilityGroup.meetings,
    ),
    CaseCapabilityDefinition(
      code: 'task.view',
      basePermission: 'task.view',
      group: CaseCapabilityGroup.tasks,
    ),
    CaseCapabilityDefinition(
      code: 'task.create',
      basePermission: 'task.create',
      group: CaseCapabilityGroup.tasks,
    ),
    CaseCapabilityDefinition(
      code: 'task.assign',
      basePermission: 'task.assign',
      group: CaseCapabilityGroup.tasks,
    ),
    CaseCapabilityDefinition(
      code: 'task.update',
      basePermission: 'task.update',
      group: CaseCapabilityGroup.tasks,
    ),
    CaseCapabilityDefinition(
      code: 'task.complete',
      basePermission: 'task.complete',
      group: CaseCapabilityGroup.tasks,
    ),
    CaseCapabilityDefinition(
      code: 'case.access.manage',
      basePermission: 'case.access.manage',
      group: CaseCapabilityGroup.access,
    ),
    CaseCapabilityDefinition(
      code: 'finance.view',
      basePermission: 'finance.view',
      group: CaseCapabilityGroup.finance,
    ),
    CaseCapabilityDefinition(
      code: 'finance.payment.record',
      basePermission: 'finance.payment.record',
      group: CaseCapabilityGroup.finance,
    ),
    CaseCapabilityDefinition(
      code: 'finance.manage',
      basePermission: 'finance.manage',
      group: CaseCapabilityGroup.finance,
    ),
  ];

  static List<CaseCapabilityDefinition> delegableBy(User user) => definitions
      .where((definition) => user.hasPerm(definition.basePermission))
      .toList(growable: false);
}
