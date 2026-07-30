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

## 3. Public / Tenants — unchanged (still present, still a BR-scope concern)

`GET /api/public/lawyers`, `GET /api/public/lawyers/specializations` (bearer, despite the name) — still a marketplace-style directory the BRD lists as out-of-scope. `GET /api/settings/public` (none). `GET/PATCH /api/tenants/my-firm`, `POST /api/tenants/my-firm/logo`, and the System-Admin-only `GET/PATCH/DELETE /api/tenants`/`/api/tenants/{id}` — all unchanged from M1, all the same concerns (cross-tenant System-Admin endpoints sitting in the same flat collection as firm-scoped ones; `DELETE` on a tenant is confirmed soft-delete, see finding C — does not contradict BR-013).

## 4. Notifications — unchanged

`GET /api/notifications/me` → `[{id, userId, title, message, isRead, type, createdAt}]`. `PATCH /api/notifications/{id}/read`. Same gap as before: no `/me/notification_prefs`, no device registration.

## 5. Clients — shape rebuilt (see breaking change #4)

| Method | Path | Request | Response |
|---|---|---|---|
| POST | `/api/clients` | `{tenantId, clientCode, type: INDIVIDUAL\|COMPANY, fullName, nationalId?, commercialReg?, emails[], phones[], addresses[]}` | 201 Client |
| GET | `/api/clients` | — | 200 Client[] |
| GET/PATCH/DELETE | `/api/clients/{id}` | (PATCH same fields, optional) | 200 / 200 / 204 |

**Client** = `{id, tenantId, clientCode, type, fullName, status, createdAt, updatedAt, nationalId?, commercialReg?, emails: string[], phones: string[], addresses: string[]}`. Note `emails`/`phones`/`addresses` are arrays of plain strings in the examples, not objects with a "primary" flag — BRD wanted one designated primary per array (§8.3); this collection doesn't show how (or if) that's represented. `DELETE` is confirmed soft-delete (TypeORM `@DeleteDateColumn`/`isArchived` via `.softRemove()` — see backend-source finding C above), matching the spec's "archive only" expectation.

## 6. Opponents — minor shape change

`{type, name, phone?, address?}` — **`email` and `notes` fields are gone** compared to the M1 version. POST/GET/PATCH/DELETE all otherwise the same shape (`id, type, name, createdAt, updatedAt, phone?, address?`). Still no representative_name/representative_contact (BRD §8.3). DELETE confirmed soft (see finding C).

## 7. Courts — shape adjusted

`{name, type, city?, address?, isActive}` (was `location`/`contactInfo`, now `city`/`address`). Still no court_circuits endpoints. DELETE confirmed soft (see finding C) — matches BR-021's "deactivate, don't delete".

## 8. Cases — shape rebuilt (see breaking change #3)

| Method | Path | Request | Response |
|---|---|---|---|
| POST | `/api/cases` | `{tenantId, caseNumber, clientId, caseTypeId, primaryLawyerId, defaultCourtId, status, openingDate?, closingDate?, outcomeSummary?, agreedFee?, priority}` | 201 Case |
| GET | `/api/cases` | — | 200 Case[] |
| GET | `/api/cases/{id}` | — | 200 Case |
| PATCH | `/api/cases/{id}` | same fields as POST, all optional | 200 Case |
| DELETE | `/api/cases/{id}` | — | 204 |

**Case** = `{id, tenantId, caseNumber, status, clientId, caseTypeId, priority, createdAt, updatedAt, client: Client, primaryLawyerId, primaryLawyer: User, caseType: {id, name}, defaultCourtId, defaultCourt: Court, openingDate?, closingDate?, outcomeSummary?, agreedFee?, team: [{id, role, user: User}]}`.

**No more `title`, no more free-text `description`, no more `assignments[]`/`notes[]`, no more `POST /cases/{id}/assignments` or `/notes` endpoints.** `status` examples seen: `DRAFT`, `ACTIVE`, `ARCHIVED` (still not a documented exhaustive list). `priority` examples seen: `NORMAL`, `HIGH`, `URGENT` (BRD's 4th value `LOW` not observed but plausible). This is much closer to BRD's case model than before, but the loss of any note-taking or hearings/documents sub-resources on the case itself means a Case Detail screen now has **less** to show than the previous (mock) version assumed, not more — only Overview + Team via `team[]`.

## 9. Tasks — shape adjusted

`{assignedById, assignedToId, title, caseId?, description?, priority, status, dueDate?}` request; response adds `completedAt?`. `status` enum now `PENDING/IN_PROGRESS/COMPLETED/CANCELLED` (was `TODO/IN_PROGRESS/DONE`). `priority` seen: `LOW/NORMAL/HIGH` (URGENT not observed but plausible given the pattern elsewhere). No `entity_type` polymorphic linking — only `caseId`, same limitation as before.

## 10. Documents — shape adjusted

`POST /api/documents/upload` (multipart: `file` required, `caseId` text) → `{id, title, fileType, sizeBytes, uploadedById, versionNumber, createdAt, updatedAt, description?, caseId?, folderId?, categoryId?}`. `GET /api/documents/{id}/download`, `DELETE /api/documents/{id}` (confirmed soft-delete, see finding C), `GET /api/documents`. Still no versions-list/restore endpoints despite `versionNumber` existing on the model — you can see which version you're on, not browse or restore prior ones.

## 11. Hearings — shape adjusted, now closer to BRD

`{caseId, courtId, hearingTypeId?, scheduledAt, circuitId?, judgeName?, status, outcomeText?, nextHearingAt?}`. `status` enum now `SCHEDULED/COMPLETED/ADJOURNED` (was `SCHEDULED/COMPLETED/POSTPONED`) — matches BRD's hearings model (§8.4) almost exactly now, including `circuitId` (though still no nested circuit object or standalone circuits endpoint) and `outcomeText`/`nextHearingAt` (BR-020). Still no `/complete` action — just a raw `status` field via PATCH. **Correction (M3 pre-planning re-check, see finding I below): DELETE is actually a hard delete here** (`HearingsService.remove` calls `.remove()`, not `.softRemove()`) — the blanket "confirmed soft" claim from finding C did not hold for this module; don't wire a destructive hearings UI action without re-confirming with the backend team first.

## 12. Finance — shape adjusted

**Invoices**: `{clientId, invoiceNumber, subtotal, taxTotal, grandTotal, issueDate, dueDate, caseId?, status, notes?}` + nested `payments[]`. `status` now includes `PARTIAL` (was `DRAFT/ISSUED/PAID/CANCELLED`, examples now show `PARTIAL/PAID/CANCELLED` — union unclear, not exhaustively documented). Still flat totals, no line-items endpoint (BRD's `invoice_line_items`). **Payments**: unchanged shape, `{invoiceId, amount, paymentDate, method, referenceNumber?}`. `DELETE` on both invoices and payments is confirmed soft-delete (see finding C) — does not contradict BR-028/BR-029. Still no reversal/compensating-transaction endpoint (a real gap, distinct from the delete-semantics question). Still no expenses module at all.

## 13. Calendar — shape adjusted, now closer to BRD's unified-calendar concept

`{userId, title, eventType: CUSTOM|TASK_DEADLINE|..., startsAt, endsAt?, description?, referenceId?, location?, isAllDay}` + `tenantId` in the response. `eventType: TASK_DEADLINE` appearing in examples is a good sign this is meant to aggregate task due dates as the spec's Calendar screen wants (§5.7) — but there's still no confirmed value for a hearing-derived event type, so it's unclear whether `GET /calendar` alone will surface hearings too, or whether the mobile app still needs to separately merge `/hearings` in. `GET /calendar/timeline` (query: `startDate, endDate, caseId, userId`) still has no example response — still the best candidate for "the" aggregation endpoint, still unconfirmed. DELETE confirmed soft (see finding C).

## 14. Reports & Dashboard — unchanged

Both `GET /api/reports/dashboard` (`{totalActiveCases, pendingTasks, upcomingHearings}`) and `GET /api/dashboard` (`{totalCases, activeCases, pendingTasks, upcomingHearings, totalInvoices, unpaidInvoices, recentActivity[]}`) still exist, still overlapping, still unresolved which one the mobile Dashboard should call. `GET /reports/export/{cases,clients}` unchanged (CSV, no example).

## 15. Settings — unchanged

Generic key-value store, same as M1 version. Same limitation: no typed lookups endpoint for case types/hearing types/document categories/expense categories (though `caseType: {id, name}` appearing nested in Case responses now confirms **lookups do exist as real entities server-side** — there's just still no dedicated `GET /lookups?kind=...`-style endpoint exposed in this collection to fetch them standalone).

## 16. AI Assistant — unchanged

`POST /api/ai/summarize`, `/api/ai/research`, `/api/ai/chat` — still no example bodies, still no entitlement/credit-preflight endpoint, still no classify/extract actions. Same gaps as M1 version.

## 17. Modules removed since M1 (see breaking change #5)

`employees` (all 5 endpoints), `reviews` (2 endpoints), `consultations` (1 endpoint) — gone. `POST /cases/{id}/assignments` and `POST /cases/{id}/notes` also gone (folded into the Case rebuild above).

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
- No payment-reversal/compensating-transaction endpoint (BR-029) — note `DELETE` on invoices/payments is confirmed soft-delete (see finding C above), so this gap is about the missing reversal workflow, not physical deletion.
- ~~Hard `DELETE`~~ **Resolved (2026-07-30, backend-source re-sync):** all `DELETE` endpoints are TypeORM soft-delete (`@DeleteDateColumn`/`isArchived` via `.softRemove()`), confirmed from `Hoqooq-main/` source — cases, clients, documents, courts, opponents, invoices, payments, tenants, users, calendar events do **not** violate BR-016/024/028/029. This was a wrong inference in earlier versions of this file, not a real backend gap.
- `tenantId` still client-suppliable on `POST/PATCH /users`, and now also on `POST/PATCH /cases` — still contradicts BR-003.
- No error-envelope example anywhere in any of the 87 requests.
- `auth/signup` still exists, still contradicts BR-001.
- `public/lawyers` marketplace directory still exists, still a BR-scope concern (unlike reviews/consultations, this one was NOT removed).

### New since this update
- Employee/staff-management module removed entirely — BRD §6.2.3 now has zero backing (regression from M1's already-imperfect version, not an improvement).
- Case note-taking capability removed entirely (both the `notes[]` field and the endpoint to add one).
- Case-to-employee assignment endpoint removed (`team[]` is now presumably populated some other way not visible in this collection — unclear how a mobile client would ever add someone to a case's team, since no endpoint exists for it).
