# Hoqooq v2 API Migration Plan

**Status:** Required backend work; endpoint names below are target semantics,
not implemented routes.

| Phase | Required API behavior | Current blocker |
|---|---|---|
| Identity | Actor-derived tenant scope; account-type/classification separation; audited provisioning and permission replacement | BV2-001–BV2-004 |
| References | Read-only global Case Type/Governorate/Court/Circuit hierarchy | BV2-008 |
| Cases | Case-owned party snapshots, archive lifecycle, validated hierarchy | BV2-007, BV2-008 |
| Access | Capability grants, immediate revocation, scoped activity detail | BV2-006 |
| Activities | Case-bound Hearing, Service, Meeting, Task APIs with retained history | BV2-009, BV2-010, BV2-014 |
| Documents | Case-owned upload/download, version history, authorization recheck | Phase 8 open |
| Calendar | Authorized, minimum-context events and safe notifications | BV2-011 |
| Finance | Case payment ledger, reversal, authorized firm aggregates | BV2-012 |
| Subscription | Explicit Firm state; no global subscription-read-only middleware | BV2-013 |

## Contract rules

- Derive tenant and actor identity from authentication context; reject client
  ownership/security fields such as `tenantId`, `isSuperAdmin`, and arbitrary
  permission grants.
- Return 404 or an equivalent non-disclosing denial for cross-tenant IDs.
- Document request/response shapes, authorization code, status codes, and
  audit effects in OpenAPI before clients enable each v2 route.
- Retain legacy routes only as deprecated compatibility paths; do not use them
  for active v2 Flutter or web flows.
