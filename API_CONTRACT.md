# Hoqooq API Contract

**Source (superseded 2026-07-30):** `hoqooq-postman-import.json` (87 requests, Postman Collection v2.1, `_postman_id: 0d05367b-0d3a-4c07-a99e-248fd3ff53b5`).

**Current primary source of truth (2026-07-30, same day): the real NestJS backend source at `Hoqooq-main/`** (gitignored — reference-only, not part of this Flutter repo). The user gave direct filesystem access to the actual backend. Where the Postman collection and the TypeScript source disagree, **the source wins** — the collection is now a secondary/illustrative artifact, not ground truth. `swagger.json`/`swagger2.json` in `Hoqooq-main/` are empty (0 bytes); `swagger-spec.json` is stale (matches the pre-re-sync collection) — neither is used as ground truth.

Per project instructions, this file is the source of truth for all HTTP calls (as informed by the backend source above).

---

## ⚠️ Findings from the backend-source re-sync (2026-07-30) — read before touching networking code

Confirmed directly from `Hoqooq-main/` TypeScript source, superseding assumptions made when only the Postman collection was available:

### A. Global response envelope (previously invisible — broke every repository's parsing against a real server)
`src/core/interceptors/transform.interceptor.ts` wraps **every successful response** in:
```json
{ "success": true, "statusCode": 200, "message": "...", "data": <actual payload> }
```
The Postman collection's example bodies show the *unwrapped* `data` value directly, which is why this was missed for two milestones. Every repository parsing `response.data` directly as the resource shape was broken until this fix. **Fixed:** `EnvelopeInterceptor` (`lib/core/network/interceptors/envelope_interceptor.dart`) now unwraps `data` for every response before it reaches a repository, registered on both the main `Dio` (`dio_client.dart`) and `RefreshInterceptor`'s internal raw `Dio`.

### B. Error response shape (previously undocumented — "no error-envelope example anywhere" is now resolved)
`src/core/filters/http-exception.filter.ts` confirms every 4xx/5xx response is:
```json
{ "success": false, "statusCode": 400, "message": "...", "error": "...", "timestamp": "..." }
```
**Fixed:** `mapDioError()` (`lib/core/network/dio_error_mapper.dart`) now extracts the real backend `message` field for `Failure` messages shown in the UI, instead of only generic per-status-code strings.

### C. Soft delete, not hard delete — corrects a standing wrong claim in this file and in CLAUDE.md (for the entities BR-016/024/028/029 actually cover)
`src/core/entities/base.entity.ts` gives every entity a TypeORM `@DeleteDateColumn` (`archivedAt`) + `isArchived` boolean, and the service methods for the entities BR-016/024/028/029 cover — `cases.service.ts`, `clients.service.ts`, `tenants.service.ts`, `documents.service.ts`, `calendar.service.ts` — call `.softRemove()`. **Every previous claim in this file that `DELETE` endpoints are hard deletes contradicting BR-016/024/028/029 was wrong** for those entities — it was an inference from the Postman collection's lack of implementation visibility, not a confirmed fact. BR-016/024/028/029 are **not violated**; `DELETE` is safe to wire to destructive UI actions on those entities subject to normal confirmation-dialog UX, same as any other soft-delete/archive action.

**⚠️ This does not generalize to every module.** M3 pre-planning research (finding I below) found `hearings.service.ts` and `tasks.service.ts` call plain `.remove()` — a real hard delete — despite `Hearing`/`Task` extending the same `BaseEntity` with the same soft-delete columns available. This is an inconsistency in the backend, not a documentation error on this file's part; don't assume "the backend does soft delete" as a blanket rule for modules not yet checked — verify per-module before wiring any delete action.

### D. `isFirmAdmin` — the real mechanism, not a role code
There is **no `firm_admin` role** in the seed data (`src/infrastructure/database/seeds/seed.ts` seeds only `admin` (SYSTEM scope), `lawyer`/`secretary`/`assistant`/`accountant`/`client` (TENANT scope)). The real mechanism: `Tenant.ownerUserId` (`src/modules/tenants/entities/tenant.entity.ts`) — a user is Firm Admin **iff** `tenant.ownerUserId == user.id`. `GET /tenants/my-firm` (`src/modules/tenants/controllers/tenants.controller.ts`) returns the raw entity (no DTO filtering), which does expose `ownerUserId`. **Fixed:** `MyFirm` entity + `IAuthRepository.getMyFirm()` added; `AuthBloc._resolveIsFirmAdmin()` calls it after login/session-restore and defers to `SessionCubit.authenticated(..., isFirmAdmin: ...)`. Defaults to `false` (secure direction) if the call fails for any reason.

### E. `CaseStatus` enum was incomplete
`src/modules/cases/entities/case.entity.ts` confirms the real enum is `DRAFT, ACTIVE, SUSPENDED, CLOSED, ARCHIVED` — the app's enum was missing `SUSPENDED`/`CLOSED` (only ever saw `DRAFT/ACTIVE/ARCHIVED` in Postman examples). Fixed in `case_status.dart` + `case_display_helpers.dart` + the `CasesPage` filter chips.

### F. Base URL confirmed
`Hoqooq-main/docker-compose.yml` maps host port `3005` → container `3000`; `src/main.ts` sets `app.setGlobalPrefix('api', { exclude: ['health'] })`. **Confirmed dev value:** `http://localhost:3005` (docker-compose), `/api` appended by `ApiConfig`.

### G. Pagination/filtering — no change, now confirmed from source rather than inferred
`cases.controller.ts` / `clients.controller.ts` have zero `@Query()` params on their list endpoints (`findAll(@CurrentUser() user)` only) — client-side filtering, already the app's implementation, is confirmed as the actual permanent backend design, not a stopgap awaiting a future server-side filter.

### H. Everything else already in this file — reconfirmed unchanged
`User`/`Role`/`Permission` shapes (`src/modules/users/dtos/user-response.dto.ts`), `Client` shape (`src/modules/clients/dtos/client-response.dto.ts`), login/refresh embedded `user` being a lighter shape than `/users/me` (`src/modules/identity/dtos/auth-response.dto.ts`), and the permission code format `<module>.<action>` (`src/core/constants/permissions.constant.ts`) all match this file's existing documentation exactly — no further changes needed there.

### I. M3 pre-planning: Hearings, Documents, Tasks, Calendar, Dashboard — source-verified contracts

Read directly from `Hoqooq-main/src/modules/{hearings,documents,tasks,calendar,dashboard,reports}/` ahead of drafting the M3 plan (M3 = finish the read-only workspace the spec originally expected M2 to cover). All five controllers require `@UseGuards(JwtAuthGuard, PermissionsGuard)` — nothing here is public. `PermissionsGuard` skips the permission check entirely for `admin`/`client` roles (`src/core/guards/permissions.guard.ts:26-29`) — worth knowing since it means those two roles bypass per-endpoint `@RequirePermissions` checks.

**Hearings** (`GET/POST /hearings`, `GET/PATCH/DELETE /hearings/{id}`, no `@Query()` params — same client-side-filtering pattern as Cases/Clients): response DTO (`hearing-response.dto.ts`) exposes `caseId`/`courtId`/`circuitId`/`hearingTypeId` as **IDs only**, but the service loads `relations: ['case', 'court']` — whether the wire response actually nests full objects or just IDs depends on whether a `ClassSerializerInterceptor` is globally applied (not found in this controller/module — verify empirically against a running instance before assuming either shape). Real `HearingStatus` enum (`entities/hearing.entity.ts`): `SCHEDULED, COMPLETED, ADJOURNED, CANCELLED` — gains `CANCELLED` versus what this file previously documented. **A second, unused `enums/hearing-status.enum.ts` file exists with `POSTPONED` instead of `ADJOURNED`/no `CANCELLED` — confirmed dead code (nothing imports it) — do not use it.** **DELETE is a hard delete** (`hearingRepository.remove()`, not `.softRemove()`) — see finding C's update above.

**Documents**: `POST /documents/upload` (multipart, file field name literally `file`, plus optional `caseId` — no `title`/`description`/`folderId`/`categoryId` settable on upload despite existing on the response shape), `GET /documents` (no `@Query()`), `DELETE /documents/{id}` (confirmed soft-delete, matches finding C). **No `PATCH /documents/{id}` endpoint exists at all.** **No `GET /documents/{id}` endpoint exists either** — `DocumentsService.findOne` exists but the controller never routes to it; a document detail view must come from the list response, not a dedicated fetch. **`GET /documents/{id}/download` does not return real file bytes or a presigned URL — it's a stub**: `DocumentsService.getDownloadUrl` returns `{ url: '/uploads/' + s3Key }` and the controller responds `{ message: 'File download simulated', url }` (`documents.controller.ts`, `documents.service.ts`). No document-versions-list endpoint despite a full `DocumentVersion` entity existing server-side (confirms the gap this file already flagged, now with the entity's existence confirmed too).

**Tasks**: `GET/POST /tasks`, `GET/PATCH/DELETE /tasks/{id}`, no `@Query()` params. Response DTO exposes `assignedToId`/`assignedById` as **IDs only** (same relations-vs-DTO caveat as Hearings — service loads full `assignedTo`/`assignedBy`/`case` relations). Real enums (`entities/task.entity.ts`): `TaskStatus = PENDING/IN_PROGRESS/COMPLETED/CANCELLED` (matches what this file already had), `TaskPriority = LOW/NORMAL/HIGH/URGENT` (confirms the previously-unconfirmed `URGENT` value). **Dead/unused `enums/task-status.enum.ts` (`TODO/IN_PROGRESS/DONE`) and `enums/task-priority.enum.ts` (uses `MEDIUM` instead of `NORMAL`) files exist — confirmed dead code, do not use.** **DELETE is a hard delete** (`taskRepository.remove()`) — same deviation as Hearings.

**Calendar**: `GET/POST /calendar`, `GET/PATCH/DELETE /calendar/{id}` (no `@Query()`), **plus `GET /calendar/timeline?startDate&endDate&caseId&userId` — this is the one list endpoint anywhere in the API with real server-side filtering.** Its response is *not* the regular `EventResponseDto` — it's an ad-hoc merged/sorted array from three sources (`CalendarService.getTimeline`, typed loosely as `any[]`): calendar events (`itemType: 'CALENDAR_EVENT'`, `referenceId` stays an **opaque, unresolved UUID** — the client must know from `eventType` what it points to and fetch it separately), hearings (`itemType: 'HEARING'`, **full `case` object embedded**, not just an ID), and tasks (`itemType: 'TASK'`, **full `case` object embedded**). **The `userId` filter only restricts calendar events — it is not applied to the tasks portion** (explicit comment in `calendar.service.ts` acknowledging this). Real `CalendarEventType` enum (`entities/calendar-event.entity.ts`): `HEARING, TASK_DEADLINE, CUSTOM` (matches what this file had). Regular (non-timeline) `GET /calendar`/`GET /calendar/{id}` DTO exposes `userId` as an ID only, despite the service loading a full `user` relation. **DELETE is confirmed soft** (`calendarEventRepository.softRemove()`), matching finding C.

**Dashboard — two endpoints serving two different personas, confirmed by the user (2026-07-30), not a bug.** `GET /dashboard` (`DashboardController`, `dashboard-summary.dto.ts`) returns `{totalCases, activeCases, pendingTasks, upcomingHearings, totalInvoices, unpaidInvoices, recentActivity[]}` — `DashboardService.getSummary(userId)` never uses the `userId` parameter it receives; every count is a global, unscoped `repository.count()` across all tenants (`dashboard.service.ts`). **This is intentional: `GET /dashboard` is the platform-wide view for the System/Super Admin who operates the whole system, not a per-tenant metric — it's out of scope for this mobile client entirely**, since this app only ever serves tenant-scoped actors (BR-037). The Reports module's `GET /reports/dashboard` (`dashboard-metrics.dto.ts`) returns a narrower `{totalActiveCases, pendingTasks, upcomingHearings}` shape and **is correctly user-scoped** — every query joins on `team.userId`/`assignedToId` to the current user. **This mobile app's Dashboard screen uses `GET /reports/dashboard` only, confirmed by the user — `GET /dashboard` is never called from this client.** `GET /reports/export/{cases,clients}` return raw CSV text (`Content-Type: text/csv`), unchanged, no query filters — out of scope for M3's JSON screens.

### J. M4 pre-planning: write-path verification (Create/Update/Delete, permissions, validation)

Read directly from `Hoqooq-main/` ahead of drafting M4 (writes). Findings below shape M4's scope — some are hard blockers for specific actions, most are not.

**Known issue, not a blocker (per user, 2026-07-30):** `ClientsService.findOne`/`.update`/`.remove` take only `id`, no `tenantId` — confirmed cross-tenant read/write/delete on a single client record by ID (contrast: every other module's `findOne` takes `(id, tenantId)` and queries `{id, tenantId}`). `ClientsController.create` also never overrides the request body's `tenantId` (unlike Cases, whose service does `{...dto, tenantId}` with the JWT-derived value spread *last*, silently discarding whatever the client sent). **Backend team is aware and will fix server-side — proceed with M4 Client writes without waiting on this.**

**Hard blocker for Case/Hearing CREATE specifically — no Lookup-listing endpoint exists, re-verified exhaustively 2026-07-30 immediately before M4 implementation.** `CreateCaseDto.caseTypeId` and `CreateHearingDto.hearingTypeId` are both required UUIDs (`@IsNotEmpty() @IsUUID()`), referencing the `Lookup` entity (`kind: CASE_TYPE|HEARING_TYPE|DOCUMENT_CATEGORY|EXPENSE_CATEGORY`, `src/modules/settings/entities/lookup.entity.ts`). Final verification pass, four independent angles, all confirming the same conclusion:
1. **Every `@Controller()` in the entire codebase enumerated** (`grep -rn "@Controller(" src/`) — 19 total (`ai`, `calendar`, `cases`, `clients`, `courts`, `dashboard`, `documents`, `finance`, `hearings`, `auth` (identity), `notifications`, `opponents`, `reports`, `settings`, `tasks`, `public/lawyers`, `tenants`, `employees`, `roles`). None named or routed for lookups/case-types/hearing-types.
2. **Every reference to `Lookup` anywhere in `src/` traced individually** — all are either `@ManyToOne(() => Lookup)` relation declarations on `Case`/`Hearing`/`Document`/`Expense` entities (read-only nested data, never a queryable collection) or `case-response.dto.ts`'s `LookupResponseDto` (a nested-shape declaration, not a route). `SettingsModule` registers `Lookup` in `TypeOrmModule.forFeature([Setting, Lookup])` purely so the ORM can resolve those relations — no service or controller in the module ever injects a `Lookup` repository or exposes it over HTTP; `SettingsController`'s five routes all operate on the unrelated `Setting` key-value entity.
3. **`RolesController` (`GET /roles`, `GET /roles/permissions`) — the other previously-"undocumented" endpoint pair — read in full and confirmed to be exactly what it says**: role list (`{id, code, scope}`, excluding `SYSTEM_ADMIN`/`CLIENT`) and permission list (`{id, code}`). Not a disguised lookups endpoint.
4. **Regex swept every controller's route-path strings for `type`/`categor`/`lookup`** (`grep -rniE "@(Get|Post|Patch|Delete)\(['"]... (type|categor|lookup)"`) — zero matches anywhere.

**No controller anywhere exposes `Lookup` rows.** A Create-Case or Create-Hearing form has no way to populate a valid Case Type / Hearing Type dropdown — the only values ever observed are whatever a specific existing case/hearing happens to nest, which isn't a real listing and would miss any type with zero current records. **This makes Case and Hearing creation impossible to build without guessing a UUID.** Per explicit instruction: do not hardcode UUIDs, embed seed values, or invent a client-side lookup list to work around this — **Case and Hearing creation stay deferred out of M4**, to revisit only once a real lookup-listing endpoint exists. Case/Hearing *Update* has no such blocker as long as `caseTypeId`/`hearingTypeId` are left immutable in the edit form (redisplay the existing value read-only; every other field on both is either free-form or references a real, browsable endpoint — see below).

**Soft blocker: `CourtCircuit` has no controller either** (`circuitId` on Hearing) — but it's optional on both create and update, so this just means the field stays unset/unchanged in M4's Hearing form, not a blocker to Hearing Update itself.

**Real, browsable reference data confirmed available for M4's pickers:** `GET /courts` (full CRUD controller, usable for `defaultCourtId`/Hearing `courtId`) and `GET /users` (confirmed since M1, usable for `primaryLawyerId`/`assignedToId`/`assignedById` pickers — Tasks/Cases assignee selection has no lookup problem, since `User` is a real entity with a real list endpoint, not a `Lookup` row).

**Client, Task, Document-upload, and Calendar-custom-event creation have zero Lookup dependency** — confirmed field-by-field against `CreateClientDto`/`CreateTaskDto`/the upload handler's two accepted fields/`CreateEventDto`. All four are fully buildable for both create and update (documents excepted — see finding I, no update/detail endpoint exists for documents at all).

**⚠️ Seed data only grants permissions to the `admin` role — worth confirming with the backend team before relying on permission-gated writes in a real environment.** `src/infrastructure/database/seeds/seed.ts` is the only file anywhere that creates `RolePermission` rows, and it only does so for `adminRole`; `lawyer`/`secretary`/`assistant`/`accountant` roles are created but never granted any permission. Combined with `PermissionsGuard`'s bypass (`admin`/`client` roles skip the permission check entirely — finding I doesn't cover this, see `permissions.guard.ts`), this means **as currently seeded, a `lawyer`/`secretary`/`assistant`/`accountant`-role user cannot pass any `@RequirePermissions(...)` check on any endpoint**, read or write — not a client-side bug, and not something M4's code needs to work around structurally (the repository/bloc code is correct regardless of what permissions a real user ends up with), but a real gap in the seed/demo environment worth flagging before assuming a non-admin test login can exercise M4's write screens end-to-end.

**Validation/error-shape confirmation for write UX:** `ValidationPipe` is `{whitelist: true, forbidNonWhitelisted: true, transform: true}` — any request-body key not declared on the DTO 400s the *entire* request, not just gets stripped. `HttpExceptionFilter` collapses `class-validator`'s array of per-field messages to `message[0]` only — a form with multiple invalid fields will only ever surface one error per submit round-trip.

**DELETE status-code inconsistency (relevant if M4 or a later milestone wires deletes):** only `ClientsController.remove` has an explicit `@HttpCode(204)`; Cases/Hearings/Documents/Tasks/Finance all document `@ApiResponse({status:204})` (Swagger-only) with no `@HttpCode`, so their real default response status is **200**, not 204. Calendar's delete documents 200 directly. Any delete-repository method should treat any 2xx as success rather than branching on the exact code.

---

## ⚠️ Findings from the second backend-source re-sync (2026-08-05) — supersedes findings A–J where noted

The backend team completed a further round of fixes after M4. Per explicit instruction, this pass treated the current backend source as the only source of truth and re-verified every finding above from scratch rather than assuming any of them still held. Confirmed directly from `Hoqooq-main/src/`.

### K. Lookup-listing endpoint now exists — resolves finding J's Case/Hearing-creation blocker
`GET /lookups?kind=CASE_TYPE|HEARING_TYPE|DOCUMENT_CATEGORY|EXPENSE_CATEGORY` (`src/modules/settings/controllers/lookups.controller.ts`), guarded `JwtAuthGuard`+`PermissionsGuard`, requires `lookups.read`. Tenant-scoped (`Lookup.tenantId` is a required column; the service always filters by `user.tenantId`). Response is the raw `Lookup` entity array (no `plainToInstance`): `{id, tenantId, kind, labelEn, labelAr, isActive, createdAt, updatedAt, archivedAt, isArchived}`. A separate `GET /lookups/enums` returns a static dictionary of backend enums (`CaseStatus`, `CasePriority`, `TaskStatus`, `TaskPriority`, `HearingStatus`, `InvoiceStatus`) — informational only, not needed since this app already hand-models these from entity source. **`CreateCaseDto.caseTypeId` and `CreateHearingDto.hearingTypeId` can now be populated from a real, listable source.** Case and Hearing creation are no longer blocked. **Fixed:** new `lookups` feature module (`ILookupRepository`), used by `CaseFormBloc`/`HearingFormBloc`'s reference-data loading for both the create-mode type picker and the (previously always-"Unknown") edit-mode type label.

### L. Firm Admin mechanism replaced — `ownerUserId` is no longer authoritative
Confirmed by the backend team directly, and independently verified by reading every server-side "is this user a firm admin" check in the current source (`cases.service.ts`, `hearings.service.ts`, `tasks.service.ts`, `documents.service.ts`, `dashboard.service.ts`): all of them now check `roles.includes('FIRM_ADMIN') || user.isSuperAdmin`, a real role code — not `Tenant.ownerUserId`. `FIRM_ADMIN` now exists as a real seeded role (`src/infrastructure/database/seeds/seed.ts`) and is granted every non-`system.*` permission. **This finding supersedes finding D outright — the `ownerUserId` mechanism this app has used since M2 is no longer what the backend itself uses to decide Firm Admin status, and should not be relied on going forward.** `Tenant.ownerUserId` still exists as a column but is not what any authorization check in the backend reads. **Fixed:** `isFirmAdmin` is now a `User` getter (`roles.any((r) => r.code == 'FIRM_ADMIN')`), computed synchronously from the already-fetched `/users/me` response — no separate network call needed. `MyFirm`/`IAuthRepository.getMyFirm()`/`GET /tenants/my-firm` call removed from the app entirely; nothing else used that endpoint.

### M. `SubscriptionGuard` — confirmed intentional, not a bug
`src/core/guards/subscription.guard.ts`, a global `APP_GUARD` (`core.module.ts`), runs on every authenticated request except paths containing `/api/subscriptions`. Blocks with **402 Payment Required** — reads included, not just writes — whenever the tenant has no `Subscription` row, or `status !== 'ACTIVE'`, or `currentPeriodEnd` has passed. Exact messages returned (all via the standard error envelope, `message` field): `"No active subscription found. Please contact support."` / `"Your subscription has expired. Please update your billing details."` / `"Your subscription is inactive or has expired. Please update your billing details."`. Confirmed by the backend team as intentional application behavior, not a bug to work around. `POST /subscriptions/activate` (bearer-only, defaults to the caller's own `tenantId`) does a no-real-payment "simulate successful payment" reactivation — **but only if a `Subscription` row already exists**; it 404s for a tenant with none at all (only reachable via a pre-`/auth/signup` account, e.g. the seeded super-admin, which has no `tenantId` and is exempt from the guard entirely). **Fixed:** `SubscriptionInactiveFailure` added to `mapDioError()` for 402; `SessionCubit` gains a subscription-inactive state; a dedicated blocking screen intercepts navigation app-wide, with a self-service "Reactivate" action shown to `FIRM_ADMIN` users only (confirmed with the user 2026-08-05 — other roles see an explanatory message, no reactivate action, since billing self-service for non-admin staff wasn't part of the ask).

### N. `Case.primaryLawyer`/`primaryLawyerId` removed from the schema entirely — not merely unloaded
Previously (finding from the M3 pre-planning re-verification) these were nullable because `CasesService` never loaded the relation. **They no longer exist on the `Case` entity at all** (confirmed by reading `case.entity.ts` directly) — the "primary lawyer" concept has been replaced by `team[]`/`CaseTeam`, now manageable through a real endpoint (`POST /cases/:id/assignments`, see finding P below). `CreateCaseDto`/`UpdateCaseDto` no longer accept `primaryLawyerId` either. **Fixed:** `LegalCase.primaryLawyer`/`primaryLawyerId` deleted from the Dart model (not kept nullable); `CaseFormPage`'s primary-lawyer picker removed; `case_details_page.dart`'s team rendering now relies solely on `team[]`.

### O. `CaseTeam`'s real field is `accessLevel`, not `roleOnCase` — and `team.user` is now reliably joined
`CaseTeam.accessLevel: CaseAccessLevel` (`FULL_ACCESS|READ_ONLY|UPLOAD_DOCUMENTS|ASSIGN_HEARING`) is the real column. `roleOnCase` only exists as a backward-compatibility **type alias for the enum type**, not a property name (`export const RoleOnCase = CaseAccessLevel`) — it never appears as a JSON key. Separately, `CasesService` was rewritten from a `relations:[...]` array to a query builder that explicitly joins `team.user` (`.leftJoinAndSelect('team.user', 'teamUser')`) — previously never loaded, now reliably populated. **Fixed:** `CaseTeamMember.roleOnCase` renamed to `accessLevel`, modeled as a real `CaseAccessLevel` enum instead of a free display string; `user` stays nullable defensively (a deleted user is still theoretically possible) but is no longer expected to be routinely absent.

### P. `POST /cases/:id/assignments` and `POST /cases/:id/notes` are back — a previously-flagged regression is resolved
Both endpoints (removed in the pre-M2 backend update, flagged as a regression at the time — no way to add a case-team member or a note existed) are real again. `AssignCaseDto = {userId, accessLevel, role?}` (`role` is a legacy alias, prefer `accessLevel`), returns the raw `CaseTeam` row. `CreateCaseNoteDto = {content}`, returns the raw `CaseNote` row. **Caveat, not yet fixed:** `caseNotes` is not joined into `GET /cases/:id` (`cases.service.ts`'s query builder doesn't include it) — a note can be added but not read back from the case-detail response. **Not built this pass**: a Notes UI would be write-only as things stand, which isn't worth shipping; flagged as a follow-up once the read side exists. Team-assignment UI **was** worth building since `team[]` is already returned in full on every case fetch.

### Q. Still Open — re-confirmed unchanged in this pass
- **Hearings/Tasks hard-delete** (`hearingRepository.remove()`/`taskRepository.remove()`, not soft) — unchanged. Irrelevant while delete stays deferred.
- **Clients `create` still accepts a client-supplied `tenantId` unchecked** (`ClientsService.create` doesn't override it, unlike Cases/Hearings) — `findOne`/`update`/`remove` were fixed to be tenant-scoped in the prior pass; `create` was not. No Flutter action needed (Flutter already sources `tenantId` correctly at the repository layer); re-flagged to the backend team.
- **DELETE status-code inconsistency** (only Clients has real `@HttpCode(204)`) — unchanged.
- **`ValidationPipe`/`HttpExceptionFilter` message-collapsing** (`message[0]` only, multi-field forms surface one error per submit) — unchanged.
- **Duplicate `EmployeesController` route collision** — new finding, not previously documented: both `UsersModule` and `EmployeesModule` register a controller at `@Controller('employees')`; `UsersModule` is imported first in `app.module.ts`, so its thin `User`-backed controller silently wins `GET/PATCH/DELETE /employees/:id`, and the real `Employee`-profile-backed controller only has `POST /employees/onboard` and the `:id/permissions` routes reachable. Not a Flutter concern (this app doesn't use the Employees module — BRD staff-management flag remains out of scope), flagged for the backend team.
- **Document upload still has no `categoryId` field**, despite `Lookup` now supporting a `DOCUMENT_CATEGORY` kind — `POST /documents/upload` still only accepts `file`+`caseId`.
- **`plainToInstance`/DTO enforcement expanded** (now also applied to Opponents, Users, Courts, Notifications, both Employees controllers) but **Cases, Hearings, Tasks, Calendar are still raw-entity, unenforced** — the reasoning behind building those four modules' Flutter models off each service's `relations`/query-builder joins (not the documented DTO) still applies.
- **Pagination** — still absent on every list endpoint except `GET /calendar/timeline`, re-checked across every module.
- **Response envelope / error shape** — unchanged, confirmed byte-for-byte.

---

## ⚠️ Findings from the third backend-source re-sync (2026-08-06) — M6 pre-planning

User asked for a fresh re-inspection of the backend source before drafting M6, specifically to find backend-supported features not yet built in Flutter, prioritized over inventing new ones. This pass went deeper than any prior one into modules that were previously only enumerated by controller name (Finance, Notifications, Opponents, AI, Tenants) but never read in full. Confirmed directly from `Hoqooq-main/src/`.

### R. Finance module (Invoices + Payments) — real, rich, and fully buildable; corrects a wrong claim in §12 below

Never previously read past the Postman-collection-derived summary in §12. Real endpoints, all guarded `JwtAuthGuard`+`PermissionsGuard`, `finance.{create,read,update,delete}`:
- `GET /finance/analytics` — firm-wide `{totalInvoiced, totalPaid, totalOutstanding, collectionRatePercentage, totalInvoicesCount, paidInvoicesCount, partialInvoicesCount, unpaidInvoicesCount, grossRevenue, netProfitEstimate}`. Hand-built plain object (not a raw entity) — this response shape **is** reliable.
- `GET /finance/cases-summary` — per-case array `{caseId, caseNumber, clientName, totalInvoiced, totalPaid, outstandingBalance, paymentStatus: 'PAID'|'PARTIAL'|'UNPAID'|'NO_INVOICE', invoicesCount}` for every case in the tenant. Also hand-built, reliable.
- `GET /finance/cases/:caseId/summary` — same shape as above for one case, plus a nested `invoices: Invoice[]` (raw entities, see below).
- `POST/GET /finance/invoices`, `GET/PATCH/DELETE /finance/invoices/:id`.
- `POST/GET /finance/payments`, `GET/DELETE /finance/payments/:id` (**no PATCH for payments** — a payment can be created or deleted, never edited).

**⚠️ `FinanceController` never calls `plainToInstance` anywhere — same "DTO documented, never enforced" pattern as Cases/Hearings/Tasks/Calendar (see the correction in §8 below).** The real `Invoice`/`Payment` wire shape is governed by `FinanceService`'s query relations, not `InvoiceResponseDto`/`PaymentResponseDto`:
- `findAllInvoices` → `relations: ['client', 'case', 'payments']` — **no `lineItems`**.
- `findOneInvoice` → `relations: ['client', 'case', 'payments', 'lineItems']` — list and detail have different shapes, same "list is thinner than detail" pattern as elsewhere in this API.
- `findAllPayments`/`findOnePayment` → `relations: ['invoice']`.
- `case`/`client` are full nested entities (not thin summaries) — build the Flutter model with a reused thin `CaseSummary` reference for `case`, same pattern as Hearings/Tasks/Documents, to avoid unbounded nesting.

**⚠️ Corrects §12 below: DELETE on Invoices and Payments is a HARD delete, not soft — the opposite of what this file previously claimed.** `FinanceService.removeInvoice`/`.removePayment` both call `.remove()`, not `.softRemove()` (`finance.service.ts` lines 72, 140), despite `Invoice`/`Payment` extending `AuditableEntity`/`BaseEntity` with the same soft-delete columns every other confirmed-soft module has. The earlier "DELETE on both invoices and payments is confirmed soft-delete... does not contradict BR-028/BR-029" line in §12 was never actually verified against Finance source — it was an extrapolation from finding C's general pattern, and finding C's own caveat (Hearings/Tasks hard-delete despite having the columns) already warned against exactly this kind of unverified generalization. **This one matters more than Hearings/Tasks hard-delete does — BR-028/BR-029 explicitly name financial records.** No Flutter delete UI exists for Finance yet (nothing to fix retroactively), but this is a hard blocker on ever wiring one without a business-rule conversation first — same "don't wire a destructive UI action without asking" standing instruction that already applies to Hearings/Tasks.

**Real, backend-confirmed inconsistency, not a Flutter bug to work around:** `CreatePaymentDto.method` is validated against `PaymentMethod` imported from `enums/payment-method.enum.ts` (`CASH|BANK_TRANSFER|CHEQUE|ONLINE`), but the `Payment` entity's TypeORM column type is a **different, inline-declared** `PaymentMethod` enum in `payment.entity.ts` (`CASH|BANK_TRANSFER|CREDIT_CARD|CHECK`) — same name, different values, two separate declarations. `FinanceService.createPayment` does a raw SQL insert coalescing `(createPaymentDto as any).paymentMethod || createPaymentDto.method`, suggesting the backend team is already aware of some mismatch here. **The DTO's enum is what class-validator actually enforces on write** (`CASH|BANK_TRANSFER|CHEQUE|ONLINE`) — that's the value set the Flutter app should send; whether the DB-level enum type actually accepts `CHEQUE`/`ONLINE` at the Postgres layer is unverifiable from source alone and worth flagging to the backend team before relying on it in a real environment.

`createPayment` auto-transitions the invoice's `status` to `PARTIAL`/`PAID` based on cumulative payments against `grandTotal` — the invoice itself isn't re-fetched by this call, so the Flutter app must explicitly refetch the invoice after a payment write to see the new status (same explicit-refetch convention as every other write path in this app).

No line-items CRUD exists despite `InvoiceLineItem` entity/relation existing (confirms the pre-existing gap) — `subtotal`/`taxTotal`/`grandTotal` stay flat, client-computed numbers on create/update, not derived from itemized lines.

### S. Notifications — real, simple, DTO-enforced, no blockers

Never previously read past "unchanged" in §4 below. `NotificationsController` **does** call `plainToInstance(..., {excludeExtraneousValues: true})` on both routes — this one's DTO **is** reliably enforced:
- `GET /notifications/me` — returns **only unread** notifications (`NotificationsService.getUserNotifications` filters `isRead: false` server-side) for the current user, sorted `createdAt DESC`. No pagination, no way to see read history — once marked read, a notification effectively disappears from this endpoint.
- `PATCH /notifications/{id}/read` — ownership-checked (404 if the notification isn't the caller's own), marks `isRead: true`, returns the updated notification.
- **`NotificationResponseDto`** = `{id, userId, title, message, isRead, type, createdAt}`. Real `NotificationType` enum (`enums/notification-type.enum.ts`): `HEARING_REMINDER|TASK_ASSIGNED|INVOICE_DUE|SYSTEM_ALERT`.
- No permission gating beyond `JwtAuthGuard` — any authenticated user reads/marks only their own notifications, no `@RequirePermissions` involved (the `notifications.read` permission code exists in `permissions.constant.ts` but this controller never checks it — dead code on the permission side, not a blocker).
- No creation endpoint — notifications are server-internal only (`NotificationsService.create`, called from elsewhere in the backend / a queue processor), nothing for the client to `POST`.

### T. Opponents — real, DTO-enforced CRUD, but structurally NOT linkable to a case

Never previously read past "minor shape change" in §6 below. Full CRUD (`opponents.create/read/update/delete`), tenant-scoped, `plainToInstance`-enforced throughout — reliable. `Opponent` = `{id, type: INDIVIDUAL|COMPANY|GOVERNMENT, name, phone?, address?, createdAt, updatedAt}`.

**No `caseId` column exists on `Opponent` at all** — it's a flat, tenant-wide directory entity, structurally identical in spirit to Clients/Courts (a standalone reference list), not a per-case sub-resource. A `CaseOpponent` join entity (`case_opponents` table: `caseId`, `opponentId`, optional `relationship` string) does exist, and `case.opponents` **is** joined into every `GET /cases`/`GET /cases/{id}` response (`cases.service.ts`'s query builder explicitly does `.leftJoinAndSelect('case.opponents', 'opponents')`) — but **no controller or route anywhere creates, reads, or deletes a `CaseOpponent` row.** The join table exists in the schema with zero HTTP surface to populate it. **Practical consequence: `case.opponents` will always deserialize as an empty array in a real response, and a "link this opponent to this case" UI is not buildable — only a standalone, flat Opponents directory (list/create/edit/delete, same shape as the existing Clients/Courts screens) is.**

### U. Courts — full CRUD now exists; the app only ever built the read side

`CourtsController` has real `POST`/`PATCH`/`DELETE` routes (`courts.create/update/delete` permissions) alongside the `GET` this app already uses as Case/Hearing picker reference data — `plainToInstance`-enforced, DELETE confirmed soft (`.softRemove()`, matches finding C, consistent with BR-021 "deactivate, don't delete"). Court management itself (as opposed to just reading courts for a dropdown) was never built as a first-class Flutter feature — same CRUD shape as Clients, no blockers.

### V. Case `opponents[]`/`timelineEvents[]` — confirmed always-empty, not partially-populated

Re-confirmed directly from `cases.service.ts`'s query builder: both `case.opponents` and `case.timelineEvents` are joined into every case fetch (`.leftJoinAndSelect('case.opponents', 'opponents')` / `.leftJoinAndSelect('case.timelineEvents', 'timelineEvents')`), but grepping the entire `CasesService` for any write to either repository turns up nothing — no code path anywhere creates a `CaseTimelineEvent` or (per finding T) a `CaseOpponent` row. Both fields will reliably deserialize as `[]` in a real response. This isn't new information about BR-017 (still no case-timeline endpoint, unchanged), but it does confirm neither field is silently half-working — they're both fully inert, not worth modeling in `LegalCase` until (if ever) a write path for either appears.

### W. Tenants / Firm Profile (`GET/PATCH /tenants/my-firm`, `POST /tenants/my-firm/logo`) — real and buildable, one DTO/entity mismatch to flag

`GET /tenants/my-firm` (any authenticated tenant user, no permission gate beyond having a `tenantId` at all) returns the raw `Tenant` entity: `{id, name, logoUrl, address, contactEmail, ownerUserId, defaultLanguage: EN|AR, currency, timezone, status: ACTIVE|SUSPENDED|CANCELLED, subscription, createdAt, updatedAt}`. `PATCH /tenants/my-firm` (requires `settings.update`) and `POST /tenants/my-firm/logo` (multipart, field name `logo`, same permission) are real, working write paths.

**⚠️ `UpdateTenantDto`'s fields don't all map to real `Tenant` columns — a backend inconsistency worth confirming before building an edit form around it.** The DTO accepts `{name?, address?, publicContactEmail?, publicContactPhone?, website?, specializations?[]}`, but the `Tenant` entity only has columns for `name`, `address`, and `contactEmail` (not `publicContactEmail` — different name) — there is **no** `publicContactPhone`, `website`, or `specializations` column on `Tenant` at all. This DTO looks copy-pasted from a different (marketplace-facing lawyer-profile?) concept than the actual `Tenant` entity. Sending `publicContactPhone`/`website`/`specializations` will pass validation (the DTO declares them) but has no column to persist into — TypeORM's `merge()` will silently drop unknown-to-the-entity fields. **Only `name`/`address` are safe to build an edit form around with confidence; `contactEmail` may or may not be reachable at all given the DTO's field is named `publicContactEmail` not `contactEmail`** — flag to the backend team, don't guess which one actually persists.

`BookMeetingDto` exists (`dtos/book-meeting.dto.ts`) and is referenced in `tenants.service.ts`, but is never wired to any controller route — dead/unused, consistent with the marketplace/consultations concept staying out of scope.

### X. AI module — confirmed a non-functional stub, not a real feature yet

`AiController`'s three endpoints (`POST /ai/summarize`, `/ai/research`, `/ai/chat`) each return a hardcoded `{status: 'success', feature: '...', message: 'AI Module is ready to be implemented.'}` regardless of request body — no real AI integration, no RAG, no entitlement check exists behind these routes yet. Confirms and sharpens the existing "no AI entitlement/credit-preflight endpoint" gap: it's not just missing a preflight check, the feature itself doesn't do anything real yet. Not a buildable feature for any milestone until the backend actually implements it — BR-030/BR-032 stay unaddressable.

### Y. `PermissionsGuard` was rewritten — supersedes finding I's "admin/client bypass entirely" claim

`src/core/guards/permissions.guard.ts` is a different, more granular implementation than what finding I described. Re-read in full:
- `SUPER_ADMIN` (or `isSuperAdmin`) bypasses only for `system.*` permissions plus a specific whitelist (`employees.read`, `lookups.read`, `settings.read`, `roles.read`, `users.read`, `users.create`, `users.delete`) — **not** a blanket bypass anymore.
- `FIRM_ADMIN` bypasses every non-`system.*` check — confirms BR-005's full-CRUD requirement is backend-enforced, not just a Flutter-side assumption.
- `ACCOUNTANT` bypasses only when every required permission is `finance.*`, `reports.read`, `dashboard.read`, or `lookups.read` — a real, working "accountant persona" the backend now supports end-to-end.
- **`CLIENT` role bypasses every non-`system.*` check too, same as Firm Admin** — flagged as a notable backend RBAC looseness (a client-role user would pass any permission check for any tenant-scoped action), but **not a Flutter action item**: this app never authenticates a CLIENT-role user (BR-001 keeps public self-signup/client login out of this app's scope), so there's no code path in this client that could exercise it.
- Everyone else (`LAWYER`/`SECRETARY`/`ASSISTANT`) falls through to explicit `user.permissions.includes(...)` matching — same as before.

**Seed data now grants real permissions to `FIRM_ADMIN` (every non-`system.*` permission) and `ACCOUNTANT` (`finance.*`, `reports.read`, `dashboard.read`, `lookups.read`)** — resolves the M4-era finding that only `admin` had any permissions seeded at all. **`LAWYER`/`SECRETARY`/`ASSISTANT` still have zero permissions granted in seed data** — those three roles still can't pass any explicit `@RequirePermissions` check against a freshly-seeded environment (same underlying gap as before, narrower now that two of five non-admin roles are fixed). Practical implication for testing: an `ACCOUNTANT`-role seeded login is now a real, viable way to exercise Finance (and M5.5's RBAC gating generally) end-to-end against a live backend; a `LAWYER`-role login still can't exercise most permission-gated write actions server-side, independent of whether the Flutter-side gating is correct.

---

## ⚠️ Breaking changes since the M1 version of this file (2026-07-30, same day)

This is not a re-randomization of examples — the collection went from 97 requests to 87, gained a global `/api` prefix, and several core entities were structurally rebuilt to match the BRD's actual data dictionary far more closely. Full diff method available: old export preserved as `/tmp/postman_full.json` from the M1 session, new one at `/tmp/postman_full_v2.json` (both outside the repo).

### 1. Every path now has an `/api` prefix
Old: `POST /auth/login`. New: `POST /api/auth/login`. This applies to **all 87 endpoints, no exceptions**. `ApiConfig.baseUrl` (or every call site) needs this prefix added — nothing in M1's shipped code has it yet.

### 2. `GET /users/me`, `/users`, `/users/{id}` — User shape rebuilt (breaks M1's `User`/`Role`/`Permission` entities)
| Field | M1 version | Current version |
|---|---|---|
| Name | `firstName` + `lastName` (both required) | Single `fullName` string |
| Active flag | `isActive: boolean` | `status: string` (enum-shaped, matches BRD's `INVITED/ACTIVE/SUSPENDED/DEACTIVATED`) |
| New fields | — | `isSuperAdmin: boolean`, `mfaEnabled: boolean` |
| `roles[]` shape | `{id, name, displayNameEn, displayNameAr, permissions[]}` | `{id, code, scope, permissions[]}` — **no more `name`/`displayNameEn`/`displayNameAr`** |
| `permissions[]` shape | `{id, resource, action, displayNameEn, displayNameAr}` | `{id, code}` — **no more `resource`/`action` split, no more display names** |

**Impact:** `lib/features/authentication/domain/entities/user.dart`'s `fromJson` will throw immediately on a real response — `firstName`/`lastName`/`isActive` are marked `required` and no longer exist. `User.fullName` (the computed getter) is now redundant since the API provides it directly. `User.hasPerm(resource, action)` no longer has a `resource`/`action` pair to check against — permissions are now a single `code` string, so the method signature itself needs to change to `hasPerm(String permissionCode)`. This also **resolves** the "how would `isFirmAdmin` ever be detected" open question differently than expected: `role.code` (e.g. plausibly `"FIRM_ADMIN"`) is a much more promising signal than the old `role.name`/`displayNameEn` fields were, though still no example shows a real value — `<string>` placeholders throughout, same caveat as before.

Auth endpoints themselves (`login`, `signup`, `refresh`, `logout`, `forgot-password`, `reset-password`, `change-password`) are **byte-for-byte unchanged** except for the `/api` prefix — confirmed by diffing every field. M1's `AuthRepository`/`AuthBloc`/token logic does not need to change beyond the base URL.

### 3. `GET/POST/PATCH /cases`, `GET /cases/{id}` — Case shape completely rebuilt
| | M1/previous version | Current version |
|---|---|---|
| Removed fields | `title`, `description`, `type`, `courtId`, `court{}`, `assignments[]`, `notes[]` | — |
| Added fields | — | `tenantId`, `caseTypeId` + `caseType{id,name}` (lookup-based, replaces free-text `type`), `primaryLawyerId` + `primaryLawyer{User}` (singular, replaces `assignments[]`), `defaultCourtId` + `defaultCourt{Court}` (renamed from `courtId`/`court`), `openingDate`, `closingDate`, `outcomeSummary`, `agreedFee`, `priority`, `team[]` (replaces `assignments[]`, shape now `{id, role, user: {User}}` instead of `{id, role, employee: {Employee}}`) |
| `POST /cases/{id}/assignments` | existed | **endpoint removed entirely** |
| `POST /cases/{id}/notes` | existed | **endpoint removed entirely** — no note-adding capability exists anywhere now, and `notes[]` is gone from the response too |

This is now dramatically closer to BRD §8.4 `cases` (agreed_fee, priority, opening/closing dates, primary_lawyer_id, case_type_id as a lookup) than the old version was. **Any M2 planning built against the old Case shape (title/description/assignments/notes) is void.**

### 4. `GET/POST/PATCH /clients`, `GET /clients/{id}` — Client shape completely rebuilt
| | Previous version | Current version |
|---|---|---|
| Removed | `name`, `email`, `phone`, `address`, `taxId` (all singular) | — |
| Added | — | `tenantId`, `clientCode`, `fullName`, `status`, `nationalId`, `commercialReg`, `emails[]`, `phones[]`, `addresses[]` (all arrays now) |

Now matches BRD §8.3 `clients` almost exactly (client_code, national_id/commercial_reg, multi-value contact arrays, status enum). **Any M2 planning built against the old Client shape is void.**

### 5. Modules removed entirely
- **`employees`** (5 endpoints: onboard, list, get, update, delete) — the whole staff-management surface is gone. BRD §6.2.3 Staff Management now has **zero backing** in this API (previously it existed, just with the wrong role/department taxonomy — now there's nothing at all).
- **`reviews`** (2 endpoints) and **`consultations`** (1 endpoint) — the public lawyer-marketplace/review/booking surface flagged as a BR-violation in the M1 version of this file is now **gone**. This resolves that concern; no action needed.
- Net: 10 endpoints removed, 0 added, 87 remain.

### 6. Other structural changes worth knowing before touching a given module
- **Opponents**: lost `email` and `notes` fields; now just `{type, name, phone, address}`.
- **Courts**: `location`/`contactInfo` renamed to `city`/`address`; gained `isActive`.
- **Tasks**: gained `assignedById` (alongside `assignedToId`); `status` enum changed from `TODO/IN_PROGRESS/DONE` to `PENDING/IN_PROGRESS/COMPLETED/CANCELLED`; gained `completedAt`.
- **Documents**: `name` renamed to `title`; gained `fileType` (renamed from `contentType`), `sizeBytes` (renamed from `size`), `uploadedById`, `versionNumber`, `folderId`, `categoryId`. Still no `GET .../versions` endpoint — `versionNumber` is a counter, not a browsable history.
- **Hearings**: gained `hearingTypeId`, `circuitId`, `judgeName`, `outcomeText`, `nextHearingAt`; `status` enum is now `SCHEDULED/COMPLETED/ADJOURNED` (matches BRD, no more `POSTPONED`).
- **Calendar events**: `date`+`time`(string) replaced by proper `startsAt`/`endsAt` datetimes; gained `eventType: CUSTOM|TASK_DEADLINE|...`, `referenceId` (generic link, likely to case/hearing/task), `location`, `isAllDay`, `tenantId`.
- **Invoices**: flat `amount` replaced by `subtotal`/`taxTotal`/`grandTotal`; gained proper `invoiceNumber`; `status` gained `PARTIAL`.
- Still **no error-envelope example anywhere** — every 4xx/5xx response in all 87 requests has an empty body, same gap as before, not newly discovered.
- Still **no subscription/billing surface, no MFA endpoint, no case-timeline endpoint, no document-versions-list endpoint** — all gaps flagged in the M1 version of this file persist unchanged.
- `POST/PATCH /users`, `POST/PATCH /cases` **still accept a client-supplied `tenantId`** in the request body — the BR-003 concern flagged in M1 is unchanged and has spread to `/cases` too now.
- Collection description changed from "Multi-Tenant SaaS Legal Practice Management System" to "Legal Practice Management System" — cosmetic, but noting it since "Multi-Tenant SaaS" was dropped from the wording.

---

## Base URL & auth (unchanged mechanics, changed path)

**Base URL:** collection variable `baseUrl = "/"` — still a placeholder, still no real dev/staging/prod host. **All paths below already include the `/api` prefix** — `ApiConfig.baseUrl` should point at the host only (e.g. `http://localhost:3000`), with `/api` prepended to every path, OR `/api` gets folded into the base URL itself (e.g. `http://localhost:3000/api`) — implementation detail to settle before any M2 code, not decided here.

**Auth scheme:** unchanged — `Authorization: Bearer <token>` on all but `login`/`signup`/`refresh`/`forgot-password`/`reset-password`/`settings/public`. (Note: `GET /api/reviews/lawyer/{lawyerId}` no longer exists since `reviews` was removed — the no-auth-required list shrank by one for that reason alone.)

**Naming convention:** still camelCase throughout.

---

## 1. Auth — unchanged from M1 except path prefix

| Method | Path | Auth | Notes |
|---|---|---|---|
| POST | `/api/auth/login` | none | `{email, password}` → `{accessToken, refreshToken, user: {}}`. Byte-identical to M1 version. |
| POST | `/api/auth/signup` | none | Still exists, still contradicts BR-001. `{email, password, firstName, lastName, userType, firmName}` — note this request still uses `firstName`/`lastName` even though the `User` model itself moved to a single `fullName`; not reconciled in this collection. |
| POST | `/api/auth/refresh` | none | `{refreshToken}` → `{accessToken, refreshToken, user: {}}`. |
| POST | `/api/auth/logout` | bearer | `{refreshToken}` → 204. |
| POST | `/api/auth/forgot-password` | none | `{email}` → 200. |
| POST | `/api/auth/reset-password` | none | `{token, newPassword}` → 204. |
| POST | `/api/auth/change-password` | bearer | `{oldPassword, newPassword}` → 204. |

Still missing: `/auth/mfa/verify`, `/auth/activate`. Still no device/FCM registration endpoint.

## 2. Users / Roles / Permissions — shape rebuilt (see breaking change #2)

| Method | Path | Request | Response |
|---|---|---|---|
| POST | `/api/users` | `{email, password, fullName, avatarUrl?, isSuperAdmin?, tenantId, roleIds[]}` | 201 User |
| GET | `/api/users` | — | 200 User[] |
| GET | `/api/users/me` | — | 200 User |
| GET | `/api/users/{id}` | — | 200 User |
| PATCH | `/api/users/{id}` | `{email?, fullName?, avatarUrl?, isSuperAdmin?, tenantId?, roleIds[]?}` | 200 User |
| DELETE | `/api/users/{id}` | — | 200 (empty) |
| GET | `/api/roles` | — | 200 (no example body — still undocumented) |
| GET | `/api/roles/permissions` | — | 200 (no example body — still undocumented) |

**User** = `{id, email, fullName, isSuperAdmin, status, mfaEnabled, createdAt, updatedAt, avatarUrl?, lastLoginAt?, roles: Role[], tenant: {id, name}}`
**Role** = `{id, code, scope, permissions: Permission[]}`
**Permission** = `{id, code}`

`tenantId` is still client-suppliable in `POST`/`PATCH /users` bodies — same BR-003 concern as M1, unresolved.

## 3. Public / Tenants — marketplace half unchanged; `my-firm` half source-verified 2026-08-06 (finding W)

`GET /api/public/lawyers`, `GET /api/public/lawyers/specializations` (bearer, despite the name) — still a marketplace-style directory the BRD lists as out-of-scope. `GET /api/settings/public` (none). The System-Admin-only `GET/PATCH/DELETE /api/tenants`/`/api/tenants/{id}` and `POST /api/tenants/provision` — unchanged, out of scope for this app (BR-037, this client never acts as System Admin); `DELETE` on a tenant is confirmed soft-delete (see finding C — does not contradict BR-013).

`GET/PATCH /api/tenants/my-firm` + `POST /api/tenants/my-firm/logo` are real, working, Firm-facing endpoints — a "Firm Profile" screen is buildable. `GET` (any authenticated tenant user) returns the raw `Tenant` entity: `{id, name, logoUrl, address, contactEmail, ownerUserId, defaultLanguage: EN|AR, currency, timezone, status: ACTIVE|SUSPENDED|CANCELLED, subscription, createdAt, updatedAt}`. `PATCH`/logo-upload both require `settings.update`. **`UpdateTenantDto`'s fields don't reliably map to real `Tenant` columns — see finding W before building an edit form:** only `name`/`address` are safe; the DTO also accepts `publicContactEmail`/`publicContactPhone`/`website`/`specializations`, none of which have a matching column on `Tenant` (closest is `contactEmail`, a different name than `publicContactEmail`) — this looks like a copy-pasted DTO from an unrelated concept, flag to the backend team rather than guessing which fields actually persist.

## 4. Notifications — fully source-verified 2026-08-06 (finding S), real and low-risk

`GET /api/notifications/me` → **unread only** (`isRead: false` filtered server-side), sorted newest-first: `[{id, userId, title, message, isRead, type, createdAt}]`. `PATCH /api/notifications/{id}/read` (ownership-checked, 404 if not the caller's own). Both `plainToInstance`-enforced — reliable. Real `NotificationType` enum: `HEARING_REMINDER|TASK_ASSIGNED|INVOICE_DUE|SYSTEM_ALERT`. No permission gating beyond being authenticated. No creation endpoint (server-internal only). Same gap as before, unchanged: no `/me/notification_prefs`, no device/FCM registration, no way to see already-read notifications (no history endpoint).

## 5. Clients — shape rebuilt (see breaking change #4)

| Method | Path | Request | Response |
|---|---|---|---|
| POST | `/api/clients` | `{tenantId, clientCode, type: INDIVIDUAL\|COMPANY, fullName, nationalId?, commercialReg?, emails[], phones[], addresses[]}` | 201 Client |
| GET | `/api/clients` | — | 200 Client[] |
| GET/PATCH/DELETE | `/api/clients/{id}` | (PATCH same fields, optional) | 200 / 200 / 204 |

**Client** = `{id, tenantId, clientCode, type, fullName, status, createdAt, updatedAt, nationalId?, commercialReg?, emails: string[], phones: string[], addresses: string[]}`. Note `emails`/`phones`/`addresses` are arrays of plain strings in the examples, not objects with a "primary" flag — BRD wanted one designated primary per array (§8.3); this collection doesn't show how (or if) that's represented. `DELETE` is confirmed soft-delete (TypeORM `@DeleteDateColumn`/`isArchived` via `.softRemove()` — see backend-source finding C above), matching the spec's "archive only" expectation.

## 6. Opponents — minor shape change, source-verified 2026-08-06 (finding T)

`{type: INDIVIDUAL|COMPANY|GOVERNMENT, name, phone?, address?}` — **`email` and `notes` fields are gone** compared to the M1 version. POST/GET/PATCH/DELETE all otherwise the same shape (`id, type, name, createdAt, updatedAt, phone?, address?`), `plainToInstance`-enforced (reliable). Still no representative_name/representative_contact (BRD §8.3). DELETE confirmed soft (see finding C). **No `caseId` on the entity — this is a flat, tenant-wide directory, not a per-case sub-resource.** A `CaseOpponent` join table exists and `case.opponents` is joined into every case response, but no endpoint anywhere populates it — see finding T for the full detail. A standalone Opponents directory (list/create/edit/delete) is buildable; a "case's opponents" UI is not, until a link-endpoint exists.

## 7. Courts — shape adjusted; full CRUD confirmed 2026-08-06 (finding U), only the read side is built

`{name, type, city?, address?, isActive}` (was `location`/`contactInfo`, now `city`/`address`). `plainToInstance`-enforced, DELETE confirmed soft (see finding C) — matches BR-021's "deactivate, don't delete". Still no court_circuits endpoints. **`POST`/`PATCH`/`DELETE /courts` are real, working endpoints (`courts.create/update/delete` permissions)** — this app currently only calls `GET /courts` as read-only reference data for Case/Hearing pickers; Court management itself was never built as a first-class feature. Same simple-CRUD shape as Clients, no blockers.

## 8. Cases — shape rebuilt (see breaking change #3)

| Method | Path | Request | Response |
|---|---|---|---|
| POST | `/api/cases` | `{tenantId, caseNumber, clientId, caseTypeId, primaryLawyerId, defaultCourtId, status, openingDate?, closingDate?, outcomeSummary?, agreedFee?, priority}` | 201 Case |
| GET | `/api/cases` | — | 200 Case[] |
| GET | `/api/cases/{id}` | — | 200 Case |
| PATCH | `/api/cases/{id}` | same fields as POST, all optional | 200 Case |
| DELETE | `/api/cases/{id}` | — | 204 |

**Case** (as documented by the Postman collection / the backend's own `CaseResponseDto` — **see the correction below, this is NOT what a real server returns**) = `{id, tenantId, caseNumber, status, clientId, caseTypeId, priority, createdAt, updatedAt, client: Client, primaryLawyerId, primaryLawyer: User, caseType: {id, name}, defaultCourtId, defaultCourt: Court, openingDate?, closingDate?, outcomeSummary?, agreedFee?, team: [{id, role, user: User}]}`.

**⚠️ CRITICAL CORRECTION (2026-07-30, M3 pre-planning re-verification) — this documented shape is never actually enforced.** `CasesController` never calls `plainToInstance`/applies `ClassSerializerInterceptor` (confirmed: neither exists anywhere in `Hoqooq-main/src/`) — it returns the raw TypeORM entity as loaded by `CasesService.findAll`/`.findOne`, whose query is `relations: ['client', 'defaultCourt', 'team', 'opponents', 'timelineEvents']`. That means the **real** wire shape is:
- `caseType` — **never returned at all.** Not in the `relations` array. `caseTypeId` is always present; the nested lookup object never is.
- `primaryLawyer` — **never returned at all**, same reason. `primaryLawyerId` is present but **nullable** (the entity column is `string | null`, not required — the app previously modeled it as required, which was also wrong).
- `defaultCourt`/`defaultCourtId` — genuinely nullable on the entity itself (a case can have no default court), not just a relations-loading question. `defaultCourt` **is** in the `relations` array, so it's present whenever `defaultCourtId` is set.
- `team[]` — present (`'team'` is in the `relations` array), but each entry's real field name is **`roleOnCase`**, not `role` (the backend's own `CaseResponseDto` documents `role` — it doesn't match its own entity, `CaseTeam`). Each entry's `user` is **never populated** (`relations: ['team']` loads the `CaseTeam` rows themselves but not `'team.user'`) — only `userId` is reliably present.
- `client` — present and correct (`'client'` is in the `relations` array).

**Impact:** this is a real, confirmed regression in the already-shipped M2 code — `LegalCase`/`CaseTeamMember` had `caseType`/`primaryLawyer`/`team[].user` as `required` non-nullable fields, which throws against a real backend. **Fixed** (see CLAUDE.md session log): all four were made nullable at the time, `team[].role` renamed to `roleOnCase` to match the real field, `team[].userId` added since it's always present even when `user` isn't, and `case_details_page.dart`/`client_profile_page.dart` degrade gracefully (fallback to the raw id or a placeholder string) instead of assuming the nested objects exist. **This same "DTO documents X, but nothing enforces it — the real shape is governed by each service's TypeORM `relations` array" pattern applies to Hearings, Tasks, Calendar, and Documents' list endpoint too** (see finding I) — `ClientsController` and the Documents *upload* response were, at the time, the only two places in the whole API that actually called `plainToInstance` (now also Opponents/Users/Courts/Notifications/Employees — see finding Q — but still not Cases/Hearings/Tasks/Calendar).

**⚠️ Superseded 2026-08-05 (finding N/O) — re-read this section, some of the above is now wrong, not just incomplete:**
- `primaryLawyer`/`primaryLawyerId` are **no longer nullable fields to work around — they're gone from the schema entirely.** `CreateCaseDto`/`UpdateCaseDto` no longer accept `primaryLawyerId` either. The "primary lawyer" concept has been replaced by `team[]`, now addable via `POST /cases/:id/assignments`.
- `team[].role` is **not** `roleOnCase` at the wire level — the real column is `accessLevel` (enum `FULL_ACCESS|READ_ONLY|UPLOAD_DOCUMENTS|ASSIGN_HEARING`). `roleOnCase` was a reasonable read of the backend's own (also-wrong) `CaseResponseDto` at the time, but the real entity's field is `accessLevel`; `roleOnCase` only exists as a backward-compat type alias for the enum type, never a JSON key.
- `team[].user` **is now reliably populated** — `CasesService`'s query builder explicitly joins `team.user`, unlike when this section was first written.
- `caseType` is still never nested in the response (unchanged) — but it no longer needs to be: `caseTypeId` can now be resolved to a name client-side via `GET /lookups?kind=CASE_TYPE` (finding K).

**Case creation is now unblocked (2026-08-05, finding K):** `CreateCaseDto` requires `tenantId` (client-suppliable but always overridden server-side, `CasesService.create` spreads it last — same pattern as before), `caseNumber`, `clientId`, `caseTypeId` (now populatable via Lookups). Optional: `defaultCourtId`, `status`, `openingDate`, `closingDate`, `outcomeSummary`, `agreedFee`, `priority`. No `primaryLawyerId` on create (see above — team assignment is a separate call).

**No more `title`, no more free-text `description`, no more `assignments[]`/`notes[]`, no more `POST /cases/{id}/assignments` or `/notes` endpoints.** `status` examples seen: `DRAFT`, `ACTIVE`, `SUSPENDED`, `CLOSED`, `ARCHIVED` (confirmed exhaustive from source). `priority`: `LOW`, `NORMAL`, `HIGH`, `URGENT` (confirmed exhaustive from source). This is much closer to BRD's case model than before, but the loss of any note-taking or hearings/documents sub-resources on the case itself means a Case Detail screen now has **less** to show than the previous (mock) version assumed, not more — only Overview + Team via `team[]`.

## 9. Tasks — shape adjusted

`{assignedById, assignedToId, title, caseId?, description?, priority, status, dueDate?}` request; response adds `completedAt?`. `status` enum now `PENDING/IN_PROGRESS/COMPLETED/CANCELLED` (was `TODO/IN_PROGRESS/DONE`). `priority` seen: `LOW/NORMAL/HIGH` (URGENT not observed but plausible given the pattern elsewhere). No `entity_type` polymorphic linking — only `caseId`, same limitation as before.

## 10. Documents — shape adjusted

`POST /api/documents/upload` (multipart: `file` required, `caseId` text) → `{id, title, fileType, sizeBytes, uploadedById, versionNumber, createdAt, updatedAt, description?, caseId?, folderId?, categoryId?}`. `GET /api/documents/{id}/download`, `DELETE /api/documents/{id}` (confirmed soft-delete, see finding C), `GET /api/documents`. Still no versions-list/restore endpoints despite `versionNumber` existing on the model — you can see which version you're on, not browse or restore prior ones.

## 11. Hearings — shape adjusted, now closer to BRD

`{caseId, courtId, hearingTypeId, scheduledAt, circuitId?, judgeName?, status?, outcomeText?, nextHearingAt?}` (`hearingTypeId` is required, not optional — corrected 2026-08-05, see below). `status` enum now `SCHEDULED/COMPLETED/ADJOURNED` (was `SCHEDULED/COMPLETED/POSTPONED`) — matches BRD's hearings model (§8.4) almost exactly now, including `circuitId` (though still no nested circuit object or standalone circuits endpoint) and `outcomeText`/`nextHearingAt` (BR-020). Still no `/complete` action — just a raw `status` field via PATCH. **Correction (M3 pre-planning re-check, see finding I below): DELETE is actually a hard delete here** (`HearingsService.remove` calls `.remove()`, not `.softRemove()`) — the blanket "confirmed soft" claim from finding C did not hold for this module; don't wire a destructive hearings UI action without re-confirming with the backend team first. **Re-confirmed unchanged 2026-08-05.**

**Hearing creation is now unblocked (2026-08-05, finding K):** `hearingTypeId` is now populatable via `GET /lookups?kind=HEARING_TYPE`. `HearingsService.create` also enforces a new authorization rule not previously documented: a non-firm-admin caller must have a `CaseTeam` assignment on the target case with `accessLevel` of `FULL_ACCESS` or `ASSIGN_HEARING`, or the request 403s (`ForbiddenException`) — worth surfacing distinctly in the UI if a non-admin's hearing-creation attempt fails for this reason, rather than a generic error.

## 12. Finance — fully source-verified 2026-08-06 (finding R), supersedes everything below from the Postman-era summary

**Invoices**: create/read/update all real; request DTO = `{clientId, caseId?, invoiceNumber, subtotal, taxTotal, grandTotal, status?, issueDate, dueDate, notes?}` (no client-suppliable `tenantId` — sourced from the JWT). Real `InvoiceStatus` enum (`entities/invoice.entity.ts`, confirmed exhaustive from source): `DRAFT|SENT|PARTIAL|PAID|CANCELLED`. Response is a **raw entity**, not the documented DTO (`FinanceController` never calls `plainToInstance`) — list (`GET /finance/invoices`) loads `relations: ['client', 'case', 'payments']`, detail (`GET /finance/invoices/:id`) additionally loads `lineItems`. Still no line-items CRUD despite the relation existing — totals stay flat, client-supplied numbers. **Payments**: create/read/delete only, **no update** — request DTO = `{invoiceId, amount, paymentDate, method, referenceNumber?}` (field is `method`, not `paymentMethod` — see the enum-mismatch caveat below). Also a raw entity, `relations: ['invoice']`. Creating a payment auto-transitions the parent invoice's `status` to `PARTIAL`/`PAID` server-side — refetch the invoice to see it.

**⚠️ `DELETE` on both invoices and payments is a HARD delete (`.remove()`, not `.softRemove()`) — this directly contradicts what this line previously said ("confirmed soft-delete... does not contradict BR-028/BR-029").** That earlier claim was never actually checked against Finance source; it was inferred from finding C's general pattern, which finding C itself already warned not to assume blanket-applies (see finding R for the full write-up, and finding C's Hearings/Tasks caveat). **This is the one hard-delete-vs-BR conflict in the entire API that actually matters** — BR-028/BR-029 explicitly name financial records. No Flutter delete UI exists for Finance (nothing retroactively broken), but don't build one without a business-rule conversation first.

**Backend inconsistency, not a Flutter workaround target:** two different `PaymentMethod` enums exist — the DTO validates `CASH|BANK_TRANSFER|CHEQUE|ONLINE`, the `Payment` entity's DB column type declares `CASH|BANK_TRANSFER|CREDIT_CARD|CHECK`. Send the DTO's values (that's what's actually enforced on write); flag the mismatch to the backend team rather than guessing which one the database really accepts.

**New since the Postman-era version of this file**: `GET /finance/analytics` (firm-wide revenue/collection/net-profit summary, hand-built response, reliable), `GET /finance/cases-summary` (per-case payment-status breakdown for every case in the tenant), `GET /finance/cases/:caseId/summary` (same, single case, plus nested invoices) — none of these three existed in the Postman collection at all. Still no reversal/compensating-transaction endpoint (a real gap, distinct from the delete-semantics question — and now a more pointed one given delete is hard). Still no expenses module with any HTTP surface, despite an `Expense` entity existing server-side (used internally by `getFinancialAnalytics`'s net-profit calculation, never exposed over a route).

## 13. Calendar — shape adjusted, now closer to BRD's unified-calendar concept

`{userId, title, eventType: CUSTOM|TASK_DEADLINE|..., startsAt, endsAt?, description?, referenceId?, location?, isAllDay}` + `tenantId` in the response. `eventType: TASK_DEADLINE` appearing in examples is a good sign this is meant to aggregate task due dates as the spec's Calendar screen wants (§5.7) — but there's still no confirmed value for a hearing-derived event type, so it's unclear whether `GET /calendar` alone will surface hearings too, or whether the mobile app still needs to separately merge `/hearings` in. `GET /calendar/timeline` (query: `startDate, endDate, caseId, userId`) still has no example response — still the best candidate for "the" aggregation endpoint, still unconfirmed. DELETE confirmed soft (see finding C).

## 14. Reports & Dashboard — unchanged

Both `GET /api/reports/dashboard` (`{totalActiveCases, pendingTasks, upcomingHearings}`) and `GET /api/dashboard` (`{totalCases, activeCases, pendingTasks, upcomingHearings, totalInvoices, unpaidInvoices, recentActivity[]}`) still exist, still overlapping, still unresolved which one the mobile Dashboard should call. `GET /reports/export/{cases,clients}` unchanged (CSV, no example).

## 15. Settings — unchanged

Generic key-value store, same as M1 version. Same limitation: no typed lookups endpoint for case types/hearing types/document categories/expense categories (though `caseType: {id, name}` appearing nested in Case responses now confirms **lookups do exist as real entities server-side** — there's just still no dedicated `GET /lookups?kind=...`-style endpoint exposed in this collection to fetch them standalone).

## 16. AI Assistant — confirmed non-functional stub 2026-08-06 (finding X)

`POST /api/ai/summarize`, `/api/ai/research`, `/api/ai/chat` — all three return a hardcoded `{status: 'success', message: 'AI Module is ready to be implemented.'}` regardless of input. Not a documentation gap, an implementation gap: there is no real AI/RAG behavior behind these routes at all yet. Still no entitlement/credit-preflight endpoint, still no classify/extract actions. Not buildable as a real feature in any near-term milestone.

## 17. Modules removed since M1 (see breaking change #5)

`reviews` (2 endpoints), `consultations` (1 endpoint) — gone, confirmed still gone as of the 2026-08-05 re-sync. `employees` is technically back (two colliding controllers, see finding Q) but not usable/not used by this app. `POST /cases/{id}/assignments` and `POST /cases/{id}/notes`, both flagged as removed in the original M1→re-sync diff, are **back as of the 2026-08-05 re-sync** — see finding P.

## 18. Lookups (new, 2026-08-05) — see finding K

`GET /lookups?kind=CASE_TYPE|HEARING_TYPE|DOCUMENT_CATEGORY|EXPENSE_CATEGORY` (bearer, `lookups.read` permission), tenant-scoped. Response: raw `Lookup[]` — `{id, tenantId, kind, labelEn, labelAr, isActive, createdAt, updatedAt}`. `GET /lookups/enums` (bearer, any authenticated user) returns a static dictionary of backend enums, not used by this app (enums are hand-modeled from entity source per project convention). This is the endpoint that unblocks Case/Hearing creation — see §8/§11 below.

## 19. Subscriptions (new, 2026-08-05) — see finding M

`GET /subscriptions/plans` (public). `POST /subscriptions/activate` (bearer, defaults to caller's own `tenantId`) — reactivates an *existing* subscription row only (404 if none exists at all). `POST /subscriptions/:tenantId/{activate,deactivate}` — Super Admin only (`system.subscriptions.manage`). No `GET /subscriptions/me`-style status-check endpoint exists — the only way the app learns its tenant's subscription state is by getting a 402 on some other call. Global `SubscriptionGuard` blocks every authenticated request (reads included) with 402 unless the tenant's subscription is `ACTIVE` and unexpired — confirmed intentional by the backend team, not a bug.

---

## Gap Analysis Summary (updated)

### Resolved since the M1 version of this file
- Marketplace reviews/consultations endpoints — removed entirely, no longer a concern.
- Case model now has `agreed_fee`, `priority`, `opening_date`/`closing_date`, `primary_lawyer_id`, `case_type_id` as a lookup — all previously-flagged BRD gaps, now present.
- Client model now has `client_code`, `national_id`/`commercial_reg`, multi-value contact arrays — previously-flagged BRD gaps, now present.
- Hearings model now has `hearing_type_id`, `circuit_id`, `judge_name`, `outcome_text`, `next_hearing_at`, and the correct `SCHEDULED/COMPLETED/ADJOURNED` status enum — previously-flagged gaps, now present.

### Still open (unchanged from M1 version)
- No MFA endpoint, no invite-activation endpoint, no device/FCM registration, no `/me/notification_prefs`.
- No subscription/billing/plan endpoint anywhere — `X-Subscription-Status` mechanism still has no data source.
- No case-timeline endpoint (BR-017) — and now no case-notes endpoint either (removed this update).
- No document-versions-list/restore endpoint (BR-024) despite `versionNumber` existing on the model.
- No AI entitlement/credit-preflight endpoint (BR-031), no classify/extract actions.
- No expenses module at all.
- No payment-reversal/compensating-transaction endpoint (BR-029) — note `DELETE` on invoices/payments is confirmed **hard**-delete (see finding R, 2026-08-06 — corrects the line below), so this gap is about the missing reversal workflow AND the delete-semantics question, not just the former.
- ~~Hard `DELETE`~~ **Partially resolved, then partially re-broken by a later verification (see finding R, 2026-08-06):** cases, clients, documents, courts, opponents, tenants, users, calendar events are confirmed TypeORM soft-delete (`.softRemove()`) — do **not** violate BR-016/024/028/029. **Invoices and payments were wrongly included in this "confirmed soft" list — they are hard `.remove()` calls, never actually checked against Finance source until the 2026-08-06 pass. This is the one real hard-delete-vs-BR conflict in the API** (BR-028/BR-029 explicitly cover financial records), on top of the already-known Hearings/Tasks inconsistency (which those BR numbers don't cover).
- `tenantId` still client-suppliable on `POST/PATCH /users`, and now also on `POST/PATCH /cases` — still contradicts BR-003.
- No error-envelope example anywhere in any of the 87 requests.
- `auth/signup` still exists, still contradicts BR-001.
- `public/lawyers` marketplace directory still exists, still a BR-scope concern (unlike reviews/consultations, this one was NOT removed).

### New since this update
- Employee/staff-management module removed entirely — BRD §6.2.3 now has zero backing (regression from M1's already-imperfect version, not an improvement).
- Case note-taking capability removed entirely (both the `notes[]` field and the endpoint to add one).
- Case-to-employee assignment endpoint removed (`team[]` is now presumably populated some other way not visible in this collection — unclear how a mobile client would ever add someone to a case's team, since no endpoint exists for it).

### Resolved in the second backend re-sync (2026-08-05) — see findings K–P
- **Lookup-listing endpoint** (`GET /lookups?kind=...`) — Case and Hearing creation, both blocked since M4 planning, are unblocked.
- **Firm Admin mechanism** — real `FIRM_ADMIN` role now exists; `ownerUserId`-based detection is obsolete, superseded by finding L.
- **Case-team-assignment endpoint** (`POST /cases/:id/assignments`) — restored, previously flagged as a lost-since-M1 regression.
- **Case note-adding endpoint** (`POST /cases/:id/notes`) — restored, though `GET /cases/:id` still doesn't return notes back (write-only until that's also fixed).
- **Clients tenant-scoping** — `findOne`/`update`/`remove` fixed (still open on `create` only, see finding Q).

### Still open (re-confirmed 2026-08-05, see finding Q for detail)
- No MFA endpoint, no invite-activation endpoint, no device/FCM registration, no `/me/notification_prefs`.
- No case-timeline endpoint (BR-017) despite the `CaseTimelineEvent` entity/relation existing server-side.
- No document-versions-list/restore endpoint (BR-024) despite `versionNumber`/`DocumentVersion` existing on the model.
- No document category field on upload, despite `Lookup` now supporting `DOCUMENT_CATEGORY`.
- No AI entitlement/credit-preflight endpoint (BR-031), no classify/extract actions.
- No expenses module at all.
- No payment-reversal/compensating-transaction endpoint (BR-029).
- Hearings/Tasks hard-delete (not soft) — irrelevant while delete stays deferred app-wide.
- Clients `create` still accepts a client-supplied, unvalidated `tenantId`.
- DELETE status-code inconsistency (only Clients has real `@HttpCode(204)`).
- `ValidationPipe`/`HttpExceptionFilter` still collapses multi-field validation errors to one message per submit.
- `tenantId` still client-suppliable (though overridden server-side) on `POST /cases`/`POST /hearings`/`POST/PATCH /users`.
- `auth/signup` still exists, still contradicts BR-001. `public/lawyers` marketplace still exists, still a BR-scope concern.
- **New this pass:** duplicate `EmployeesController` route collision (backend bug, not a Flutter concern — see finding Q).

### Real, buildable, backend-supported features not yet in Flutter (third re-sync, 2026-08-06 — see findings R–Y)

Not gaps in the backend — these all exist, work, and are DTO-verified (or raw-entity-verified where noted). Listed here because M6 planning drew directly from this list, per the instruction to prioritize what already exists over inventing new work:
- **Finance (Invoices + Payments)** — full CRUD minus payment-update, plus 3 analytics endpoints (`/finance/analytics`, `/finance/cases-summary`, `/finance/cases/:caseId/summary`). BRD-aligned (§8.4, BR-026–029). See finding R for the hard-delete correction and the two DTO/enum mismatches to work around.
- **Notifications** — `GET /notifications/me` (unread only) + `PATCH .../read`. Simplest, lowest-risk item on this list; the Flutter screen already exists as static UI waiting to be wired up.
- **Opponents** — standalone tenant-wide CRUD directory. Real but structurally can't be linked to a case (see finding T) — scope any UI as a flat directory, not a case sub-resource.
- **Courts, write side** — `POST`/`PATCH`/`DELETE /courts` exist; only `GET` is used today.
- **Firm Profile** (`GET/PATCH /tenants/my-firm` + logo upload) — real, Firm-Admin-only (`settings.update`), one DTO/entity field-mapping issue to flag to the backend team before trusting it fully (finding W).

### Confirmed NOT buildable this pass
- **AI Assistant** — all three endpoints are hardcoded stubs, zero real behavior (finding X).
- **Case-linked Opponents / Case Timeline** — both have a joined-but-always-empty relation on `Case`, no write path exists for either (findings T, V).
- **Public lawyers marketplace, `auth/signup`** — exist but remain explicit BR-scope violations, not something to build toward.
