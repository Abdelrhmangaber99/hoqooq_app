# Prompt for ChatGPT Terminal Agent — HOQOOQ Mobile v2 Migration

You are working inside the existing **HOQOOQ** repository. Your job is to update the existing Flutter mobile application so that it matches the new authoritative **HOQOOQ PRD v2.0**.

This is **not a greenfield rewrite**. Preserve the existing working architecture and functionality where it is compatible with v2.0. Refactor or remove only what conflicts with the new business rules.

## FIRST: DO NOT WRITE CODE YET

Before making any implementation change, locate and read these files **in full**:

1. `HOQOOQ_PRD_v2.0_UPDATED.md`
2. `API_CONTRACT.md`
3. `hoqooq_mobile_spec.md`
4. `PROJECT_SUMMARY.md`
5. `CLAUDE.md`
6. the current `PLAN.md`
7. the current backend source under `Hoqooq-main/` or the actual backend folder available in this repo
8. any current Postman / Swagger / OpenAPI artifact if available

You must understand the current app, current backend, current API contract, and new v2 business rules before touching implementation.

---

## SOURCE PRECEDENCE

When documents or code disagree, follow this order:

1. **`HOQOOQ_PRD_v2.0_UPDATED.md`**
   - authoritative for business rules, scope, roles/account types, permissions, workflows, and v2 product behavior.

2. **Current backend source**
   - authoritative only for what the backend actually does today.
   - if backend behavior conflicts with the v2 PRD, treat that as a **BACKEND VIOLATION**.
   - do not change the mobile app to preserve an obsolete backend business rule.

3. **`API_CONTRACT.md`**
   - integration reference for endpoint paths, requests, responses, errors, and authentication.
   - it MUST be re-verified against the current backend before relying on it.
   - update it if backend behavior has changed.

4. **`hoqooq_mobile_spec.md`**
   - mobile screens, UX, architecture, and product guidance.
   - use it only where it does not conflict with the v2 PRD or actual API.

5. `PROJECT_SUMMARY.md` and `CLAUDE.md`
   - historical/current implementation context.

6. Older PRDs, old milestones, mocks, old UI behavior, and old Postman assumptions
   - non-authoritative when they conflict with v2.

Do not invent endpoints or payloads.

---

# REQUIRED DOCUMENT CHANGE

The old `PLAN.md` is obsolete.

I am providing a new v2 `PLAN.md`.

**Replace the repository's current `PLAN.md` with the new v2 `PLAN.md` completely.**

Do not append the new plan below the old milestone history. The old plan remains available through git history.

After replacing it, use the new `PLAN.md` as the execution plan for this migration and update milestone/status checkboxes as work progresses.

---

# PHASE 0 — BACKEND + MOBILE COMPLIANCE AUDIT

Before implementation, perform a fresh audit.

Do not trust historical findings without re-verifying them against the current backend source.

Create:

`BACKEND_VIOLATIONS_V2.md`

For every backend mismatch against the v2 PRD include:

- violation ID
- severity
- exact PRD `BR-###`
- backend file/controller/service/entity/guard
- endpoint/model
- current behavior
- expected v2 behavior
- mobile impact
- security/tenant-isolation impact
- required backend change
- whether the mobile feature is blocked
- status

If the backend violates the PRD:

- tell me explicitly
- document it
- do NOT silently hide the problem with Flutter-side filtering
- do NOT invent a fake mobile-only contract
- do NOT modify the backend unless I explicitly ask you to
- continue with non-blocked mobile work where possible

If a required v2 mobile feature has no backend API, mark it as a backend blocker rather than inventing an endpoint.

---

# VERY IMPORTANT V2 BUSINESS MODEL

The new PRD intentionally overrides major parts of the old implementation.

## Account Types

There are exactly three system account types:

- `SUPER_ADMIN`
- `FIRM_ADMIN`
- `EMPLOYEE`

`LAWYER`, `SECRETARY`, `ACCOUNTANT`, `ASSISTANT`, `OTHER` are **professional/job classifications**, not authentication roles.

Authorization must never be based only on job classification.

---

## Provisioning

- Super Admin is seeded.
- Super Admin creates:
  - Firms
  - Firm Admin accounts
- Firm Admin creates/manages Employees.
- Super Admin does NOT create normal Employees.
- Firm Admin permissions are assigned by Super Admin.
- Firm Admin is no longer automatically hard-coded as irrevocable full CRUD.

---

## Employee / Lawyer Profile

Employee/Firm Admin professional profile must support:

- job classification
- lawyer specialization(s) when classified as Lawyer
- permissions
- account status
- profile/preferences

A Lawyer may have multiple Case Type specializations.

---

## Lawyer Assignment

A lawyer can be assigned only when their specialization includes the Case Type.

This applies to:

- Case lawyer assignment
- Hearing lawyer assignment
- any activity that explicitly requires legal counsel

The mobile picker must filter invalid lawyers.

The backend must also reject an incompatible lawyer ID.

If backend validation is missing, record a backend violation.

---

## Case-Centric Data

The **Case** is the main workspace.

### Client

The Client is stored inside the Case as a case-local snapshot.

Do NOT use a reusable firm-wide Client registry as the authoritative v2 flow.

If the same person has two Cases, the Client information is duplicated independently in both Cases.

### Opponent

Opponent information is also case-local.

Do not use a reusable firm-wide Opponent master record as the v2 source of truth.

---

## Governorate / Court / Circuit

Reference data is global and seeded:

`Governorate -> Court -> Circuit`

Flow:

1. select Governorate
2. display only Courts belonging to it
3. select Court
4. display only Circuits belonging to it

Firm users do not create/edit/delete Court reference data in v2.

If backend still uses tenant-owned Court CRUD, report it.

---

# GRANULAR PERMISSION MODEL

The v2 application requires layered permissions:

1. account-level permission
2. Employee base permission
3. Case-specific access grant
4. activity-specific assignment
5. professional specialization constraint when required

An Employee being assigned to a Case does NOT imply full Case access.

Example:

- Lawyer A: `case.view` + `document.view`
- Secretary B: `client.edit` + `document.upload`
- Lawyer C: assigned only to Hearing #3
- Employee D: assigned only to a Client Meeting
- Accountant E: `finance.view` + `finance.payment.record`

Implement using verified backend permission codes.

Do not assume legacy Case team role/access-level values equal v2 capabilities.

If the backend does not have granular Case access grants, report a blocker.

---

# MINIMUM CONTEXT FOR ACTIVITY-ONLY ASSIGNMENT

A user assigned only to a Hearing / Service / Meeting / Task must not automatically receive the full Case.

They may receive only the minimum context necessary for the assignment, such as:

- Case reference/title
- client display name if needed
- Court
- date/time
- activity notes explicitly shared

They must not automatically receive:

- finance
- unrelated documents
- opponent details
- unrelated hearings
- unrelated tasks

If the backend returns the whole Case to an activity-only assignee, flag it as a privacy/authorization violation.

---

# MOBILE FEATURES TO ALIGN WITH V2

Update or create the mobile implementation for:

## Authentication / Session

- v2 account types
- permissions
- job classification
- lawyer specializations
- active/inactive state
- secure session
- route guards

## Dashboard

Firm Admin:
- authorized firm work
- today Hearings
- Service of Process
- Client Meetings
- due Tasks
- finance widgets only when permitted

Employee:
- assigned/authorized Cases
- assigned activities
- due Tasks
- permitted finance only

No mock production data.

## Employee Management

Firm Admin can:

- list/search Employees
- create Employee
- edit Employee
- set classification
- set Lawyer specializations
- grant/revoke base permissions
- activate/deactivate Employee

Only implement against real verified APIs.

## Cases

Support:

- Case Type
- Governorate
- Court
- Circuit
- case-local Client
- case-local Opponent
- Case details
- lifecycle
- selective Case access
- finance where permitted

## Hearings

Support current v2 fields and:

- Court/Circuit
- schedule
- status
- outcome
- matching Lawyer assignment
- calendar
- notifications

## Service of Process

This is now a first-class Case activity.

Required fields/behavior include:

- Case
- Court
- schedule
- assignee
- recipient/service details
- notes
- attachments
- result
- statuses:
  - SCHEDULED
  - COMPLETED
  - FAILED
  - RESCHEDULED
  - CANCELLED
- calendar + notification integration

If backend API does not exist, report it.

## Client Meetings

Case-bound activity containing:

- schedule
- subject
- location/method
- assigned Employee
- notes/outcome
- status
- calendar
- notifications

If backend API does not exist, report it.

## Tasks

Tasks must respect:

- Case/activity scope
- assignee
- due date/time
- priority
- status
- permission-safe visibility

## Documents

Every v2 legal document belongs to a Case.

Permissions include:

- view
- download
- upload
- edit metadata
- manage/archive

Optional link to Hearing or Service of Process.

## Calendar

Unified view of:

- Hearings
- Service of Process
- Client Meetings
- Task due dates

Firm Admin sees only events allowed by their permissions.

Employee sees assigned/authorized events only.

Deep links must recheck authorization.

## Notifications

Use real API data.

Support:

- assignment
- reassignment
- schedule changes
- relevant permission/access changes
- today's work

Never leak hidden Case/client/opponent/document/finance data in notification text.

## Finance

The old Invoice-focused mobile flow is no longer the v2 product.

v2 finance is:

Per Case:
- agreed fee
- payment records
- paid
- remaining

Firm-level:
- total Case value
- total collected
- total outstanding
- paid / partial / unpaid Case counts

`ACCOUNTANT` classification alone gives NO finance access.

Finance requires explicit permissions.

Remove/disable active v2 navigation for:
- invoices
- invoice line items
- expenses
- tax/general-ledger flows

If backend supports only invoices rather than Case payments, report a backend blocker. Do not fake a Case ledger by interpreting invoices as something they are not.

## Settings

Support:

- profile
- avatar
- EN/AR
- RTL
- Light/Dark/System
- security/password settings

No self-escalation of:
- account type
- permissions
- lawyer specialization

---

# SUBSCRIPTION CHANGE

The old subscription suspension behavior is removed.

The mobile app must NOT preserve an old rule that automatically turns the app into read-only or blocks the workspace simply because subscription payment/state changed.

Audit the current:

- Subscription guard
- Dio 402 handling
- blocking route/screen
- subscription interceptor

If the backend still blocks every authenticated request with `402` based only on subscription state, report it as a backend violation against v2.

Do not fake around it on mobile.

Firm `ACTIVE/INACTIVE` is a separate explicit operator-controlled status.

---

# AI / RAG

AI/RAG is OUT OF SCOPE for v2.

- no AI assistant route
- no AI entitlement UI
- no AI dashboard widget
- no AI credit logic
- no RAG workflow required

Existing dormant code may remain only if it does not affect v2 behavior.

---

# KNOWN HISTORICAL BACKEND RISKS TO RE-VERIFY

These were observed previously. They may already be fixed. Do not assume either way; verify current source/runtime.

1. `GET /users` previously lacked tenant filtering and could return users from every tenant.
2. `POST /users` previously trusted client-supplied `tenantId`.
3. Client read/update/delete queries previously crashed due to camelCase raw SQL column references against snake_case DB columns.
4. Backend authorization previously depended on legacy `FIRM_ADMIN` role assumptions that may conflict with v2 explicit permissions.
5. Case team assignment previously used broad access-level/role semantics instead of granular Case capability grants.
6. Clients/Opponents previously existed as reusable standalone records.
7. Courts previously behaved as tenant-managed CRUD.
8. A global subscription guard previously blocked all authenticated API calls with `402` when subscription was inactive/expired.
9. Finance previously centered around Invoices/Payments and some finance removal paths used hard delete.
10. Service of Process may have no real first-class backend API.
11. Client Meetings may have no real first-class backend API.
12. Case access-grant/timeline APIs may be incomplete.
13. AI endpoints were stubs.

For every one, verify and report the exact current status.

---

# EXISTING FLUTTER ARCHITECTURE

Do not rewrite the app to another state-management/storage stack.

Preserve the existing project approach unless a verified technical blocker exists:

- `flutter_bloc`
- Equatable
- `get_it`
- `injectable`
- Hive
- Freezed
- `go_router`
- `dio`
- secure token storage
- current central networking/error mapping pattern

All API calls must remain centralized and consistent with `API_CONTRACT.md`.

No feature repository may introduce random hard-coded endpoint paths that bypass the contract/network layer.

---

# IMPLEMENTATION PROCESS

Follow the new `PLAN.md` milestone by milestone.

For each milestone:

1. inspect current code
2. inspect relevant backend source
3. inspect relevant `API_CONTRACT.md` section
4. compare against v2 BR rules
5. report blockers/violations
6. implement only verified behavior
7. add/update tests
8. run:
   - `flutter test`
   - `flutter analyze`
   - required code generation
   - targeted formatting on touched files
9. update:
   - `PLAN.md`
   - `API_CONTRACT.md` if contract changed
   - `BACKEND_VIOLATIONS_V2.md`
   - `CLAUDE.md` / working memory where necessary
10. commit in small, milestone-scoped commits

Do not do a giant rewrite in one commit.

---

# TESTING REQUIREMENTS

Add tests for:

- account type parsing
- permission helpers
- Firm Admin permission restrictions
- Employee permission restrictions
- Case-local Client/Opponent behavior
- lawyer specialization filtering
- invalid lawyer assignment response
- Governorate -> Court filtering
- Court -> Circuit filtering
- Case-specific access
- activity-only minimum context
- access revocation
- Calendar filtering
- notification privacy
- finance gating
- accountant title without finance permission
- Arabic RTL
- English LTR
- deep-link authorization

Do not keep obsolete tests simply because old v1 behavior used to pass.

---

# IMPORTANT SECURITY RULE

Client-side filtering is not security.

If a backend endpoint leaks another tenant's users, Cases, documents, payments, or privileged Case data:

- do not call the issue solved because Flutter filters the response
- classify it as Critical/High in `BACKEND_VIOLATIONS_V2.md`
- tell me
- continue using defensive client-side filtering only as temporary defense-in-depth if the existing app needs it, but explicitly label the backend as noncompliant

---

# FINAL DELIVERABLE

When the migration/audit session is complete, give me a concise final report containing:

## Mobile

- what was changed
- files/features changed
- tests added
- tests/analyzer status

## Backend violations

For each open violation:

- ID
- severity
- BR rule
- endpoint/backend file
- exact problem
- mobile impact
- required backend fix

## Backend blockers

List every v2 feature that cannot be completed because API support is missing.

## Documentation

Confirm status of:

- `HOQOOQ_PRD_v2.0_UPDATED.md`
- `PLAN.md`
- `API_CONTRACT.md`
- `hoqooq_mobile_spec.md`
- `PROJECT_SUMMARY.md`
- `CLAUDE.md`
- `BACKEND_VIOLATIONS_V2.md`

Do not claim v2 mobile is complete while a required feature is implemented only as mock data or while a required backend endpoint is missing.

Start now with **Phase 0 only: read everything, replace `PLAN.md`, re-audit backend/API/mobile against v2, update `API_CONTRACT.md` where necessary, create `BACKEND_VIOLATIONS_V2.md`, and report the findings before large feature implementation.**
