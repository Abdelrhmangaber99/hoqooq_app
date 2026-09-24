# Backend Actions Required for Mobile v2

## Purpose

This document records backend work required to make the current mobile v2
flows function correctly. No backend code or database data is changed by this
document.

## 1. Permission catalog and Firm Admin grants

### Problem

The backend controllers currently require v2-style permission codes, while
existing Firm Admin accounts hold legacy codes. For example:

| Mobile/backend requirement | Existing legacy grant |
|---|---|
| `case.view` | `cases.read` |
| `case.create` | `cases.create` |
| `case.edit` | `cases.update` |
| `calendar.manage` | `calendar.create` / `calendar.update` / `calendar.delete` |
| `employee.create` | `employees.create` |

`case.view` and `case.create` are required by `CasesController`, but they are
missing from the current permission table. As a result, existing Firm Admins
cannot list or create Cases even when their older grants imply that authority.

### Required backend work

1. Run the idempotent permission seed so every code in
   `src/core/constants/permissions.constant.ts` exists in `permissions`.
2. Write and run an audited migration that adds equivalent v2 grants to
   existing Firm Admin accounts. Do not delete old grants in the migration;
   retain them as historical data or revoke them only after verification.
3. Revoke active sessions / increment authorization versions for affected
   users, so new JWTs carry the corrected permissions.
4. Add automated coverage for a Firm Admin with `case.view`, `case.create`,
   and `calendar.read`.

### Minimum mappings

| Legacy code | Required v2 code |
|---|---|
| `cases.read` | `case.view` |
| `cases.create` | `case.create` |
| `cases.update` | `case.edit` |
| `cases.assign` | `case.access.manage` |
| `calendar.create`, `calendar.update`, `calendar.delete` | `calendar.manage` |
| `employees.create` | `employee.create` |
| `employees.read` | `employee.read` |
| `employees.update` | `employee.edit` |
| `hearings.read` | `hearing.view` |
| `documents.read` | `document.view` |
| `documents.create` | `document.upload` |
| `tasks.read` | `task.read` |
| `tasks.create` | `task.create` |
| `tasks.update` | `task.update` |
| `settings.update` | `firm.profile.manage` |
| `notifications.read` | `notification.read` |

## 2. Employee creation route

### Problem

Swagger documents `POST /api/users`, but the running server returns:

```
404 Cannot POST /api/users
```

The mobile employee form therefore cannot create an employee after it loads.

### Required backend work

Provide one verified, registered endpoint for employee provisioning:

- Firm Admin / delegated tenant actor: derives the target tenant from the JWT
  and requires `employee.create`.
- Super Admin: requires an explicit target Firm, validates that it exists, and
  may never create a Super Admin through the employee flow.
- Reject a client-supplied `isSuperAdmin` flag.
- Validate role/classification/specialization and write audit metadata.
- Update Swagger from the running application and add integration tests.

## 3. User management routes

### Problem

The running `UsersController` exposes metadata reads but not the documented
create/update routes. The mobile Super Admin employee edit screen cannot
complete an update until a secure API contract exists.

### Required backend work

- Add a Super-Admin-only firm-account update endpoint.
- Add permission read/replace endpoints for Super Admin that cannot grant
  platform/system permissions or modify a Super Admin account.
- Preserve audit history and invalidate affected user sessions after a
  permission change.
- Ensure non-Super-Admin user reads remain tenant-scoped.

## 4. Mobile behavior until these actions are completed

- The app hides Case create and Calendar create controls when the current
  JWT lacks the required v2 permission.
- Cases/Calendar show a clear no-permission state rather than repeatedly
  calling endpoints that return 403.
- Employee setup no longer loops indefinitely when a Firm Admin is denied
  access to the platform-wide tenant list.

