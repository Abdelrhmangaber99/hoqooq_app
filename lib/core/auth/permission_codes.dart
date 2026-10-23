/// Canonical permission codes as the **deployed** backend issues them.
///
/// The v3 permission catalog renamed several v2 codes, and this app was still
/// checking the old spellings. A granted Employee therefore passed the wrong
/// string to `User.hasPerm()` and the whole module was hidden:
///
/// | v2 code the app used          | v3 code the backend grants |
/// | ----------------------------- | -------------------------- |
/// | `employee.read`               | `employee.view`            |
/// | `employee.edit`               | `employee.manage`          |
/// | `employee.permission.manage`  | `employee.manage`          |
/// | `finance.firm.read`           | `finance.firm.view`        |
/// | `finance.case.view`           | `finance.view`             |
/// | `report.operational.read`     | `report.view`              |
/// | `audit.read`                  | `audit.view`               |
///
/// Verified two independent ways on 2026-10-16, both against the deployed
/// backend (`13.50.240.246:3006`): the API's own OpenAPI document
/// (`SetFirmAdminPermissionsDto.permissionKeys.example` = `["case.view",
/// "employee.view"]`), and the shipped desktop bundle
/// (`D:\New Folder\Hoqooq\Hoqooq.exe`), whose sidebar map and permission
/// labels name `employee.view`, `employee.manage`, `finance.firm.view`,
/// `finance.view`, `report.view` and `audit.view`.
///
/// Every other code (`case.*`, `hearing.*`, `task.*`, `document.*`,
/// `service.*`, `meeting.*`, `client.*`, `opponent.*`, `calendar.*`,
/// `finance.payment.record`, `finance.manage`, `dashboard.read`,
/// `notification.read`, `firm.profile.*`, `reference.read`) is unchanged
/// between the two — only the seven above moved.
///
/// The v2 spellings are kept as aliases in `permission_labels.dart` so a
/// catalog fetched from an older server still groups and labels correctly;
/// this class is what gating code should compare against.
abstract final class PermissionCodes {
  static const employeeRead = 'employee.view';
  static const employeeCreate = 'employee.create';
  static const employeeEdit = 'employee.manage';
  static const employeeManage = 'employee.manage';

  /// The deployed backend folded "edit employee data" and "manage employee
  /// permissions" into one code (`employee.manage`) — see the table above.
  /// Kept as a separate constant because the two call sites express
  /// different intents, even though they now resolve to the same grant.
  static const employeePermissionManage = 'employee.manage';
  static const employeeStatusManage = 'employee.status.manage';

  static const caseCreate = 'case.create';
  static const caseView = 'case.view';
  static const caseEdit = 'case.edit';
  static const caseStatusManage = 'case.status.manage';
  static const caseAccessManage = 'case.access.manage';

  static const hearingCreate = 'hearing.create';
  static const hearingView = 'hearing.view';
  static const hearingEdit = 'hearing.edit';
  static const hearingAssign = 'hearing.assign';
  static const hearingComplete = 'hearing.complete';
  static const serviceCreate = 'service.create';
  static const serviceView = 'service.view';
  static const serviceEdit = 'service.edit';
  static const serviceAssign = 'service.assign';
  static const serviceComplete = 'service.complete';
  static const meetingCreate = 'meeting.create';
  static const meetingView = 'meeting.view';
  static const meetingEdit = 'meeting.edit';
  static const meetingAssign = 'meeting.assign';
  static const meetingComplete = 'meeting.complete';
  static const taskCreate = 'task.create';
  static const taskView = 'task.view';
  static const taskUpdate = 'task.update';
  static const taskAssign = 'task.assign';
  static const taskComplete = 'task.complete';
  static const documentView = 'document.view';
  static const documentUpload = 'document.upload';
  static const documentDownload = 'document.download';
  static const documentEdit = 'document.edit';
  static const documentManage = 'document.manage';

  static const clientView = 'client.view';
  static const clientEdit = 'client.edit';
  static const opponentView = 'opponent.view';
  static const opponentEdit = 'opponent.edit';

  static const calendarRead = 'calendar.read';
  static const calendarManage = 'calendar.manage';

  static const financeFirmRead = 'finance.firm.view';
  static const financeCaseView = 'finance.view';
  static const financePaymentRecord = 'finance.payment.record';
  static const financeManage = 'finance.manage';

  static const reportOperationalRead = 'report.view';

  static const firmProfileRead = 'firm.profile.read';
  static const firmProfileManage = 'firm.profile.manage';

  static const auditRead = 'audit.view';
  static const notificationRead = 'notification.read';
  static const referenceRead = 'reference.read';
  static const dashboardRead = 'dashboard.read';
}
