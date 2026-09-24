# Hoqooq v2 Test Traceability Matrix

| Test area | Plan tests | Test level | Required fixture/evidence |
|---|---|---|---|
| Seeder/reference data | P1-T01–T20 | Backend integration | Empty database; rerun seed 10 times. |
| Tenant isolation | P2-T01–T15 | API security integration | Firm A, Firm B, user/case/document/payment IDs. |
| Identity/provisioning | P3-T01–T14 | API integration | Super Admin, Firm Admin, Employee, inactive account. |
| References/specialization | P4-T01–T10 | API + Flutter | Alexandria/Cairo hierarchy; matching/nonmatching lawyers. |
| Case snapshots/lifecycle | P5-T01–T12 | API integration | Two Cases for the same real person. |
| Capabilities | P6-T01–T13 | API + client parity | Per-Case grants and activity-only assignment. |
| Activities | P7-T01–T12 | API integration | Hearing, Service, Meeting, Task lifecycle. |
| Documents/audit | P8-T01–T12 | API/storage integration | Tenant-scoped files and version history. |
| Calendar/notifications | P9-T01–T12 | API + Flutter | Revocation, reassignment, safe payloads. |
| Finance | P10-T01–T13 | API integration | Payment/reversal reconciliation. |
| Platform administration | P11-T01–T12 | API integration | Metadata-only Super Admin access. |
| Flutter/web parity | P12-T01–T13 | Client integration | Deep links, EN/AR RTL, logout/cache clear. |
| Hardening/release | P13-T01–T14, P14-T01–T16 | Staging/E2E | Scan, backup/restore, fresh bootstrap. |
