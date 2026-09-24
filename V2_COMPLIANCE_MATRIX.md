# Hoqooq v2 Compliance Matrix

**Status:** Re-verified 2026-08-20 directly against `D:\hoqooq\Hoqooq\src`
(not just re-derived from `BACKEND_VIOLATIONS_V2.md`'s older table). Most
rows below flipped from Fail to Pass/Partial since the 2026-08-13 baseline —
see that file's "2026-08-20 re-verification" section for file-level evidence.
Rows still citing BV2-016/017/018/019/020/021/022 remain genuinely open.

| Rule | Requirement | Planned verification | Current status | Evidence / blocker |
|---|---|---|---|---|
| BR-001 | Seeded Super Admin | P1-T01, P1-T09–T11 | Open | Seeder source is outside this workspace; not re-verified this pass. |
| BR-002 | Three account types | P1-T12, P3-T01–T02 | Pass | BV2-003 resolved — `PermissionsGuard` has no role bypass. |
| BR-003 | Firm/Admin provisioning | P3-T03–T11 | Pass | BV2-002, BV2-004 resolved — `tenantId` is server-derived, not client-supplied. |
| BR-004 | Admin permission assignment | P3-T12, P11-T08 | Pass | BV2-003, BV2-004 resolved. |
| BR-005 | Employee management | P3-T05–T09 | Partial | Provisioning/deactivation fixed (BV2-001–004 resolved); profile edit and reactivation still missing (BV2-017). |
| BR-006 | Classification/specialization | P4-T06–T08 | Pass | BV2-005 resolved — specialization required and validated for LAWYER classification. |
| BR-007 | Tenant isolation | P2-T01–T15 | Pass | BV2-001, BV2-002 resolved. |
| BR-008 | Effective permissions | P3-T12–T14, P6-T01–T13 | Partial | BV2-003, BV2-006 resolved; grant *listing* still missing (BV2-018). |
| BR-009 | Case capability grants | P6-T01–T07 | Partial | Grant/revoke works (BV2-006 resolved); no grant-listing endpoint (BV2-018). |
| BR-010 | Activity assignment | P6-T08–T10, P7-T08–T11 | Partial | Capability grants exist; assignee-picker data still incomplete (BV2-016). |
| BR-011 | Minimum activity context | P6-T08–T10, P7-T11 | Pass | BV2-006 resolved. |
| BR-012 | Case-local parties | P5-T01–T05, P5-T11 | Partial | Snapshots exist on create (BV2-007 resolved); update after creation still blocked (BV2-021). |
| BR-013 | Required Case Type | P5-T06, P4-T09 | Pass | BV2-008 resolved — global read-only reference data. |
| BR-014 | Matching lawyer assignment | P4-T06–T08, P7-T04 | Partial | Specialization enforced on onboarding (BV2-005 resolved); assignee picker still lacks authoritative data (BV2-016). |
| BR-015 | Firm Admin case owner | P5-T10 | Open | Not re-verified this pass. |
| BR-016 | Case preservation | P5-T08–T09, P8-T05–T06 | Partial | Case delete now archives (confirmed); status-transition matrix still unenforced (BV2-022). |
| BR-017 | Global judicial references | P4-T01–T03, P4-T10 | Pass | BV2-008 resolved. |
| BR-018 | Dependent court filtering | P4-T04–T05 | Partial | Governorate→Court→Circuit endpoints exist and work (BV2-008 resolved); seeded Circuit data looks incomplete (BV2-019, not row-count verified). |
| BR-019 | Hearing ownership/schedule | P7-T01, P7-T04 | Pass | Module confirmed Case-bound and capability-scoped. |
| BR-020 | Hearing completion/history | P7-T05, P7-T07 | Pass | BV2-014 resolved — `remove()` cancels, does not hard-delete. |
| BR-021 | Service of Process | P7-T02, P7-T06–T07 | Pass | BV2-009 resolved — full schedule/assign/complete/cancel lifecycle confirmed. |
| BR-022 | Case-bound meetings | P7-T03, P7-T08 | Pass | BV2-010 resolved — module confirmed to exist with full lifecycle. |
| BR-023 | Task assignment | P7-T09–T12 | Pass | BV2-014 resolved. |
| BR-024 | Authorized calendar | P9-T01–T04, P9-T11–T12 | Partial | BV2-006 resolved; Firm Admin still gets unfiltered cross-module visibility (BV2-011 partial). |
| BR-025 | Safe notifications | P9-T05–T10 | Partial | BV2-011 partially resolved — Service/Meeting now included, Firm Admin scoping gap remains. |
| BR-026 | Case-owned documents | P8-T01–T07, P8-T11–T12 | Open | Not re-verified this pass. |
| BR-027 | Fee/payment ledger | P10-T01–T05, P10-T09–T11 | Pass | BV2-012 resolved — real Case-payment ledger with reversal, no invoices/expenses. |
| BR-028 | Finance permission scope | P10-T06–T08, P10-T12 | Pass | BV2-003, BV2-012 resolved — no Accountant bypass, explicit `finance.*` permissions only. |
| BR-029 | Firm financial aggregates | P10-T09 | Pass | BV2-012 resolved. |
| BR-030 | Operator subscription state | P11-T01, P11-T04, P11-T09–T12 | Pass | BV2-013 resolved — global subscription guard removed. |
| BR-031 | No automatic suspension | P11-T02–T03 | Pass | BV2-013 resolved. |
| BR-032 | Server-side authorization | P2-T01–T15, P13-T02–T03 | Partial | Core bypasses removed (BV2-001–006 resolved); Case lifecycle/party-update authorization gaps remain (BV2-021, BV2-022). |
| BR-033 | Audit logging | P3-T14, P6-T11, P8-T08–T10 | Open | Not re-verified this pass. |
| BR-034 | Web/mobile parity | P6-T13, P9-T12, P12-T01–T13 | Open | Depends on stable v2 APIs; not independently tested this pass. |
| BR-035 | AI/RAG excluded | P12-T08, P13-T01 | Pass | BV2-015 resolved — no AI module, no signup, no marketplace route anywhere in backend source. |

## Acceptance-scenario mapping

`AC-001` maps to P1-T01; `AC-002`–`AC-003` to P3-T12/P4-T06;
`AC-004`–`AC-005` to P4-T07–T08; `AC-006`–`AC-007` to P4-T03–T05;
`AC-008` to P5-T04–T05; `AC-009`–`AC-010` to P6-T02–T10;
`AC-011`–`AC-012` to P9-T01–T04; `AC-013` to P7-T02/P9-T05;
`AC-014`–`AC-016` to P10-T01–T09; `AC-017` to P11-T02;
`AC-018` to P11-T05–T07; `AC-019` to P6-T05/P9-T02;
`AC-020` to P12-T02; `AC-021` to P12-T05–T06; and `AC-022` to P12-T08.
