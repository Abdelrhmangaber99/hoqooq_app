# Hoqooq v2 Production Blockers

**Release decision:** **BLOCKED** as of 2026-08-20 (re-verified directly
against `D:\hoqooq\Hoqooq\src`). The severity dropped sharply since the
2026-08-13 pass — 15 of the 22 original BV2 findings are now resolved on the
backend — but real P0/P1 items remain. No production-readiness claim is valid
while any blocker below is open.

| Priority | Blocker | Source | Release impact |
|---|---|---|---|
| P0 | No endpoint lists existing Case access grants/grantees | BV2-018 | Case access management screen cannot display or safely edit current permissions — grants can be replaced/revoked blind. |
| P0 | Case status accepts any direct transition, including out of `ARCHIVED`; extra `SUSPENDED` state unaddressed | BV2-022 | Legal-record lifecycle integrity is not server-enforced; a direct API call can un-archive or otherwise corrupt Case state. |
| P0 | Case Client/Opponent snapshots are immutable after creation | BV2-021 | No supported way to correct a party record once a Case exists; forces workarounds or data errors to persist permanently. |
| P0 | Android release build ships debug signing + placeholder `com.example.hqooq` applicationId | Flutter-side, found 2026-08-20 | Cannot produce a real signed release APK/AAB; Play Store will reject the package name outright. |
| P1 | Employee response omits authoritative classification/status/permissions | BV2-016 | Lawyer/assignee pickers (Hearing, Task, Meeting, Service assignment) cannot be built safely — this is why Flutter's Phase 5/7 assignment work is still marked skipped. |
| P1 | Employee profile fields (name/email/phone/classification) are not editable; no reactivation path after deactivation | BV2-017 | Staff-management module is only partially usable — an offboarded Employee can never be brought back through the API. |
| P1 | National Court/Circuit seed data looks incomplete (single small embedded list, no Circuit-seeding block found) | BV2-019 | Hearing Court/Circuit pickers may be empty or near-empty in a fresh environment — not independently row-count-verified this pass. |
| P1 | Onboarding invitation delivery failures are swallowed (log-only), no resend/status endpoint | BV2-020 | A new Employee can be silently unable to activate their account with no operator-visible signal. |
| P1 | Firm Admin gets unfiltered Calendar visibility across all activity types regardless of per-module permission | BV2-011 (partial) | Matches Flutter's own tracked gap (`SKIPPED_PHASE_BACKEND_BLOCKERS.md` P9-B01) — over-broad disclosure to Firm Admin accounts specifically. |
| P1 | The v2 migration work (326 changed files: new features, deleted Clients feature, all planning docs) is entirely uncommitted in the Flutter working tree | Flutter-side, found 2026-08-20 | No git history checkpoint, no CI run against this state, at risk of loss; not itself a functional blocker but must be fixed before any release process can even start. |

## Resolved since 2026-08-13 (no longer blockers)

Cross-tenant `/users` exposure and client-controlled `tenantId`/`isSuperAdmin`
(BV2-001/002), the FIRM_ADMIN/ACCOUNTANT permission bypasses (BV2-003),
unsafe employee provisioning (BV2-004), missing Lawyer specialization
enforcement (BV2-005), missing Case capability grants (BV2-006), shared
Client/Opponent records instead of snapshots (BV2-007), tenant-owned Courts
(BV2-008), incomplete Service of Process (BV2-009), missing Client Meetings
(BV2-010), invoice/expense Finance with an Accountant bypass (BV2-012), the
global subscription-blocking guard (BV2-013), Hearing/Task hard deletion
(BV2-014), and exposed public signup/marketplace/AI routes (BV2-015). See
`BACKEND_VIOLATIONS_V2.md`'s 2026-08-20 section for the file-level evidence
behind each.

## Required release evidence

- Passing Phase 1–14 tests in `HOQOOQ_V2_PRODUCTION_READINESS_PLAN.md`.
- The 6 backend items above (BV2-016, 017, 018, 019, 020, 021, 022 minus
  what's already partial) closed, plus BV2-011's Firm Admin scoping gap.
- The Flutter release-packaging fix (real applicationId + release signing).
- The current working tree committed, so this state is actually reproducible.
- Staging proof for backup/restore, tenant-isolation, authorization, and
  seeder idempotency (still not evaluated in this workspace).
