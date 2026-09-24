# Hoqooq v2 Database Migration Plan

**Status:** Proposed only. Execute after backup and against a staging copy;
the backend schema/migrations are not present in this workspace.

## Ordered migrations

1. Add account type, classification, account status, direct permission, and
   authorization-version fields. Backfill only `SUPER_ADMIN`, `FIRM_ADMIN`,
   and `EMPLOYEE`; keep legacy roles as historical data until cutover.
2. Create global `case_types`, `governorates`, `courts`, and
   `court_circuits`, all with stable business codes and EN/AR labels. Do not
   delete tenant courts until Cases have been migrated and validated.
3. Add lawyer specializations and enforce the Case Type relationship.
4. Add Case-local client and opponent snapshot tables. Copy each existing
   Case's current party data into immutable independent snapshots.
5. Add Case capability grants and activity assignments; backfill only the
   minimum verified access and retire broad CaseTeam access after comparison.
6. Add Client Meetings; normalize Service of Process statuses and retention.
7. Add document versions, timeline events, immutable audit records, and
   tenant/case-scoped storage metadata.
8. Add Case payments and calculated aggregates. Preserve invoices/expenses
   as legacy historical data; never reinterpret them as v2 payments.
9. Separate subscription state from Firm activation state.

## Safety controls

- Snapshot the database and document store before each migration.
- Use additive, reversible schema changes first; archive rather than delete.
- Run referential-integrity and Firm A/Firm B isolation checks after each
  phase.
- Gate destructive cleanup behind a separately approved release and a tested
  rollback runbook.
- Run the production seeder and `seed:verify` only after schema migration.
