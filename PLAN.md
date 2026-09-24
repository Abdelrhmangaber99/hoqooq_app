# HOQOOQ Mobile v2 Migration Plan

> **Status:** Authoritative replacement plan for the existing `PLAN.md`.
>
> **Purpose:** Migrate the existing Hoqooq Flutter mobile application to the authoritative HOQOOQ PRD v2.0 without silently preserving v1 business rules or working around backend violations.
>
> **Important:** This is a migration of an existing application, **not a rewrite from scratch**.

---

## 1. Mandatory source documents and precedence

Before changing any code, the implementation agent MUST locate and read these files in full:

1. `HOQOOQ_PRD_v2.0_UPDATED.md`
2. `API_CONTRACT.md`
3. `hoqooq_mobile_spec.md`
4. `PROJECT_SUMMARY.md`
5. `CLAUDE.md`
6. the existing `PLAN.md` only to understand historical work before replacing it
7. the current backend source under `Hoqooq-main/` or the actual backend folder available in the repository
8. any current Postman/OpenAPI/Swagger artifact if present

### Conflict precedence

Use the following precedence:

1. **`HOQOOQ_PRD_v2.0_UPDATED.md`** — authoritative for business rules, roles/account types, permissions, workflows, scope, and v2 behavior.
2. **Current backend source** — authoritative for what the backend actually exposes today. If it conflicts with the PRD, that is a **backend violation**, not a reason to downgrade the mobile app to v1 behavior.
3. **`API_CONTRACT.md`** — authoritative integration reference only after it is re-verified against the current backend source.
4. **`hoqooq_mobile_spec.md`** — mobile UX, screens, and implementation guidance where it does not conflict with the PRD or real API.
5. **`PROJECT_SUMMARY.md` / `CLAUDE.md`** — historical/current implementation context.
6. Older BRD/PRD, Postman examples, old plans, mocks, or existing UI behavior — non-authoritative when they conflict with v2.

Do not invent missing API behavior. Do not implement a mobile-side workaround for a server-side authorization or tenant-isolation defect and call it complete.

---

## 2. Existing mobile architecture — preserve unless a v2 requirement forces change

The existing Flutter application is not a blank slate.

Preserve the established architecture unless there is a concrete reason to change it:

- `flutter_bloc` + Equatable for state management
- `get_it` + `injectable` for dependency injection
- Hive / `hive_flutter` for local storage where currently used
- Freezed for DTOs/entities where already established
- `go_router` for routing
- `dio` for networking
- central Dio configuration/interceptors
- secure token storage
- existing localization approach, while continuing migration toward ARB where already established
- existing feature-oriented folder structure

Do **not** migrate to Riverpod/drift merely because an older mobile specification proposed them.

Do not rewrite stable screens/services unnecessarily. Refactor existing modules into v2 behavior with the smallest safe changes.

---

## 3. v2 product rules that drive the migration

The mobile application must be rebuilt around these v2 rules:

- Exactly three system account types:
  - `SUPER_ADMIN`
  - `FIRM_ADMIN`
  - `EMPLOYEE`
- `LAWYER`, `SECRETARY`, `ACCOUNTANT`, `ASSISTANT`, and `OTHER` are professional/job classifications, not authorization roles.
- Firm Admin permissions are assigned by Super Admin; Firm Admin is **not** automatically hard-coded full CRUD.
- Firm Admin creates/manages Employees.
- Employee base permissions are explicitly granted.
- Lawyer profiles have one or more Case Type specializations.
- Lawyer selection for Cases/Hearings must be filtered by Case Type specialization and validated by the backend.
- Clients and Opponents are **case-local snapshots**, not reusable firm-wide master records.
- Governorates, Courts, and Circuits are global seeded reference data:
  - Governorate -> Courts
  - Court -> Circuits
- Employees receive granular Case-specific capabilities.
- Activity-specific assignment can expose only the minimum Case context required for that activity.
- Case activities include:
  - Hearings
  - Service of Process
  - Client Meetings
  - Tasks
- Documents are Case-owned.
- Calendar visibility mirrors effective permissions/assignments.
- Notification payloads must never leak hidden Case data.
- Finance is simplified to:
  - agreed Case fee
  - Case payments
  - paid amount
  - remaining amount
  - firm collected revenue
  - outstanding receivables
- `ACCOUNTANT` classification grants no finance access by itself.
- Old Invoice/Expense product flows are out of v2 scope.
- Subscription state must not automatically trigger the old read-only/suspension behavior.
- AI/RAG is out of v2 scope and must not be exposed by the mobile application.

---

# 4. Phase 0 — Mandatory audit before implementation

No feature migration begins until this phase is complete.

> **Phase status (2026-08-11):** [x] Source/document/mobile audit completed.
> The backend source was verified at `D:\hoqooq\Hoqooq`, including its
> `swagger.json`. Runtime testing remains optional and was not performed.
> `BACKEND_VIOLATIONS_V2.md` is the current source-backed v2 compliance record.

## 4.1 Read and inventory

Read the mandatory files listed in Section 1.

Then inventory:

- current mobile routes
- feature folders
- blocs/cubits
- repositories
- DTOs/entities
- Dio endpoints
- permission helpers
- role/account-type logic
- case/team assignment logic
- standalone Client/Opponent flows
- Courts/lookups flows
- Finance flows
- Subscription/402 handling
- Notifications
- Profile/Settings
- AI routes/features
- existing tests

## 4.2 Backend vs PRD v2 compliance audit

Read the real backend source and compare it rule-by-rule against the v2 PRD.

Create or replace:

`BACKEND_VIOLATIONS_V2.md`

For every mismatch record:

| Field | Required content |
|---|---|
| ID | `BV2-001`, `BV2-002`, ... |
| Severity | Critical / High / Medium / Low |
| PRD rule | Exact BR-### |
| Backend location | Controller/service/entity/guard/file |
| Endpoint/model | Affected route/entity |
| Actual behavior | What backend currently does |
| Required v2 behavior | What PRD requires |
| Mobile impact | Blocker / Partial blocker / No blocker |
| Security impact | Tenant leak / privilege issue / data integrity / none |
| Recommendation | Specific backend change |
| Status | Open / Verified fixed / No longer applicable |

### Rules for the audit

- Do not assume `API_CONTRACT.md` is still current.
- Re-read the current backend source.
- Re-test critical endpoints if a runnable backend/environment is available.
- If backend behavior changed, update `API_CONTRACT.md`.
- If the backend violates v2, **report it clearly**.
- Do not hide a server defect by filtering only in Flutter.
- Do not change backend code unless explicitly instructed to do so.
- Mobile work may continue on non-blocked areas, but blocked features must be marked clearly.

## 4.3 API contract synchronization

Update `API_CONTRACT.md` only after re-verifying the backend.

It must describe:

- actual current endpoint paths
- auth/session behavior
- request payloads
- response shapes
- account type/profile fields
- permission representation
- tenant behavior
- Case fields
- Case access-grant endpoints
- specialization endpoints
- Governorate/Court/Circuit endpoints
- Hearing endpoints
- Service of Process endpoints
- Client Meeting endpoints
- Task endpoints
- Document endpoints
- Calendar endpoints
- Notification endpoints
- Case payment/finance endpoints
- error and authorization responses

For every required v2 capability that has no backend endpoint, mark it explicitly as **MISSING / BACKEND BLOCKER**. Do not invent endpoint strings.

## 4.4 Replace old plan

After the audit:

- overwrite the repository's old `PLAN.md` with this v2 migration plan
- do not append this plan below the historical milestone plan
- rely on git history for the old plan
- update milestone statuses in this new plan as work progresses

---

# 5. Phase 1 — Identity, Session, Account Type, Professional Profile

> **Phase status (2026-08-14):** [x] Mobile identity parsing and authorization
> helpers accept the backend's account-type + flat-permission model without
> requiring the removed legacy roles array. Employee specialization data is
> consumed through the Employee surface, not the session User DTO.

## Goal

Make the mobile domain model understand the v2 identity model before changing feature visibility.

## Tasks

- Update `User` / session entities to distinguish:
  - `accountType`
  - `jobClassification`
  - `specializations`
  - `permissions`
  - `accountStatus`
  - `tenant`
- Remove authorization logic that treats `LAWYER`, `SECRETARY`, `ACCOUNTANT`, etc. as security roles.
- Retain role parsing only if the current backend still exposes legacy role data for compatibility; do not make it authoritative for v2 UI behavior.
- Add helpers such as:
  - `isFirmAdmin`
  - `isEmployee`
  - `isLawyer`
  - `hasPermission(code)`
  - `hasAnyPermission(codes)`
  - `hasSpecialization(caseTypeId)`
- Ensure route guards depend on account type + permission, not professional classification.
- Ensure account `INACTIVE` behavior is handled consistently.
- Keep access token / refresh token handling secure.
- Update fixtures/tests.

## Definition of done

- No mobile authorization decision relies on job title alone.
- User parsing matches the verified API contract.
- Session state exposes v2 permission/specialization information.
- Unit tests cover account-type and permission helpers.

---

# 6. Phase 2 — Navigation, Dashboard, and Permission-Safe UI Shell

## Goal

Use one coherent firm-user mobile application while making navigation/actions permission-aware.

## Tasks

- Preserve common UI patterns between Firm Admin and Employee.
- Build navigation from actual effective account permissions.
- Firm Admin dashboard:
  - authorized firm-level Case/work metrics
  - today's authorized Hearings
  - Service of Process
  - Client Meetings
  - due Tasks
  - financial widgets only with finance permissions
- Employee dashboard:
  - only assigned/authorized Cases
  - assigned activities
  - due Tasks
  - permitted finance widgets
- Never show a screen merely because `jobClassification == ACCOUNTANT` or `LAWYER`.
- UI gating is UX only; continue handling 403/404 server responses safely.

## Definition of done

- Employee cannot navigate to unrelated firm data through routes/deep links.
- Firm Admin navigation respects the permission set assigned by Super Admin.
- Dashboard has no mock/fake sections.

---

# 7. Phase 3 — Employee Management

> **Phase status (2026-08-14):** [~] Backend onboarding, tenant-scoped list,
> specialization, and permission endpoints now exist. Mobile completion is
> pending BV2-016/017 because the response/update DTOs omit authoritative
> classification/status/profile lifecycle fields.

## Goal

Allow Firm Admin to create and manage Employees according to v2.

## Required mobile capability

If supported by the API:

- Employee list/search/filter
- Create Employee
- Edit Employee
- activate/deactivate Employee
- set professional classification
- when Lawyer:
  - select one or more Case Type specializations
- grant/revoke Employee base permissions

## Rules

- Employee creation is a Firm Admin/authorized firm action.
- Super Admin creation of Employees is not part of the firm mobile app.
- Job classification never grants automatic Case or Finance access.
- New Employee sees no Cases until Case access or activity assignment exists.
- Permission changes must refresh Session/authorization-dependent screens where relevant.

## Blocker behavior

If backend exposes only legacy role assignment and no base-permission/specialization model, mark this phase blocked in `BACKEND_VIOLATIONS_V2.md`; do not simulate authoritative permissions only in Flutter.

---

# 8. Phase 4 — Case Model Migration

> **Phase status (2026-08-15):** [~] Case creation now sends the full v2
> Case-owned Client snapshot plus zero-or-more Case-owned Opponents and never
> sends `clientId` or `tenantId`. Permission-gated lifecycle status controls
> call the dedicated status endpoint. Case detail now presents authoritative
> Client/Opponent snapshots only when the backend returns the corresponding
> capability-gated relation. Editing existing party snapshots remains
> creation-only because `UpdateCaseDto` explicitly excludes them; primary-
> lawyer selection remains blocked by the employee response gap (BV2-016).

## Goal

Refactor Cases around the v2 case-centric data model.

## 8.1 Case core

Support:

- internal reference
- court case number/year where applicable
- title/subject
- Case Type
- status
- opening date
- description/notes
- Governorate
- Court
- Circuit
- operational owner
- agreed fee when finance permission allows

## 8.2 Case-local Client

Remove dependency on a reusable Client master record for the v2 flow.

Client data belongs inside the Case.

The Case form/detail must contain the Client snapshot fields provided by the verified API.

Do not navigate users to a standalone Client registry as the authoritative v2 workflow.

Existing Client code may be reused as components/forms where helpful, but not as a shared master-record model.

## 8.3 Case-local Opponent

Move Opponent data into the Case.

Support zero or more opponents if the backend supports it.

Do not make standalone Opponent records the v2 source of truth.

## 8.4 Case Type

Case Type is mandatory for active legal work.

When Case Type changes:

- refresh lawyer eligibility
- warn about incompatible existing lawyer assignments
- never silently preserve an invalid new assignment

## Definition of done

- Case create/edit/detail reflects v2 fields.
- Client/Opponent data is case-local.
- No new Case depends on reusable client/opponent IDs unless the backend is still noncompliant and the feature is explicitly marked blocked.

---

# 9. Phase 5 — Global Governorate / Court / Circuit Reference Data

> **Phase status (2026-08-15):** [~] Case Type and Governorate endpoints are
> integrated. Case forms now query Google Places after Governorate selection
> and save only the selected `courtName`; Google Place IDs, addresses, and
> coordinates remain display-only. Backend Court/Circuit UUIDs are retained for
> Hearings, whose production completion remains blocked by BV2-019.

## Goal

Replace tenant court-management behavior with seeded global dependent selectors.

## Required flow

1. Load Governorates.
2. Case forms query Google Places for Courts in that Governorate and persist
   only the selected name.
3. Hearing forms load backend Courts and Circuits as dependent references.

## Remove/disable

- Firm-user "Create Court"
- Firm-user "Edit Court"
- Firm-user "Delete Court"
- tenant-specific Court creation UX

unless the v2 PRD is later changed.

## Validation

The mobile app filters options, but backend must also reject inconsistent IDs.

If backend still stores Courts as tenant-owned CRUD records, report a backend violation.

---

# 10. Phase 6 — Granular Case Access Grants

## Goal

Implement the v2 access model instead of broad Case-team-role access.

## Mobile domain model

Represent Case grants explicitly, with capability codes such as:

- `case.view`
- `case.edit`
- `case.status.manage`
- `client.view`
- `client.edit`
- `opponent.view`
- `opponent.edit`
- `document.view`
- `document.download`
- `document.upload`
- `document.edit`
- `document.manage`
- `hearing.view`
- `hearing.create`
- `hearing.edit`
- `hearing.assign`
- `hearing.complete`
- `service.view`
- `service.create`
- `service.edit`
- `service.assign`
- `service.complete`
- `meeting.view`
- `meeting.create`
- `meeting.edit`
- `meeting.assign`
- `meeting.complete`
- `task.view`
- `task.create`
- `task.assign`
- `task.update`
- `task.complete`
- `finance.view`
- `finance.payment.record`
- `finance.manage`
- `case.access.manage`

Use the exact verified backend codes if naming differs; document any mismatch in `API_CONTRACT.md`.

## UI

Case -> Access & Assignments:

- list Employees with granted access
- show granted capabilities
- add/revoke capabilities
- distinguish Case-wide capabilities from activity assignments
- do not grant broad access from a single Hearing/Meeting/Task assignment

## Critical security rule

An activity-only assignee receives minimum context only.

Flutter must not fetch and cache the entire Case just because a user is assigned one activity if the backend provides a scoped activity detail endpoint.

If the backend only returns full Case content to activity assignees, record a backend privacy violation.

---

# 11. Phase 7 — Lawyer Specialization Filtering

## Goal

Enforce Case Type -> eligible Lawyer selection consistently.

## Apply to

- Case lawyer assignment
- Hearing assigned lawyer
- any legal-counsel assignment requiring a Lawyer

## Rules

- Only users classified `LAWYER` are shown.
- Lawyer must include the Case Type in their specialization set.
- Firm Admin is not automatically a legal assignee.
- A Firm Admin may be offered as lawyer only if classified Lawyer and specialization matches.
- Backend must reject an incompatible lawyer ID even if Flutter filtering is bypassed.

## Tests

- Criminal Case excludes Civil-only lawyer.
- Multi-specialization lawyer appears in every matching Case Type.
- Non-lawyer never appears in lawyer picker.
- API 4xx mismatch is mapped to a clear validation message.

---

# 12. Phase 8 — Case Activities

## 12.1 Hearings

Preserve/refactor current Hearing functionality to v2:

- one Case
- scheduled date/time
- Court/Circuit
- type
- judge
- optional matching assigned Lawyer
- status:
  - `SCHEDULED`
  - `COMPLETED`
  - `ADJOURNED`
  - `CANCELLED`
- outcome/notes
- supporting documents/minutes
- next hearing/adjournment flow if backend supports it

## 12.2 Service of Process

Add a first-class feature if backend supports it:

- Case
- Court
- scheduled date/time
- assignee
- recipient/service details
- notes
- attachments
- result
- statuses:
  - `SCHEDULED`
  - `COMPLETED`
  - `FAILED`
  - `RESCHEDULED`
  - `CANCELLED`

If no backend model/endpoints exist, this is a v2 backend blocker.

## 12.3 Client Meetings

Add a Case-bound Client Meeting feature:

- Case
- schedule
- location/method
- subject
- assigned user
- notes/outcome
- statuses:
  - `SCHEDULED`
  - `COMPLETED`
  - `CANCELLED`
  - `RESCHEDULED`

If absent server-side, report it as a backend blocker.

## 12.4 Tasks

Refactor Tasks to:

- Case scope for legal work
- optional activity link
- assignee
- priority
- due date/time
- v2 status model
- permission-safe visibility

---

# 13. Phase 9 — Documents

## Goal

Make every v2 legal document Case-owned.

## Tasks

- Require Case association.
- Support optional Hearing or Service association.
- Enforce capability-based actions:
  - view
  - download
  - upload
  - edit metadata
  - manage/archive
- Preserve version metadata/history if backend supports it.
- Remove assumptions based on old Tenant/Entity/Restricted/Owner access-level model where they conflict with v2.
- Do not expose document names/metadata through notifications without permission.

---

# 14. Phase 10 — Calendar and Notifications

## 14.1 Calendar

Unified event sources:

- Hearings
- Service of Process
- Client Meetings
- Task due dates

Firm Admin:

- sees only firm events allowed by assigned account permissions

Employee:

- sees only assigned/authorized events

Deep-link/open behavior must re-check current authorization.

## 14.2 Notifications

Wire to real data.

Support:

- assignment
- reassignment
- material schedule changes
- access/permission changes where user action is affected
- due-today scheduled work

Rules:

- per-user read/unread
- safe payloads
- no hidden Case/client/opponent/document/finance data
- access revocation suppresses future notifications
- opening a notification rechecks authorization

Do not resurrect the old hard-coded 24h/1h reminder requirement unless current v2 docs/API explicitly support it.

---

# 15. Phase 11 — Finance Refactor

## Goal

Replace the v1 invoice-centric mobile experience with v2 Case fee/payment tracking.

## Required model

Per Case:

- `agreedFee`
- payment records:
  - amount
  - date
  - method
  - reference
  - notes
  - recorded by
- calculated paid amount
- calculated remaining amount

Firm-level authorized dashboard:

- total Case value
- total collected
- total outstanding
- paid / partial / unpaid Case counts

## Permission rules

- `ACCOUNTANT` job classification alone does nothing.
- Case finance requires explicit finance permission + Case grant.
- firm totals require `finance.firm.read`.
- hide finance by default when permission state is missing/ambiguous.

## Remove from active v2 UI

- Invoice list/detail/create
- Invoice line items
- Expense workflows
- tax/accounting-ledger workflows

Existing backend Invoice APIs may remain for historical compatibility, but the mobile v2 product must not depend on them.

If the backend lacks Case payment ledger APIs and only supports invoices/payments, report a backend blocker rather than mapping invoices to Case payments incorrectly.

---

# 16. Phase 12 — Subscription Behavior Cleanup

## Goal

Remove v1 mobile behavior that treats subscription state as an automatic full-app block/read-only transition.

## Tasks

- Audit the existing 402 interceptor/route guard/blocking screen.
- Compare with current backend behavior.
- The v2 PRD does not allow subscription expiry/failure to automatically impose the old suspended/read-only model.
- If backend still globally rejects all tenant requests based solely on subscription state, record a backend violation.
- Do not implement a mobile workaround that pretends the workspace is available if the backend blocks it.
- Firm `ACTIVE/INACTIVE` is a separate explicit operator-controlled state.

---

# 17. Phase 13 — Profile, Settings, Appearance

## Firm Admin / Employee

Support:

- own display/profile information
- profile image/avatar
- EN/AR preference
- RTL
- Light/Dark/System theme
- password/security settings

## Firm Admin where permitted

- firm profile/branding settings

## Security

- no self-escalation of account type
- no self-granting permissions
- no self-edit of lawyer specialization unless the backend explicitly exposes an authorized flow

---

# 18. Phase 14 — Remove / Disable v1 Product Violations

After replacement flows exist, remove or disable obsolete v1 UI/navigation assumptions:

- standalone reusable Client registry as the v2 source of truth
- standalone reusable Opponent registry as the v2 source of truth
- tenant Court CRUD
- broad Case-team-role authorization
- automatic Firm Admin full-CRUD assumption
- job-title-based permission shortcuts
- Invoice/Expense product flows
- automatic subscription blocking/read-only UX tied to old logic
- AI/RAG routes, plan entitlements, and visible features
- public signup links/routes
- any marketplace/reviews/consultation UI outside v2

Do not delete historical backend/mobile code merely for cleanliness until replacement flows are verified. First remove it from active routes and dependencies, then clean safely.

---

# 19. Phase 15 — Testing and v2 Acceptance

At minimum, automated tests must cover the PRD v2 acceptance cases that apply to mobile.

## Identity / permissions

- account types parse correctly
- job title alone grants no access
- Firm Admin actions respect assigned permissions
- Employee access revocation takes effect

## Cases

- Case-local Client
- Case-local Opponent
- Case Type required
- matching lawyer filtering
- mismatched backend assignment error

## Judicial hierarchy

- Governorate -> Court filter
- Court -> Circuit filter
- invalid hierarchy error handling

## Case grants

- document-only Employee cannot access finance
- Hearing-only assignee gets minimum context
- unrelated Case deep link denied
- revoked grant removes screen/data access

## Calendar / notifications

- only authorized events appear
- safe notification payloads
- deep link rechecks authorization

## Finance

- finance hidden without permission
- accountant title alone does not grant access
- paid/remaining totals match Case payments

## Localization

- EN LTR
- AR RTL
- no new hard-coded user-facing strings

## Quality gates

Run:

- `flutter test`
- `flutter analyze`
- `dart format` only on touched files/directories unless a project-wide formatting change is intentionally approved
- generated-code steps required by Freezed/injectable/l10n
- targeted integration tests against a real/dev backend when available

---

# 20. Phase 16 — Final documentation synchronization

Before declaring v2 migration complete:

1. Re-read `HOQOOQ_PRD_v2.0_UPDATED.md`.
2. Re-run the backend compliance checklist.
3. Update `API_CONTRACT.md` with final verified API behavior.
4. Update `hoqooq_mobile_spec.md` only where its old screen/flow descriptions conflict with implemented v2 mobile behavior.
5. Update `PROJECT_SUMMARY.md` with the resulting application state.
6. Update `CLAUDE.md` / working memory with concise current facts only.
7. Update this `PLAN.md` with completion status and remaining blockers.
8. Update `BACKEND_VIOLATIONS_V2.md` with:
   - fixed
   - still open
   - no longer applicable
9. Provide the user a final implementation report containing:
   - mobile changes
   - tests
   - backend violations
   - blocked features
   - API contract changes
   - deferred items

---

# 21. Previously observed backend risks that MUST be re-verified

These are historical findings, not assumptions that they are still true. Re-check the current backend from scratch.

1. `GET /users` previously returned users across tenants without tenant filtering.
2. `POST /users` previously trusted a client-supplied `tenantId` instead of deriving/validating it safely.
3. Client read/update/delete paths previously crashed because raw SQL referenced camelCase column names instead of the actual snake_case schema.
4. The backend previously used a hard-coded `FIRM_ADMIN` role and broad role/permission assumptions inconsistent with v2's account-type + explicit permission model.
5. Existing Case team assignment used broad access-level/role semantics rather than v2 granular Case capability grants.
6. Clients and Opponents were modeled as reusable standalone records rather than Case-local snapshots.
7. Courts were exposed as tenant-managed CRUD rather than global seeded Governorate/Court/Circuit reference data.
8. A global subscription guard previously returned `402` and blocked every authenticated request when the subscription was not active.
9. Finance was previously centered on Invoices/Payments and included hard-delete behavior for some financial entities; v2 requires a Case fee/payment ledger and removes invoice/expense product flows.
10. Service of Process and Client Meeting first-class v2 endpoints may not exist.
11. Case timeline/access-grant APIs may be missing or incomplete.
12. AI endpoints were previously stubs; v2 excludes AI entirely, so the mobile app must not expose them.

For every item:
- verify current source
- verify runtime if possible
- cite the exact backend file/route in `BACKEND_VIOLATIONS_V2.md`
- never silently compensate in Flutter for a security or tenant-isolation issue

---

# 22. Implementation discipline

- Work in small, reviewable commits.
- Do not mix unrelated refactors into a v2 migration feature.
- Preserve working behavior that is compatible with v2.
- Do not retain old behavior merely because tests currently encode it; update obsolete tests.
- No fake/mock production data.
- No ad-hoc endpoint strings inside feature code; networking must remain centralized and consistent with `API_CONTRACT.md`.
- Treat 401/403/404/409/422/5xx according to the verified API contract.
- Never display server error internals to end users.
- Never log passwords, tokens, national IDs, legal document content, or privileged Case payloads.
- When a backend dependency blocks a mobile feature, document it and move to a non-blocked task rather than inventing a temporary incompatible API.

---

# Definition of v2 mobile completion

The migration is complete only when:

- mobile behavior matches the v2 PRD
- obsolete v1 routes/assumptions are no longer active
- the API contract matches the current backend
- all backend violations are documented
- no known tenant isolation or authorization defect is hidden by client-side filtering
- v2 permissions work for Firm Admin and Employee
- Case-local Client/Opponent flows are active
- lawyer specialization filtering works
- Governorate/Court/Circuit filtering works
- granular Case access and activity assignments work
- Hearings, Service of Process, Client Meetings, Tasks, Documents, Calendar, Notifications, and Finance follow v2 scope or are explicitly marked blocked by missing backend support
- AI/RAG is not exposed
- subscription logic does not preserve the removed v1 suspension behavior
- EN/AR + RTL pass
- tests and static analysis pass
- documentation is synchronized
