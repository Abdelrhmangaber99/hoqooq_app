# Skipped Phase Backend Blockers

This is the living tracker for production-readiness phases intentionally
skipped because the required backend contract is incomplete.

When a backend blocker is resolved:

1. Re-check the implemented endpoint and DTO against the backend source and
   Swagger output.
2. Make only the small Flutter model, repository, state, and UI updates needed
   to consume the completed contract.
3. Add or update focused tests.
4. Mark the blocker resolved here and resume the affected phase exit gate.

Do not compensate for these blockers with fabricated data, client-only
authorization, or assumptions about fields the backend does not return.

## Phase 5 — Case-Centric Data Model

Phase status: **Skipped with backend blockers**

### P5-B01 — Authoritative Lawyer picker data

- Related audit finding: `BV2-016`
- Backend problem: Employee responses do not reliably expose account type,
  job classification, account status, phone, and effective permissions.
- Blocked behavior: Flutter cannot authoritatively identify active Lawyers or
  validate the primary-Lawyer picker using backend-provided professional data.
- Required backend result: Tenant-scoped Employee responses include the
  authoritative classification, status, and effective permission fields.
- Small Flutter update after resolution: Update the Employee model/repository,
  restrict the picker to active `LAWYER` Employees, and add parsing/filtering
  tests.
- Status: **Open — skipped**

### P5-B02 — Case-owned party snapshot updates

- Related audit finding: `BV2-021`
- Backend problem: `PATCH /cases/:id` excludes `client` and `opponents`, and no
  dedicated snapshot-update endpoint exists.
- Blocked behavior: Existing Case Client and Opponent snapshots must remain
  read-only in Flutter.
- Required backend result: Capability-protected, tenant-scoped operations for
  updating the Case Client and Opponent snapshots with audit/timeline history.
- Small Flutter update after resolution: Add update request models and
  repository methods, enable the existing party fields in edit mode, refresh
  Case Details after saving, and add Case-isolation tests.
- Status: **Open — skipped**

### P5-B03 — Case lifecycle enforcement

- Related audit finding: `BV2-022`
- Backend problem: The backend exposes `SUSPENDED` and accepts invalid direct
  transitions, including transitions out of `ARCHIVED`.
- Blocked behavior: Flutter can hide unsupported transitions but cannot enforce
  lifecycle integrity against direct API requests.
- Required backend result: An explicit server-side transition matrix aligned
  with `DRAFT → ACTIVE → CLOSED → ARCHIVED`, including archive finality.
- Small Flutter update after resolution: Read the finalized lifecycle contract,
  restrict the status selector to server-approved next states, map any updated
  error response, and add transition tests.
- Status: **Open — skipped**

### Phase 5 work already completed

- Case-owned Client and Opponent creation snapshots.
- Google Places Court selection in Flutter.
- Case Court stored and filtered as `courtName` only.
- Backend Case Court UUID/relation removed through a reversible migration.

## Phase 6 — Granular Case Permission and Assignment Engine

Phase status: **Partially implemented, then skipped at backend blocker**

### P6-B01 — List existing Case access grants

- Related audit finding: `BV2-018`
- Backend problem: Capability sets can be replaced with
  `PUT /cases/:id/access-grants/:userId` and revoked with DELETE, but no endpoint
  lists the current Case grantees and their active capabilities.
- Blocked behavior: Flutter cannot display existing grants, prefill an
  Employee's current capability set, or safely provide a complete access
  management screen.
- Required backend result: A permission-protected, tenant-scoped endpoint such
  as `GET /cases/:id/access-grants` returning active grantees, Employee
  summaries, and capability arrays.
- Small Flutter update after resolution: Add the grant response model and GET
  repository method, load grants in the access BLoC, prefill capability
  selections, show current grantees, and refresh after replace/revoke.
- Status: **Open — skipped**

### Phase 6 work already completed

- Flutter mirrors all backend Case capability values.
- Delegation choices are limited by the current user's base permissions.
- Active Employee filtering is applied when authoritative classification is
  available.
- Capability-set replacement and complete revocation are integrated.
- Case Details avoids loading Hearing, Document, and Finance sections when the
  corresponding base permission is absent.

## Future skipped phases

## Phase 7 — Complete Case Activities

Phase status: **Flutter workflows implemented; exit gate blocked by backend-owned requirements**

### P7-B01 — Authoritative activity assignee data

- Related audit finding: `BV2-016`
- Backend problem: Employee responses do not yet provide authoritative active
  Employee/Lawyer classification and effective permission data for activity
  assignment pickers.
- Blocked behavior: Flutter cannot safely implement Hearing specialization
  matching or Meeting/Task assignment and reassignment visibility workflows.
- Required backend result: Tenant-scoped active Employee responses with account
  type, professional classification, status, and effective permissions.
- Small Flutter update after resolution: Enable permission-gated assignment
  controls, filter Hearing assignees by Case Type specialization, and add
  reassignment refresh/visibility tests.
- Status: **Open — skipped**

### P7-B02 — Rescheduling history contract

- Related test: `P7-T07`
- Backend problem: Activity updates can replace schedule fields, but no
  source-verified response or history endpoint exposes the previous schedule as
  retained audit evidence.
- Blocked behavior: Flutter cannot prove or display historical rescheduling
  evidence after an activity date changes.
- Required backend result: An auditable reschedule operation or activity-history
  endpoint that retains old/new schedule values and actor/timestamp metadata.
- Small Flutter update after resolution: Use the reschedule operation, display
  history in Case Details, and add preservation tests.
- Status: **Open — skipped**

### P7-B03 — Assignment isolation exit tests

- Related tests: `P7-T09`, `P7-T10`, `P7-T11`
- Backend problem: These guarantees depend on server query scoping, grant
  revocation, and minimum-context serialization and cannot be established by a
  Flutter repository mock test.
- Blocked behavior: Phase 7 cannot claim its authorization exit gate from the
  mobile suite alone.
- Required backend result: Integration/e2e coverage proving unrelated Case
  non-discovery, immediate reassignment access changes, and minimum activity-only
  context.
- Small Flutter update after resolution: Add client regression tests against the
  finalized response/error shapes and enable the assignment UI from P7-B01.
- Status: **Open — skipped**

## Phase 8 — Documents, Versioning, Timeline and Audit

Phase status: **Supported Flutter slice implemented; exit gate blocked by backend surfaces**

### P8-B01 — Prior-version retrieval

- Related tests: `P8-T04`
- Backend problem: Immutable `document_versions` are created, but no endpoint
  lists versions or downloads an authorized historical version.
- Blocked behavior: Flutter can upload and show the current version number but
  cannot display or retrieve previous versions.
- Required backend result: Tenant- and Case-capability-scoped version list and
  historical download endpoints.
- Small Flutter update after resolution: Add version entities/repository calls,
  a version-history sheet, and authorized historical-download tests.
- Status: **Open — skipped**

### P8-B02 — Complete Case timeline production

- Related tests: `P8-T08`
- Backend problem: Case status and grant changes write timeline events, but the
  current services do not source-verify timeline records for every required
  material event, including document uploads/version replacement.
- Blocked behavior: Flutter can display embedded timeline events but cannot
  guarantee a complete legal history.
- Required backend result: Transactional timeline writes for every Phase 8
  material event, with deterministic ordering and actor metadata.
- Small Flutter update after resolution: Add event labels for any finalized
  types and end-to-end refresh/rendering tests.
- Status: **Open — skipped**

### P8-B03 — Audit-log visibility and verification

- Related tests: `P8-T09`, `P8-T10`
- Backend problem: Audit rows are written internally for Case grant changes,
  but no permission-protected audit read surface exists and required critical
  actions are not all source-verified as audited.
- Blocked behavior: Flutter cannot provide authorized audit review or verify
  immutable audit coverage.
- Required backend result: Read-only, tenant-scoped audit endpoints plus backend
  integration tests proving critical-action coverage and employee immutability.
- Small Flutter update after resolution: Add a permission-gated audit viewer and
  response/error-shape regression tests; expose no mutation controls.
- Status: **Open — skipped**

### P8-B04 — Storage and cross-tenant download integration proof

- Related tests: `P8-T07`, `P8-T11`
- Backend problem: Source uses tenant/Case-prefixed object keys and rechecks the
  Case download capability, but the required cross-tenant and storage-boundary
  guarantees need backend integration tests against database and object storage.
- Blocked behavior: Flutter unit tests cannot prove Firm isolation or physical
  object-path enforcement.
- Required backend result: Integration/e2e tests proving cross-tenant denial
  and tenant + Case object-key boundaries.
- Small Flutter update after resolution: Preserve the current permission-gated
  download UX and add regression tests for finalized denial responses.
- Status: **Open — skipped**

## Phase 9 — Unified Calendar and Notifications

Phase status: **Supported Flutter slice implemented; exit gate blocked by backend guarantees**

### P9-B01 — Firm Admin Calendar source-permission enforcement

- Related tests: `P9-T01`, `P9-T12`
- Backend problem: `GET /calendar/timeline` scopes Employees by assignment or
  Case capability, but a Firm Admin holding `calendar.read` receives every
  tenant activity without per-source Hearing/Service/Meeting/Task permission
  filtering.
- Blocked behavior: Flutter hides disallowed source types as defense in depth,
  but the API response itself still discloses them.
- Required backend result: Apply the current principal's source permissions to
  every Calendar query for all account types and prove web/mobile scope parity.
- Small Flutter update after resolution: Remove redundant filtering only if the
  contract guarantees it, and add response-level permission matrix regressions.
- Status: **Open — skipped**

### P9-B02 — Calendar revocation and activity-only deep-link proof

- Related tests: `P9-T02`, `P9-T03`, `P9-T04`
- Backend problem: Source queries appear grant/assignment scoped, but no
  integration suite proves immediate revocation, activity-only minimum context,
  and authorization recheck across every activity detail endpoint.
- Blocked behavior: Flutter cannot safely claim the deep-link exit gate or use
  Case Details as a universal target because activity-only users may not hold
  `case.view`.
- Required backend result: Integration tests plus a finalized per-activity
  detail/deep-link contract that returns minimum safe context.
- Small Flutter update after resolution: Add typed activity detail routes and
  route Calendar/notification items by `type + id` while mapping 403/404 safely.
- Status: **Open — skipped**

### P9-B03 — Complete notification generation

- Related tests: `P9-T05`, `P9-T06`, `P9-T07`, `P9-T08`, `P9-T10`
- Backend problem: New-assignee notifications exist, but previous assignees are
  not consistently notified on reassignment, material schedule updates do not
  consistently notify, and there is no source-verified duplicate-safe daily
  notification job. The daily endpoint is an on-demand feed, not persisted
  read/unread notifications.
- Blocked behavior: Flutter can show safe unread notifications and the scoped
  daily feed but cannot supply missing server-generated events or prove payload
  safety/deduplication end to end.
- Required backend result: Transactional generation rules for assignment,
  reassignment, material schedule changes, access effects, and duplicate-safe
  daily reminders with safe payload tests.
- Small Flutter update after resolution: Parse any finalized notification types,
  add typed safe deep links, and test read/unread refresh behavior.
- Status: **Open — skipped**

### P9-B04 — Cross-activity scheduling conflicts

- Related test: `P9-T11`
- Backend problem: Hearing creation detects only an exact-time conflict for the
  assigned Lawyer; no unified overlap contract covers Hearings, Service,
  Meetings, and Tasks for an Employee.
- Blocked behavior: Flutter cannot provide an authoritative overlap warning from
  the unified schedule, especially while assignee pickers remain blocked by
  `BV2-016`.
- Required backend result: A tenant-scoped conflict-check response covering all
  scheduled activity types, with override/audit rules.
- Small Flutter update after resolution: Show the warning in activity forms,
  require justification when applicable, and add overlap boundary tests.
- Status: **Open — skipped**

## Phase 11 — Super Admin, Plans, Subscriptions and Firm Administration

Phase status: **Supported Flutter slice implemented; exit gate blocked by backend guarantees**

### P11-B01 — Operator-controlled EXPIRED subscription state

- Related tests: `P11-T01`, `P11-T02`, `P11-T04`
- Backend problem: `EXPIRED` exists in the subscription enum, but the operator
  API can only activate to ACTIVE, deactivate to CANCELLED, or change plan and
  billing cycle while retaining the current status. Super Admin cannot
  explicitly set EXPIRED or manage period dates through the API.
- Blocked behavior: Flutter can display EXPIRED when returned, but cannot make
  the authoritative operator-controlled state transition or prove it through
  the public contract.
- Required backend result: A versioned Super Admin subscription-state operation
  covering PENDING/ACTIVE/EXPIRED/CANCELLED and period dates, with integration
  tests proving EXPIRED changes only subscription state.
- Small Flutter update after resolution: Refresh displayed subscription state
  after the finalized transition and add an integration regression.
- Status: **Open — skipped**

### P11-B02 — Operator plan management API

- Related test: `P11-T12`
- Backend problem: The only plan route is public `GET /subscriptions/plans`,
  filtered to active plans. No create, update, archive, or inactive-plan read
  route uses the existing `platform.plan.manage` permission.
- Blocked behavior: Flutter can select active seeded plans but cannot manage the
  plan catalog according to operator policy.
- Required backend result: Permission-protected plan CRUD/archive endpoints
  with stable DTOs and seeded-plan policy tests.
- Small Flutter update after resolution: Add a Plans admin screen and typed
  create/edit/archive flows.
- Status: **Open — skipped**

### P11-B03 — Platform audit read surface and durable mutation audit

- Related test: `P11-T09`
- Backend problem: Audit rows are written by a best-effort interceptor, but no
  platform audit controller exists. Audit write failures are swallowed, and
  subscription routes use `tenantId` rather than `id`, so the generic
  interceptor does not record the target as `resourceId`.
- Blocked behavior: Flutter cannot display platform audit or verify a durable,
  attributable subscription-change record.
- Required backend result: A `platform.audit.read` endpoint plus transactional
  or otherwise guaranteed subscription audit records containing actor, target
  Firm, old state, new state, and request identity.
- Small Flutter update after resolution: Add a read-only platform audit page
  with filters and contract tests.
- Status: **Open — skipped**

### P11-B04 — Platform authorization and tenant-content isolation proof

- Related tests: `P11-T03`, `P11-T06`, `P11-T07`, `P11-T10`, `P11-T11`
- Backend problem: Permission guards and the Super Admin route allowlist appear
  aligned in source, but no Phase 11 integration matrix proves explicit Firm
  deactivation enforcement, denial of tenant legal/document content, employee
  denial of subscription management, and prevention of platform self-grants.
- Blocked behavior: Flutter hides tenant-content navigation from Super Admin
  and exposes platform controls only there, but client routing cannot establish
  server-side isolation or authorization.
- Required backend result: Authenticated integration tests for each account
  type, Firm state, and subscription state across platform and tenant routes.
- Small Flutter update after resolution: Add finalized denial/error mappings
  only if response contracts differ from the current global mapping.
- Status: **Open — skipped**

Add every future backend-blocked phase here using this format:

```text
## Phase N — Name
Phase status: Skipped with backend blockers

### PN-B01 — Short blocker name
- Related audit finding:
- Backend problem:
- Blocked behavior:
- Required backend result:
- Small Flutter update after resolution:
- Status: Open — skipped
```
