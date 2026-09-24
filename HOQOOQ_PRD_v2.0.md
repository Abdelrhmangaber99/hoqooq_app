**HOQOOQ**

**حقوق**

**Legal Practice Management Platform**

**Product Requirements Document - Version 2.0**

Authoritative Business Rules & Functional Specification

**Scope: Invite-only \| Multi-tenant \| Web + Mobile \| EN / AR (RTL)**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>SUPERSESSION NOTICE<br />
</strong>This v2.0 document replaces the conflicting role, client/opponent, court, finance, subscription-suspension, and AI/RAG logic in the previous v1.0 BRD. Where any difference exists, v2.0 is authoritative.</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

Prepared for engineering implementation \| August 2026

# **Table of Contents**

0\. Supersession & Scope Lock

1\. Executive Summary

2\. Product Scope & Objectives

3\. Actors, Accounts & Professional Profiles

4\. Legal Terminology & Global Reference Data

5\. Authorization & Permission Model

6\. Functional Requirements

7\. Business Rules (BR-###)

8\. Data Model & Data Dictionary

9\. Permission Catalog

10\. Key Workflows

11\. Acceptance Criteria & Test Scenarios

12\. Cross-Cutting Requirements

13\. Out of Scope / Deferred

14\. Traceability & Implementation Precedence

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>How to use this PRD<br />
</strong>Sections 0 and 7 are normative. Functional modules in Section 6 describe the user-visible product. Section 8 defines the required business data model. Section 9 defines authorization vocabulary. If implementation behavior conflicts with a BR-### rule, the rule wins.</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

# **0. Supersession & Scope Lock**

This document is the authoritative Hoqooq product specification for v2.0. It is intentionally written as a replacement for conflicting requirements in the previous v1.0 BRD. Existing functionality that does not conflict with v2.0 may be retained, but obsolete rules must not continue to govern the implementation.

| **Decision area**       | **v2.0 authoritative decision**                                                                                                                                          |
|-------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| System account types    | Exactly three account types: Super Admin, Firm Admin, Employee. Lawyer, Secretary, Accountant, and Other are professional/job classifications, not authentication roles. |
| Provisioning            | One seeded Super Admin. Super Admin creates Firms and their Firm Admin accounts. Firm Admin creates and manages Employees. No public signup.                             |
| Permission assignment   | Super Admin assigns the Firm Admin account-level permissions. Firm Admin assigns Employee base permissions and case-specific permissions.                                |
| Lawyer profile          | A user classified as Lawyer has one or more legal specializations. Lawyer assignment is filtered by the Case Type.                                                       |
| Client & opponent       | Client and opponent data are stored inside each Case as case-local snapshots. They are duplicated if the same person appears in another Case.                            |
| Governorates & courts   | Egypt Governorates, Courts, and Court Circuits are global seeded reference data. Case court selection is filtered by Governorate.                                        |
| Case access             | Employee visibility/actions are permission- and assignment-scoped per Case and, where needed, per Hearing / Service of Process / Meeting / Task.                         |
| Service of Process      | A first-class scheduled Case activity with court, date/time, assignee, status, notes, attachments, and result.                                                           |
| Calendar                | Firm Admin sees firm-wide scheduled work allowed by their account permissions. Employee sees only assigned/authorized scheduled work.                                    |
| Finance                 | Case fee + payment tracking only: agreed fee, paid, remaining, payment records, firm collected revenue, outstanding receivables. No invoices or expenses in v2.0.        |
| Subscription suspension | No automated read-only suspension or dunning rule. Subscription status does not automatically convert the workspace into read-only mode.                                 |
| AI / RAG                | Removed from v2.0 scope. No AI/RAG requirements are implied by this PRD.                                                                                                 |
| Mobile                  | Firm-user mobile app remains in scope and must enforce the same permissions and assignment filters as web.                                                               |
| Localization            | English and Arabic UI with RTL support remains required.                                                                                                                 |

## **0.1 Explicit overrides from v1.0**

| **v1.0 logic being replaced**                                     | **v2.0 replacement**                                                                                                                             |
|-------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| Separate Lawyer / Secretary / Assistant / Accountant system roles | Single Employee account type + professional classification + explicit permissions.                                                               |
| Firm Admin always has irrevocable full CRUD                       | Firm Admin permissions are assigned and adjustable by Super Admin. A recommended full-management template may be used, but it is not hard-coded. |
| Reusable tenant-wide Client and Opponent registries               | Client/Opponent are embedded case-local records and are not shared across cases.                                                                 |
| Per-firm court reference data                                     | Global seeded Governorate -\> Court -\> Circuit hierarchy shared as read-only reference data.                                                    |
| Case team role assignment grants broad module access              | Granular case access grants and activity-specific assignments control effective access.                                                          |
| Document access levels: Tenant / Entity / Restricted / Owner      | Case-scoped document capabilities: view / upload / edit metadata / manage / download, plus activity-level context.                               |
| Invoices + expenses finance module                                | Simplified case fee and payment ledger only.                                                                                                     |
| Payment failure -\> read-only suspended workspace                 | Removed. Subscription status and firm activation are operator-controlled without an automatic read-only state.                                   |
| AI/RAG modules and AI credit metering                             | Removed from current scope.                                                                                                                      |

# **1. Executive Summary**

Hoqooq is a multi-tenant Legal Practice Management Platform for law firms. The v2.0 product centers the Case as the primary workspace and combines case information, case-local client/opponent data, documents, hearings, service of process, client meetings, tasks, calendar scheduling, granular employee access, and case-level financial tracking in one secure system.

The platform is operator-controlled. A fixed Super Admin account is seeded with the application. The Super Admin provisions law firms, creates each Firm Admin account, controls plans/subscriptions and activation/status, and may assign the Firm Admin permission set. The Super Admin may inspect account metadata but must not enter privileged legal case content.

Inside a firm, the Firm Admin configures their profile, creates Employees, assigns employee job classifications and permissions, creates Cases, grants selective case access, and coordinates legal work. Employees use the same functional UI patterns but see only the cases, activities, documents, meetings, tasks, and financial data they have been explicitly allowed to access.

## **1.1 Product principles**

- Case-centric operations: legal work is organized around the Case, not around separate global client/opponent records.

- Least privilege by default: an Employee receives only the minimum base permission and case/activity scope needed for their work.

- Professional qualification matters: legal assignment to a Case or Hearing is filtered by the Lawyer specialization matching the Case Type.

- One schedule: Hearings, Service of Process, Client Meetings, and due Tasks appear on a unified calendar according to visibility scope.

- Financial clarity without accounting-suite complexity: v2.0 tracks agreed case fees, payments, collected revenue, and outstanding amounts.

- Operator privacy boundary: Super Admin controls the SaaS but does not access substantive firm legal records.

## **1.2 Stakeholder value**

| **Stakeholder**              | **Value**                                                                                                                                                   |
|------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Super Admin                  | Centralized firm onboarding, Firm Admin provisioning, plans/subscriptions, account status, and employee metadata visibility without legal-content access.   |
| Firm Admin                   | Full operational control to the extent of permissions assigned by Super Admin: employees, cases, granular delegation, calendar, notifications, and finance. |
| Lawyer Employee              | A focused view of matching and assigned legal matters, hearings, documents, tasks, and meetings with no unrelated firm data.                                |
| Secretary / Support Employee | Case-specific access to scheduling, client/opponent information, document upload, service-of-process tracking, and tasks only where granted.                |
| Accountant Employee          | Access to case finance or firm financial dashboard only when explicitly granted; job title alone grants no data access.                                     |

# **2. Product Scope & Objectives**

## **2.1 In scope for v2.0**

- Seeded Super Admin authentication and platform dashboard.

- Firm creation and Firm Admin account creation by Super Admin.

- Firm Admin permission assignment by Super Admin.

- Plan catalog, subscription assignment, activation/status, renewal dates, and subscription history managed by Super Admin.

- Employee creation/management by Firm Admin, with base permissions and professional classification.

- Lawyer specialization management aligned to Case Types.

- Case creation, case lifecycle, case-local Client and optional Opponent information.

- Global seeded Egypt Governorate -\> Court -\> Court Circuit reference hierarchy and dependent filtering.

- Case-specific Employee access grants with action-level capabilities.

- Hearings, Service of Process, Client Meetings, Tasks, Documents, Calendar, Notifications, Case Timeline.

- Simplified case finance: agreed fee, payments, paid/remaining, firm collected revenue and outstanding receivables.

- Firm/user profile settings and appearance preferences.

- Web and mobile experiences for Firm Admin and Employees using the same authorization rules.

- English/Arabic localization with RTL support, audit logging, tenant isolation, and security controls.

## **2.2 Out of scope for v2.0**

- AI assistant, RAG, embeddings, AI document processing, or AI credit metering.

- Public self-registration or self-service firm creation.

- Client login or client portal.

- Public lawyer marketplace, ratings, or consultation booking.

- Invoice lifecycle, invoice line items, firm expense accounting, payroll, or general ledger.

- Automated subscription dunning or automatic read-only firm suspension.

- Deep court-system integration, government APIs, electronic filing, or e-signature.

- Cross-case reusable Client/Opponent master records.

## **2.3 Primary success criteria**

| **Objective**             | **Success measure**                                                                                                      |
|---------------------------|--------------------------------------------------------------------------------------------------------------------------|
| Safe delegation           | An Employee cannot discover or act on a Case unless effective permissions or a specific activity assignment allow it.    |
| Correct lawyer assignment | The lawyer picker excludes lawyers whose specialization does not include the Case Type.                                  |
| Correct court filtering   | After selecting a Governorate, only Courts belonging to it are selectable; Circuit options depend on the selected Court. |
| Daily operational clarity | Firm Admin sees all authorized firm activities; each Employee sees only their own assigned/authorized work.              |
| Financial clarity         | Paid and remaining amounts reconcile to payment records; firm totals equal the sum of authorized case finance data.      |
| Privacy boundary          | Super Admin can manage tenant/account metadata without access to case/client/opponent/document content.                  |

# **3. Actors, Accounts & Professional Profiles**

## **3.1 Exactly three account types**

| **Account type** | **Scope**         | **Created by** | **Core responsibility**                                                                       |
|------------------|-------------------|----------------|-----------------------------------------------------------------------------------------------|
| SUPER_ADMIN      | Global platform   | Seeder         | Operate SaaS: firms, Firm Admins, plans/subscriptions, activation/status, account metadata.   |
| FIRM_ADMIN       | One firm / tenant | Super Admin    | Run the firm according to assigned permissions; create Employees and manage legal operations. |
| EMPLOYEE         | One firm / tenant | Firm Admin     | Perform only explicitly permitted and assigned work.                                          |

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>Important distinction<br />
</strong>Lawyer, Secretary, Accountant, Assistant, and Other are not system roles. They are professional/job classifications stored on a Firm Admin or Employee profile. Authorization is permission-driven.</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

## **3.2 Professional profile**

| **Field**                    | **Applies to**             | **Rule**                                                                                    |
|------------------------------|----------------------------|---------------------------------------------------------------------------------------------|
| job_classification           | Firm Admin / Employee      | LAWYER, SECRETARY, ACCOUNTANT, ASSISTANT, OTHER.                                            |
| specializations              | Users classified as LAWYER | One or more Case Types; required before the user can be assigned as a lawyer.               |
| display_name / profile image | Firm Admin / Employee      | Editable personal presentation fields.                                                      |
| email / phone                | Firm Admin / Employee      | Account identity/contact fields subject to verification and admin controls.                 |
| language / theme             | Firm Admin / Employee      | User preference: EN/AR and Light/Dark/System.                                               |
| account status               | All accounts               | ACTIVE / INACTIVE; status is administration metadata and separate from subscription status. |

## **3.3 Creation responsibility**

- The Super Admin creates a Firm and its Firm Admin account and may create Employees for an explicitly selected Firm. A Super Admin must never create another Super Admin through an ordinary user-management flow.

- At Firm Admin creation, the Super Admin assigns the Firm Admin account-level permission set and may set their professional classification. If classified as Lawyer, specialization(s) are recorded.

- The Firm Admin creates Employees only for their own Firm. During Employee creation, the Firm Admin sets job classification, base permissions, and - for Lawyers - specialization(s).

- Super Admin may view and update Employee metadata/status, including Employees they created, and may activate/deactivate the account status, but does not assign Employee case permissions.

# **4. Legal Terminology & Global Reference Data**

## **4.1 Core legal terminology**

| **Arabic** | **English**        | **v2.0 definition**                                                                                                              |
|------------|--------------------|----------------------------------------------------------------------------------------------------------------------------------|
| قضية       | Case               | Primary legal workspace. Contains legal details, embedded client/opponent data, documents, activities, permissions, and finance. |
| عميل       | Client             | Case-local client snapshot. No login; not reused across Cases.                                                                   |
| خصم        | Opponent           | Optional case-local opposing-party snapshot. No login; not reused across Cases.                                                  |
| محافظة     | Governorate        | Global seeded Egyptian governorate used to filter Courts.                                                                        |
| محكمة      | Court              | Global seeded court belonging to exactly one Governorate.                                                                        |
| دائرة      | Court Circuit      | Global seeded child of a Court.                                                                                                  |
| جلسة       | Hearing            | Scheduled court session belonging to exactly one Case.                                                                           |
| إعلان      | Service of Process | Scheduled case activity for official legal notification/service, with court, assignee, status, documents, and result.            |
| موعد عميل  | Client Meeting     | Scheduled meeting associated with the Case and its embedded Client.                                                              |
| مهمة       | Task               | Internal work item tied to a Case/activity with assignee, due date/time, priority, and status.                                   |
| مستند      | Document           | File stored under a Case and accessible according to case/document capabilities.                                                 |

## **4.2 Case Types and lawyer specializations**

Case Types are global seeded/reference values. The initial catalog should support common practice areas and may be extended through controlled platform configuration. The Case Type is the source of truth for lawyer assignment filtering.

| **Seeded Case Type (initial)** | **Example use**                                 |
|--------------------------------|-------------------------------------------------|
| CRIMINAL                       | Criminal matters and hearings.                  |
| CIVIL                          | Civil disputes and claims.                      |
| COMMERCIAL                     | Commercial/business disputes.                   |
| FAMILY                         | Family/personal-status matters.                 |
| LABOR                          | Employment/labor matters.                       |
| ADMINISTRATIVE                 | Administrative/government disputes.             |
| OTHER                          | Fallback for matters outside seeded categories. |

## **4.3 Governorate -\> Court -\> Circuit hierarchy**

- Governorates, Courts, and Circuits are global seeded reference data, not tenant-created data.

- Every Court belongs to exactly one Governorate.

- Every Circuit belongs to exactly one Court.

- When a user selects a Governorate, the Court selector must display only Courts in that Governorate.

- When a Court is selected, the Circuit selector must display only Circuits under that Court.

- Firm users cannot create arbitrary courts/circuits in v2.0; this avoids inconsistent duplicates across firms.

# **5. Authorization & Permission Model**

v2.0 replaces broad role-based access with a layered permission model. System account type answers who the account is; professional classification answers what the person does; permissions and assignments answer what the person may see or do.

## **5.1 Permission layers**

| **Layer**                              | **Assigned by**                 | **Purpose**                                                             | **Example**                                        |
|----------------------------------------|---------------------------------|-------------------------------------------------------------------------|----------------------------------------------------|
| Account-level permissions - Firm Admin | Super Admin                     | Defines which firm modules/actions the Firm Admin may use.              | case.manage, employee.manage, finance.firm.read    |
| Base permissions - Employee            | Firm Admin                      | Defines which kinds of actions the Employee is capable of in principle. | documents.upload, hearing.view, task.update        |
| Case-specific access grant             | Firm Admin                      | Scopes Employee capabilities to one Case.                               | Case A: view case + upload documents only          |
| Activity assignment                    | Firm Admin / authorized manager | Assigns responsibility for one Hearing / Service / Meeting / Task.      | Attend Hearing H-003                               |
| Professional constraint                | Profile data                    | Restricts legal assignments regardless of permissions.                  | Criminal case -\> Criminal-specialized lawyer only |

## **5.2 Effective permission rule**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>Effective access formula<br />
</strong>For an Employee, effective access is the intersection of: tenant membership + ACTIVE account + base permission + case-specific grant, with any required professional specialization constraint. A specific activity assignment may add only the minimum contextual read access required to perform that activity; it does not grant broad Case access.</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

## **5.3 Case-specific capability model**

| **Case area**              | **Capabilities**                                                                  |
|----------------------------|-----------------------------------------------------------------------------------|
| Case core                  | case.view, case.edit, case.status.manage                                          |
| Client snapshot            | client.view, client.edit                                                          |
| Opponent snapshot          | opponent.view, opponent.edit                                                      |
| Documents                  | document.view, document.download, document.upload, document.edit, document.manage |
| Hearings                   | hearing.view, hearing.create, hearing.edit, hearing.assign, hearing.complete      |
| Service of Process         | service.view, service.create, service.edit, service.assign, service.complete      |
| Client Meetings            | meeting.view, meeting.create, meeting.edit, meeting.assign, meeting.complete      |
| Tasks                      | task.view, task.create, task.assign, task.update, task.complete                   |
| Finance                    | finance.view, finance.payment.record, finance.manage                              |
| Case access administration | case.access.manage                                                                |

## **5.4 Examples**

| **Employee**    | **Case grant / assignment**                             | **Expected result**                                                                                                             |
|-----------------|---------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
| Lawyer Ahmed    | Case A: case.view + document.view; assigned Hearing \#3 | Can read Case A basics/docs and Hearing \#3; cannot edit case or view finance.                                                  |
| Secretary Sara  | Case A: case.view + client.edit + document.upload       | Can update case-local Client data and upload Case A documents; cannot attend/manage hearing unless separately granted/assigned. |
| Lawyer Omar     | Hearing \#4 assignment only                             | Receives minimum context for Hearing \#4; no general document/finance access. Lawyer specialization must match Case Type.       |
| Accountant Ali  | Case A: finance.view + finance.payment.record           | Can view and record Case A payments; cannot see unrelated Case A documents unless granted.                                      |
| Accountant Mona | Base finance.firm.read                                  | Can access firm financial dashboard across all cases only if Firm Admin grants the firm-wide finance permission.                |

# **6. Functional Requirements**

## **6.1 Super Admin Workspace**

### **6.1.1 Super Admin Dashboard**

| **Feature**               | **Requirement**                                                                                                       |
|---------------------------|-----------------------------------------------------------------------------------------------------------------------|
| Seeded login              | Exactly one bootstrap Super Admin account is created idempotently by seeding. No public signup.                       |
| Firm registry             | List/search firms with name, Firm Admin, plan, subscription status, activation/status, creation date, employee count. |
| Firm details              | View firm metadata and employee account metadata/status only. No legal Case content.                                  |
| Firm creation             | Create the Firm and its first Firm Admin in one controlled workflow.                                                  |
| Firm Admin permissions    | Assign/edit the Firm Admin account-level permission set.                                                              |
| User status oversight     | View and update account status metadata for Firm Admin/Employees without touching case permissions.                   |
| Plan/subscription control | Create/edit plans; attach plan; set billing cycle, dates, subscription status, activation.                            |
| Audit                     | All provisioning, permission, plan, activation, and status changes are audit logged.                                  |

### **6.1.2 Plan & Subscription Management**

| **Feature**     | **Requirement**                                                                                                                                          |
|-----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| Plan catalog    | Plan name, description, price, monthly/yearly billing cycle options, employee limit, storage limit, enabled modules if used.                             |
| Subscription    | One current subscription record per Firm plus immutable history of changes.                                                                              |
| Status          | Recommended statuses: PENDING, ACTIVE, EXPIRED, CANCELLED. No SUSPENDED state is required in v2.0.                                                       |
| Activation      | Super Admin explicitly activates the subscription/firm as part of operator workflow.                                                                     |
| Expiry behavior | Subscription expiry updates subscription status and notifications; it does not automatically place the workspace into read-only mode.                    |
| Firm status     | Firm ACTIVE/INACTIVE is a separate operator-controlled flag; any access blocking caused by INACTIVE is an explicit operator action, not payment dunning. |

## **6.2 Firm Admin Workspace**

### **6.2.1 First login, profile & appearance**

- Firm Admin logs in using the account provisioned by Super Admin.

- On first use, Firm Admin can complete personal profile fields and profile image/avatar.

- Appearance settings: Light / Dark / System theme, preferred language EN/AR, and RTL automatically when Arabic is selected.

- Firm profile fields may include firm display name, logo, address, phone, email, and general notes if the Firm Admin has firm.profile.manage.

- Professional profile may mark the Firm Admin as Lawyer and store specialization(s). Super Admin controls this administrative classification; the Firm Admin may view it but should not self-escalate specialization without authorized edit flow.

### **6.2.2 Employee Management**

| **Feature**           | **Requirement**                                                                                                 |
|-----------------------|-----------------------------------------------------------------------------------------------------------------|
| Employee directory    | List/search/filter Employees by name, job classification, lawyer specialization, status.                        |
| Create Employee       | Firm Admin creates the account, sets contact details, job classification, base permissions, and initial status. |
| Lawyer fields         | If job classification = LAWYER, one or more specialization values are mandatory.                                |
| Permission assignment | Firm Admin grants/revokes Employee base permissions; changes apply immediately and are audited.                 |
| Status                | Firm Admin may activate/deactivate an Employee within the firm, subject to account-management permission.       |
| No implicit access    | Creating an Employee or choosing a job classification does not automatically grant Case visibility.             |

### **6.2.3 Case Management**

The Case is the central unit of legal work. Firm Admin can create and manage Cases only if their Super Admin-assigned permission set allows the relevant action.

| **Case area**          | **Required behavior**                                                                                                             |
|------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| Core identification    | Internal case reference, court case number/year if applicable, title/subject, Case Type, status, opening date, description/notes. |
| Jurisdiction           | Select Governorate first, then filtered Court, then optional/required Circuit depending on Court configuration.                   |
| Client                 | Client information is entered directly inside the Case and stored as a case-local snapshot.                                       |
| Opponent               | Opponent section is optional. It is stored inside the Case; the UI may allow one or more opponent entries.                        |
| Default responsibility | Firm Admin is the default Case owner/responsible administrator, subject to their account permissions.                             |
| Legal assignment       | Lawyers assigned to the Case must have a specialization containing the Case Type.                                                 |
| Case team / access     | Firm Admin grants each Employee selected case capabilities; no broad team role automatically grants all Case content.             |
| Associations           | Case contains Documents, Hearings, Service of Process, Client Meetings, Tasks, Finance, and Timeline.                             |

### **6.2.4 Case Documents**

- Every document is stored under exactly one Case in v2.0.

- Document metadata: category/type, filename, description, upload date, uploader, version, optional activity link (Hearing or Service of Process).

- Document visibility/actions are controlled by the Employee base permission plus Case-specific document grant.

- Document version history should be preserved when replacing/updating a file.

- Standard users archive rather than physically delete legal documents; destructive purge is administrative/retention behavior outside normal UI.

### **6.2.5 Hearings**

| **Field / feature**    | **Requirement**                                                                                                    |
|------------------------|--------------------------------------------------------------------------------------------------------------------|
| Case link              | Every Hearing belongs to exactly one Case.                                                                         |
| Schedule               | Date, time, Court, optional Circuit, hearing type, judge if known.                                                 |
| Court consistency      | Hearing Court/Circuit must be valid for the Case Governorate/Court hierarchy; the UI may default from Case values. |
| Assigned lawyer        | Optional at creation. When assigned, only Lawyers whose specialization includes the Case Type may be selected.     |
| Status                 | SCHEDULED, COMPLETED, ADJOURNED, CANCELLED.                                                                        |
| Outcome                | Completion stores outcome/notes and may attach Hearing Minutes/documents.                                          |
| Next hearing           | Adjournment/completion may create or suggest the next Hearing date.                                                |
| Calendar/notifications | Hearing creates a calendar item and assignment/day-of notifications for authorized users.                          |

### **6.2.6 Service of Process**

| **Field / feature**    | **Requirement**                                                                                                                                                                |
|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Case link              | Every Service of Process record belongs to exactly one Case.                                                                                                                   |
| Schedule               | Court, date, time, service/recipient details as applicable, assigned Employee/Lawyer, notes.                                                                                   |
| Status                 | SCHEDULED, COMPLETED, FAILED, RESCHEDULED, CANCELLED.                                                                                                                          |
| Assignee               | Default operational owner is Firm Admin where appropriate; another Employee may be assigned. Lawyer assignment, if used as legal counsel, must match Case Type specialization. |
| Attachments            | Supporting documents/proof of service can be attached to the Case activity.                                                                                                    |
| Result                 | Completion/failure records result, notes, and completion timestamp.                                                                                                            |
| Calendar/notifications | Creates a calendar event and assignment/day-of notifications.                                                                                                                  |

### **6.2.7 Client Meetings**

| **Field / feature**    | **Requirement**                                                                                               |
|------------------------|---------------------------------------------------------------------------------------------------------------|
| Case link              | Every Client Meeting belongs to exactly one Case because the Client is case-local.                            |
| Schedule               | Date, time, location/method, subject/purpose, assigned Employee(s), notes.                                    |
| Status                 | SCHEDULED, COMPLETED, CANCELLED, RESCHEDULED.                                                                 |
| Outcome                | Authorized assignee may add meeting notes/outcome according to permissions.                                   |
| Visibility             | Firm Admin sees firm-wide authorized meetings; Employee sees meetings assigned to them or explicitly granted. |
| Calendar/notifications | Meeting appears on unified calendar and generates assignment/day-of notification.                             |

### **6.2.8 Tasks**

| **Feature**            | **Requirement**                                                                                            |
|------------------------|------------------------------------------------------------------------------------------------------------|
| Creation               | Title, description, priority, due date/time, status, Case, optional linked activity.                       |
| Assignment             | One primary assignee; optional collaborators if implemented.                                               |
| Status                 | NEW, IN_PROGRESS, WAITING, COMPLETED, CANCELLED.                                                           |
| Scope                  | Task visibility is limited to assigned/authorized users and the Firm Admin subject to account permissions. |
| Completion             | Assignee can update status/add completion note if task.update/task.complete is effective.                  |
| Dashboard/notification | Due-today and overdue tasks surface on dashboard and notification page.                                    |

### **6.2.9 Calendar**

- Month, week, and day views.

- Event types: Hearing, Service of Process, Client Meeting, Task Due Date.

- Firm Admin calendar shows all events they are permitted to view across the firm.

- Employee calendar shows only events assigned to them or Case activities they are explicitly authorized to view.

- Clicking an event opens only the detail fields permitted by effective permissions.

- Scheduling conflict warnings should be shown for the same Employee assigned to overlapping time-bound activities.

### **6.2.10 Notifications**

- Notification center exists for Firm Admin and Employees.

- Immediate notifications: assignment, reassignment, material schedule change, permission/access grant or revoke where user action is affected.

- Daily notifications: today’s assigned Hearings, Service of Process, Client Meetings, and due Tasks.

- Employees receive only notifications for records they can access; notification payload must not leak hidden Case content.

- Notification read/unread status is stored per user.

- Additional reminder windows may be configurable later; v2.0 does not hard-code the old 24h/1h rule as a mandatory invariant.

### **6.2.11 Finance Dashboard**

| **Feature**          | **Requirement**                                                                                                                               |
|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| Case agreed fee      | Store the total agreed fee for the Case.                                                                                                      |
| Payments             | Record amount, date, method, optional reference, notes, and recorder.                                                                         |
| Calculated paid      | Sum valid payment records for the Case.                                                                                                       |
| Calculated remaining | max(agreed fee - paid, 0), with validation preventing inconsistent overpayment unless later explicitly supported.                             |
| Case finance view    | Show agreed, paid, remaining, payment history.                                                                                                |
| Firm dashboard       | Total case value, total collected revenue, total outstanding receivables, paid/unpaid/partial case counts.                                    |
| Accountant access    | Job classification ACCOUNTANT grants no automatic access. Firm Admin must explicitly grant case finance permissions and/or finance.firm.read. |
| No invoices/expenses | Invoice, line-item, expense, tax, and accounting-ledger workflows are removed from v2.0.                                                      |

### **6.2.12 Settings**

- Personal information and profile image/avatar.

- Language EN/AR and RTL behavior.

- Appearance: Light / Dark / System.

- Password/security settings.

- Firm profile settings when firm.profile.manage is granted.

- Employee administrative data and specializations are changed only through authorized employee-management flows, not self-escalation.

## **6.3 Employee Workspace**

The Employee interface should reuse the same navigation patterns and components as the Firm Admin workspace where practical. The difference is data scope and available actions, not a completely separate product.

| **Area**                      | **Employee behavior**                                                                                                             |
|-------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| Dashboard                     | Only assigned/authorized Cases, today activities, due Tasks, and permitted financial widgets.                                     |
| Cases                         | Only Cases where a Case grant or activity-derived minimum context exists. Actions shown only if effective permissions allow them. |
| Hearings / Service / Meetings | Only assigned or explicitly visible activities.                                                                                   |
| Documents                     | Only documents inside accessible Cases and according to document capabilities.                                                    |
| Calendar                      | Only assigned/authorized calendar events.                                                                                         |
| Notifications                 | Only relevant assignments, changes, and today work.                                                                               |
| Finance                       | Hidden unless finance permissions are effective. Firm-wide totals require finance.firm.read.                                      |
| Settings                      | Own profile, language, theme, password; no self-edit of elevated permissions or lawyer specialization unless explicitly allowed.  |

## **6.4 Mobile Application**

The Flutter mobile application remains a client of the same tenant-scoped API and permission engine. It must not introduce a weaker authorization path.

| **Feature**                   | **Requirement**                                                                                          |
|-------------------------------|----------------------------------------------------------------------------------------------------------|
| Authentication                | Same account/session rules as web. Optional biometric unlock may protect a locally stored session token. |
| Dashboard                     | Today’s assigned activities, tasks, notifications.                                                       |
| Cases                         | View/update only assigned/authorized Case sections.                                                      |
| Hearings / Service / Meetings | View schedule and update outcome/status only when permitted.                                             |
| Documents                     | View/upload according to Case document grants. Camera capture may be used as an upload source.           |
| Calendar                      | Filtered to the same effective scope as web.                                                             |
| Finance                       | Visible only when effective finance permissions exist.                                                   |
| Localization                  | Full EN/AR and RTL parity.                                                                               |

# **7. Business Rules**

The following rules are normative and testable. Where a rule says MUST, server-side enforcement is required. UI filtering improves usability but is never the security boundary.

## **7.1 Identity, Provisioning & Tenancy**

**BR-001 Seeded Super Admin**

| **Statement**                                                                                                                           | **Rationale**                                                                    |
|-----------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| Exactly one bootstrap Super Admin account MUST be created idempotently by application seeding. Public self-registration MUST NOT exist. | The platform is operator-controlled and must have a deterministic owner account. |

- The seeder may run repeatedly without creating duplicate Super Admin accounts.

- Super Admin is global and is not attached to a tenant.

- Credentials/secrets must not be hard-coded in source control; deployment secret injection is required.

**BR-002 Exactly Three Account Types**

| **Statement**                                                                                                    | **Rationale**                                                                        |
|------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| The authentication/authorization domain MUST expose only SUPER_ADMIN, FIRM_ADMIN, and EMPLOYEE as account types. | Separates security identity from job classification and prevents role proliferation. |

- LAWYER, SECRETARY, ACCOUNTANT, ASSISTANT, OTHER are professional classifications, not account types.

- Account-type checks alone are insufficient to authorize tenant operations; explicit permissions are also required.

**BR-003 Firm & Firm Admin Provisioning**

| **Statement**                                                                                                           | **Rationale**                                   |
|-------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------|
| A Firm and its initial Firm Admin account are created by Super Admin. Super Admin may also create Employees only after explicitly selecting the target Firm; an ordinary user flow must never create a Super Admin. | Supports operator-led staffing while preserving explicit tenant ownership and platform-privilege boundaries. |

- Firm creation issues a unique tenant_id.

- Firm Admin is bound to exactly one tenant.

- Provisioning must be atomic: no orphan Firm or Firm Admin is left if the workflow fails.

- Super Admin assigns the Firm Admin account-level permissions during or after provisioning.

**BR-004 Firm Admin Permission Assignment**

| **Statement**                                                                                                                  | **Rationale**                                                                                |
|--------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| The Firm Admin permission set is assigned and may be changed by Super Admin. The old rule of irrevocable full CRUD is removed. | Allows the operator to configure which tenant-management capabilities a Firm Admin receives. |

- Permission changes are audit logged.

- Firm Admin cannot grant themselves permissions not already granted to their account.

- A recommended full-management template may exist, but it is not a hard-coded invariant.

**BR-005 Employee Creation & Management**

| **Statement**                                                                                                                                                            | **Rationale**                                               |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------|
| Employees belong to exactly one Firm and are created/managed by the Firm Admin, an authorized tenant user, or Super Admin acting for an explicitly selected Firm. | Supports operator-led staffing while preserving explicit tenant ownership. |

- Employee creation requires job classification.

- Employee base permissions are explicitly selected; no job classification auto-grants data access.

- Employee access ends immediately when account status becomes INACTIVE.

**BR-006 Professional Classification & Lawyer Specialization**

| **Statement**                                                                                                                                                | **Rationale**                                                       |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| If a Firm Admin or Employee is classified as LAWYER, at least one lawyer specialization MUST be recorded from the Case Type catalog before legal assignment. | Assignment must reflect the lawyer field requested by the business. |

- A Lawyer may have multiple specializations.

- Non-lawyer classifications do not carry lawyer specializations.

- Changing specialization must not retroactively invalidate historical assignments; future assignment/edit validation uses the current specialization set and warnings should identify mismatches.

**BR-007 Tenant Isolation**

| **Statement**                                                                                                                   | **Rationale**                                   |
|---------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------|
| Every tenant-owned record MUST carry tenant_id and all reads/writes MUST be tenant-scoped. Cross-tenant references are invalid. | Legal data from different firms must never mix. |

- Super Admin platform metadata queries are global but legal-content endpoints remain tenant-protected.

- Cross-tenant entity IDs should return not-found/forbidden without leaking existence.

- Automated no-leak tests must cover Cases, Documents, Activities, Payments, Notifications, and permissions.

## **7.2 Authorization & Assignment**

**BR-008 Effective Employee Permission**

| **Statement**                                                                                                                                                                              | **Rationale**                                           |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------|
| An Employee operation succeeds only when the account is active, tenant matches, required base permission exists, required Case grant exists, and any professional constraint is satisfied. | Prevents broad access from job titles or UI visibility. |

- Backend checks are mandatory for every protected operation.

- Revoking either base permission or Case grant removes effective access immediately.

- Firm Admin operations are similarly constrained by the permissions assigned by Super Admin.

**BR-009 Case-Specific Access Grants**

| **Statement**                                                                       | **Rationale**                                                                                                |
|-------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| Employee access to a Case MUST be expressed as explicit capabilities for that Case. | The business requires a secretary to upload documents, one lawyer to view, another to attend a hearing, etc. |

- A Case grant may contain any subset of Case capabilities.

- Granting case.view does not imply document.view, finance.view, or edit rights.

- Case access grants are created/revoked only by a user with case.access.manage for that Case/firm.

- Grant/revoke events are audit logged.

**BR-010 Activity-Specific Assignment**

| **Statement**                                                                                                                      | **Rationale**                                                       |
|------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------|
| Hearings, Service of Process, Client Meetings, and Tasks MAY be assigned to specific Employees independently of broad Case access. | Allows responsibility to be delegated at the exact work-item level. |

- An assignee can see the assigned activity and the minimum Case context necessary to perform it.

- Activity assignment alone does not reveal unrelated documents, finance, opponent details, or other activities.

- Reassignment must notify affected users and be audit logged.

**BR-011 Assignment-Derived Minimum Context**

| **Statement**                                                                                                                                           | **Rationale**                                                                     |
|---------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| When a user is assigned a single Case activity without broader Case access, the system MUST expose only the contextual fields needed for that activity. | An assignment must be actionable without accidentally granting whole-case access. |

- Minimum context may include Case reference/title, client display name if required, court, date/time, and activity notes explicitly shared for the assignment.

- Download or document visibility still requires document.view or an explicitly attached/shared activity document policy.

## **7.3 Cases, Client & Opponent**

**BR-012 Case-Local Client & Opponent**

| **Statement**                                                                                                                                       | **Rationale**                                                        |
|-----------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------|
| Client and Opponent information MUST be stored inside the Case as Case-owned records and MUST NOT be reused as a shared firm master record in v2.0. | This is an explicit replacement of the previous reusable registries. |

- Every Case contains one required Client snapshot.

- Opponent information is optional; the implementation may support multiple opponents within the Case.

- Creating a second Case for the same real-world person creates a separate Client/Opponent snapshot.

- Changing one Case snapshot does not automatically update another Case.

**BR-013 Case Type Is Required**

| **Statement**                                                                        | **Rationale**                                               |
|--------------------------------------------------------------------------------------|-------------------------------------------------------------|
| Every active Case MUST have exactly one Case Type from the global Case Type catalog. | Case Type drives legal classification and lawyer filtering. |

- Case Type is required before assigning a Lawyer.

- Changing Case Type must revalidate existing lawyer assignments and present mismatch warnings requiring resolution.

**BR-014 Lawyer Assignment Must Match Case Type**

| **Statement**                                                                                         | **Rationale**                                     |
|-------------------------------------------------------------------------------------------------------|---------------------------------------------------|
| A user assigned as a Lawyer to a Case or Hearing MUST have the Case Type in their specialization set. | Ensures assignment according to the lawyer field. |

- Lawyer pickers must be filtered before selection.

- Backend validation must reject a mismatching lawyer even if the client UI is bypassed.

- Non-lawyer work assignments are not blocked by Case Type unless the activity explicitly requires a Lawyer.

**BR-015 Firm Admin as Default Case Owner**

| **Statement**                                                                                                                                                                                            | **Rationale**                                                          |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| On Case creation, the creating Firm Admin is the default responsible Case owner/administrator when they have required Case permissions. This does not automatically make them the legal assigned Lawyer. | Separates operational ownership from professional legal qualification. |

- If the Firm Admin is a Lawyer and their specialization matches the Case Type, the UI may offer or default them as assigned Lawyer.

- If specialization does not match, they remain administrative owner but are not valid as the legal assignee.

- Case creation may proceed without another Lawyer if the business workflow allows; any later lawyer-required activity must satisfy BR-014.

**BR-016 Case Lifecycle & Preservation**

| **Statement**                                                                                             | **Rationale**                                            |
|-----------------------------------------------------------------------------------------------------------|----------------------------------------------------------|
| Cases MUST support a controlled lifecycle and MUST not be physically deleted through normal user actions. | Legal matters require traceable historical preservation. |

- Recommended statuses: DRAFT, ACTIVE, CLOSED, ARCHIVED.

- Status changes are written to the Case timeline.

- Archived Cases are excluded from default active views but remain retrievable by authorized users.

## **7.4 Governorates, Courts & Circuits**

**BR-017 Global Seeded Judicial Reference Data**

| **Statement**                                                                                             | **Rationale**                                                    |
|-----------------------------------------------------------------------------------------------------------|------------------------------------------------------------------|
| Governorates, Courts, and Circuits MUST be global seeded reference data rather than tenant-owned records. | Ensures consistent court names and supports dependent filtering. |

- Firm users cannot create tenant-specific duplicate Courts/Circuits in v2.0.

- Every Court references one Governorate; every Circuit references one Court.

- Reference data updates are controlled platform data maintenance, not a Firm Admin setting.

**BR-018 Dependent Court Filtering**

| **Statement**                                                                                                                               | **Rationale**                             |
|---------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| Selecting a Governorate MUST restrict Court options to that Governorate, and selecting a Court MUST restrict Circuit options to that Court. | Prevents invalid case/court combinations. |

- Backend validation must reject inconsistent Governorate/Court/Circuit IDs.

- Case and Hearing forms must reuse the same reference data service.

## **7.5 Hearings, Service of Process, Meetings & Tasks**

**BR-019 Hearing Ownership & Schedule**

| **Statement**                                                                              | **Rationale**                   |
|--------------------------------------------------------------------------------------------|---------------------------------|
| Every Hearing MUST belong to exactly one Case and contain a scheduled date/time and Court. | Prevents orphaned court events. |

- Circuit is constrained by the selected Court.

- Assigned Lawyer is optional until business workflow requires one, but any assigned Lawyer must satisfy BR-014.

- Hearing schedule changes update the calendar and notify affected assignees.

**BR-020 Hearing Completion**

| **Statement**                                                                                         | **Rationale**                              |
|-------------------------------------------------------------------------------------------------------|--------------------------------------------|
| Completing a Hearing MUST store an outcome/notes and preserve the Hearing permanently under the Case. | Maintains the legal history of the matter. |

- Hearing Minutes/supporting documents may be attached.

- Adjournment may create/link a next Hearing.

- Historical assignments and timestamps are preserved in audit/timeline data.

**BR-021 Service of Process as First-Class Activity**

| **Statement**                                                                                                                             | **Rationale**                                                                                                          |
|-------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| Service of Process MUST be stored as a schedulable Case activity with Court, date/time, assignee, status, notes, attachments, and result. | The workflow is operationally equivalent to other time-bound legal obligations and must appear in daily work/calendar. |

- Allowed statuses: SCHEDULED, COMPLETED, FAILED, RESCHEDULED, CANCELLED.

- Rescheduling preserves prior schedule history or audit evidence.

- Completion/failure requires result notes or a documented reason.

**BR-022 Client Meeting Is Case-Bound**

| **Statement**                                                                         | **Rationale**                                      |
|---------------------------------------------------------------------------------------|----------------------------------------------------|
| Every Client Meeting MUST belong to one Case and therefore to that Case-local Client. | There is no reusable client master record in v2.0. |

- Meeting has date/time, subject, location/method, assignee, status, notes/outcome.

- Employee visibility follows assignment/case permissions.

**BR-023 Task Assignment**

| **Statement**                                                                                                                       | **Rationale**                                 |
|-------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------|
| Tasks MUST be tenant- and Case-scoped when they concern legal work, with an assignee, status, priority, and optional due date/time. | Provides explicit ownership of internal work. |

- Employees see only their assigned/authorized Tasks.

- Due-today and overdue Tasks surface on dashboard/notifications.

- Task completion may require a completion note if configured.

## **7.6 Calendar & Notifications**

**BR-024 Calendar Visibility Mirrors Authorization**

| **Statement**                                                                                    | **Rationale**                                           |
|--------------------------------------------------------------------------------------------------|---------------------------------------------------------|
| Calendar events MUST be filtered using the same authorization rules as their underlying records. | Calendar must not become an indirect data-leak channel. |

- Firm Admin sees events only within their account permissions.

- Employee sees assigned/authorized events only.

- Event titles/details shown in calendar must not reveal protected information beyond user access.

**BR-025 Daily & Assignment Notifications**

| **Statement**                                                                                                                   | **Rationale**                                                               |
|---------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| The system MUST notify users about newly assigned work, material schedule changes, and their assigned work due/scheduled today. | The notification page is intended to surface the current day’s obligations. |

- Notification records are user-specific with read/unread state.

- No notification may expose hidden Case content.

- Removing access should suppress future notifications for that record.

## **7.7 Documents**

**BR-026 Case-Owned Documents**

| **Statement**                                                                                                        | **Rationale**                                       |
|----------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------|
| Every v2.0 legal document MUST belong to exactly one Case, with optional linkage to a Hearing or Service of Process. | Aligns document access with the Case-centric model. |

- Document access is governed by document capabilities in the Case grant.

- Uploading requires document.upload; editing metadata requires document.edit; deletion/archival requires document.manage.

- Version history should be retained when replacing file content.

## **7.8 Finance**

**BR-027 Case Fee & Payment Ledger**

| **Statement**                                                                                 | **Rationale**                                                                   |
|-----------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| Each Case MAY store an agreed fee and MUST calculate paid/remaining from its payment records. | Provides the requested paid vs unpaid tracking without a full invoicing module. |

- Payment record: amount, paid_at, method, optional reference, note, recorded_by.

- Paid amount = sum of valid non-reversed payment records.

- Remaining amount = agreed_fee - paid_amount, constrained to non-negative unless overpayment is later explicitly supported.

**BR-028 Finance Permission Scope**

| **Statement**                                                                                                                  | **Rationale**                                                          |
|--------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| Finance data is visible only when an explicit finance permission is effective. ACCOUNTANT classification alone grants nothing. | Financial information is sensitive and must be deliberately delegated. |

- Case finance requires Case finance.view/manage grant plus relevant base permission.

- Firm-wide finance totals require finance.firm.read.

- An Employee with case-only finance rights sees totals only for the cases they are allowed to access, not the entire firm.

**BR-029 Firm Financial Aggregates**

| **Statement**                                                                                                                       | **Rationale**                                                      |
|-------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| Firm collected revenue and outstanding receivables MUST be computed from Case fees/payments rather than separately editable totals. | Prevents dashboard numbers from drifting from source transactions. |

- Total Case Value = sum agreed_fee across included Cases.

- Total Collected = sum valid payment amounts across included Cases.

- Total Outstanding = sum max(agreed_fee - paid, 0) across included Cases.

- Filters may include date range, Case Type, lawyer, Court, and payment status when authorized.

## **7.9 Plans, Subscriptions & Status**

**BR-030 Operator-Controlled Subscription State**

| **Statement**                                                                                                                                                         | **Rationale**                                                      |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| Super Admin manages plans, subscription records, activation, and subscription status. Subscription state is not driven by an automatic dunning state machine in v2.0. | Matches the requested operator-controlled plan/subscription model. |

- Recommended subscription states: PENDING, ACTIVE, EXPIRED, CANCELLED.

- Subscription history is retained for audit.

- Plan/limit enforcement, if enabled, must return explicit entitlement errors rather than silently removing data.

**BR-031 No Automatic Read-Only Suspension**

| **Statement**                                                                                                         | **Rationale**                                       |
|-----------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------|
| A subscription expiry/failure MUST NOT automatically place the Firm workspace into the old read-only SUSPENDED state. | The user explicitly removed the firm suspend point. |

- Subscription status may change and generate notifications.

- Any Firm deactivation is a separate explicit Super Admin action using Firm status, not an automatic payment rule.

- The implementation must not preserve BR-012 from v1.0 as hidden middleware behavior.

## **7.10 Security, Audit & Mobile**

**BR-032 Authentication & Server-Side Authorization**

| **Statement**                                                                                       | **Rationale**                                |
|-----------------------------------------------------------------------------------------------------|----------------------------------------------|
| All protected resources MUST require authentication and server-side authorization on every request. | Client-side hidden buttons are not security. |

- Short-lived access tokens and secure refresh/session handling are required.

- Super Admin/Firm Admin MFA is recommended and may remain mandatory if already implemented.

- Permission, tenant, Case grant, and assignment checks occur before returning sensitive data.

**BR-033 Audit Logging**

| **Statement**                                                                                                                    | **Rationale**                                    |
|----------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------|
| Business-critical changes MUST be append-only audited with actor, time, action, entity, and before/after state where applicable. | Supports accountability and legal defensibility. |

- Audit at minimum: account creation/status, permission grants, Case status, assignments, schedule changes, document upload/version, payments, subscription changes.

- Employees cannot edit or delete audit records.

**BR-034 Mobile/API Parity**

| **Statement**                                                                                                  | **Rationale**                                            |
|----------------------------------------------------------------------------------------------------------------|----------------------------------------------------------|
| Mobile MUST use the same tenant, permission, Case grant, specialization, and activity-assignment rules as web. | A second client must not become a weaker security model. |

- No mobile-only privileged endpoint.

- Offline/cache behavior must not expose records after permission revocation beyond reasonable secure cache invalidation policy.

**BR-035 AI/RAG Excluded**

| **Statement**                                                                                      | **Rationale**                              |
|----------------------------------------------------------------------------------------------------|--------------------------------------------|
| No AI/RAG functionality is required, entitled, metered, or referenced by v2.0 acceptance criteria. | The current scope explicitly skips AI/RAG. |

- Existing AI code may remain dormant only if it does not affect v2.0 behavior or data access.

- No UI route, plan entitlement, or business rule should assume AI is available in this release.

# **8. Data Model & Data Dictionary**

This section describes the business data required by v2.0. It is implementation-oriented but not tied to a specific database technology. Every tenant-owned table/entity includes tenant_id, created_at, updated_at, created_by, and updated_by unless explicitly global.

## **8.1 Global entities**

### **users**

| **Field**          | **Type / example**                                         | **Rule**                                                     |
|--------------------|------------------------------------------------------------|--------------------------------------------------------------|
| id                 | UUID                                                       | Primary identifier.                                          |
| account_type       | SUPER_ADMIN / FIRM_ADMIN / EMPLOYEE                        | Exactly three values (BR-002).                               |
| tenant_id          | UUID nullable                                              | NULL only for Super Admin; required for Firm Admin/Employee. |
| email              | string unique                                              | Login identity.                                              |
| password_hash      | secure hash                                                | Never stored plaintext.                                      |
| account_status     | ACTIVE / INACTIVE                                          | Administrative account state.                                |
| job_classification | LAWYER / SECRETARY / ACCOUNTANT / ASSISTANT / OTHER / null | Required for firm users as configured.                       |
| display_name       | string                                                     | User-facing name.                                            |
| profile_image_url  | string nullable                                            | Appearance/profile.                                          |
| preferred_language | EN / AR                                                    | Drives RTL.                                                  |
| theme_preference   | LIGHT / DARK / SYSTEM                                      | Appearance setting.                                          |

### **case_types**

| **Field**           | **Type** | **Rule**                                                        |
|---------------------|----------|-----------------------------------------------------------------|
| id                  | UUID     | Global seeded.                                                  |
| code                | string   | CRIMINAL, CIVIL, etc.                                           |
| label_en / label_ar | string   | Localized labels.                                               |
| is_active           | boolean  | Inactive values remain historical but cannot be newly selected. |

### **lawyer_specializations**

| **Field**    | **Type**           | **Rule**                        |
|--------------|--------------------|---------------------------------|
| user_id      | UUID FK users      | User must be classified LAWYER. |
| case_type_id | UUID FK case_types | One or more rows per lawyer.    |

### **governorates / courts / court_circuits**

| **Entity**     | **Key fields**                                                 | **Rule**                          |
|----------------|----------------------------------------------------------------|-----------------------------------|
| governorates   | id, code, name_en, name_ar, is_active                          | Global seeded.                    |
| courts         | id, governorate_id, name_en, name_ar, type, address, is_active | Court belongs to one Governorate. |
| court_circuits | id, court_id, name_en, name_ar, is_active                      | Circuit belongs to one Court.     |

### **subscription_plans**

| **Field**                    | **Type / notes** | **Rule**                  |
|------------------------------|------------------|---------------------------|
| id                           | UUID             | Global.                   |
| name                         | string           | Plan label.               |
| price_monthly / price_yearly | decimal nullable | Commercial configuration. |
| max_employees                | int nullable     | Optional entitlement.     |
| storage_limit                | numeric nullable | Optional entitlement.     |
| is_active                    | boolean          | Controls new selection.   |

## **8.2 Tenant & account administration**

### **firms**

| **Field**                       | **Type / notes**  | **Rule**                                  |
|---------------------------------|-------------------|-------------------------------------------|
| id                              | UUID              | tenant_id.                                |
| name                            | string            | Firm legal/display name.                  |
| logo_url                        | string nullable   | Branding.                                 |
| contact_email / phone / address | strings           | Firm profile.                             |
| status                          | ACTIVE / INACTIVE | Explicit operator-controlled firm status. |
| current_firm_admin_id           | UUID FK users     | Primary Firm Admin account.               |

### **subscriptions**

| **Field**         | **Type / notes**                       | **Rule**             |
|-------------------|----------------------------------------|----------------------|
| id                | UUID                                   | PK.                  |
| tenant_id         | UUID                                   | Firm.                |
| plan_id           | UUID                                   | Current plan.        |
| billing_cycle     | MONTHLY / YEARLY                       | Commercial choice.   |
| status            | PENDING / ACTIVE / EXPIRED / CANCELLED | No SUSPENDED.        |
| start_at / end_at | date/datetime                          | Subscription period. |
| activated_at      | datetime nullable                      | Explicit activation. |
| changed_by        | UUID Super Admin                       | Audit source.        |

### **user_permissions**

| **Field**       | **Type / notes**  | **Rule**                                             |
|-----------------|-------------------|------------------------------------------------------|
| user_id         | UUID              | Firm Admin or Employee.                              |
| permission_code | string            | Catalog code.                                        |
| granted_by      | UUID              | Super Admin for Firm Admin; Firm Admin for Employee. |
| granted_at      | datetime          | Auditability.                                        |
| revoked_at      | datetime nullable | History retained.                                    |

## **8.3 Case core**

### **cases**

| **Field**                | **Type / notes**                   | **Rule**                                |
|--------------------------|------------------------------------|-----------------------------------------|
| id                       | UUID                               | PK.                                     |
| tenant_id                | UUID                               | Required.                               |
| internal_reference       | string unique within firm          | Human-friendly reference.               |
| court_case_number / year | string/int nullable                | Official court reference if applicable. |
| title                    | string                             | Case label.                             |
| case_type_id             | UUID FK case_types                 | Required when active.                   |
| governorate_id           | UUID FK                            | Required for court-bound matter.        |
| court_id                 | UUID FK                            | Must belong to governorate.             |
| circuit_id               | UUID nullable                      | Must belong to court.                   |
| status                   | DRAFT / ACTIVE / CLOSED / ARCHIVED | Lifecycle.                              |
| opening_date             | date                               | Required when active.                   |
| description / notes      | text                               | General case details.                   |
| owner_firm_admin_id      | UUID                               | Default operational owner.              |
| agreed_fee               | decimal nullable                   | Finance-gated.                          |

### **case_clients**

| **Field**                     | **Type / notes**     | **Rule**                               |
|-------------------------------|----------------------|----------------------------------------|
| case_id                       | UUID unique FK cases | One required client snapshot per Case. |
| client_type                   | INDIVIDUAL / COMPANY | Snapshot type.                         |
| name                          | string               | Required.                              |
| national_id / registration_no | string nullable      | Sensitive.                             |
| phone / email / address       | strings nullable     | Contact fields.                        |
| notes                         | text nullable        | Case-local notes.                      |

### **case_opponents**

| **Field**                       | **Type / notes**     | **Rule**                            |
|---------------------------------|----------------------|-------------------------------------|
| id                              | UUID                 | Supports zero or more opponents.    |
| case_id                         | UUID FK cases        | Case-local.                         |
| opponent_type                   | INDIVIDUAL / COMPANY | Type.                               |
| name                            | string               | Required if opponent record exists. |
| contact / representative fields | nullable strings     | Optional.                           |
| notes                           | text nullable        | Case-local only.                    |

### **case_access_grants**

| **Field**               | **Type / notes**            | **Rule**                        |
|-------------------------|-----------------------------|---------------------------------|
| id                      | UUID                        | PK.                             |
| case_id                 | UUID                        | Case scope.                     |
| user_id                 | UUID Employee               | Grantee.                        |
| capabilities            | set/json or normalized join | Explicit case capability codes. |
| granted_by              | UUID                        | Authorized manager.             |
| granted_at / revoked_at | datetime                    | History.                        |

## **8.4 Case activities**

### **hearings**

| **Field**             | **Type / notes**                              | **Rule**                             |
|-----------------------|-----------------------------------------------|--------------------------------------|
| id                    | UUID                                          | PK.                                  |
| case_id               | UUID                                          | Exactly one Case.                    |
| scheduled_at          | datetime                                      | Required.                            |
| court_id / circuit_id | UUID                                          | Valid hierarchy.                     |
| hearing_type          | string/lookup                                 | Optional configurable type.          |
| judge_name            | string nullable                               | Optional.                            |
| assigned_lawyer_id    | UUID nullable                                 | Must match Case Type specialization. |
| status                | SCHEDULED / COMPLETED / ADJOURNED / CANCELLED | Lifecycle.                           |
| outcome_notes         | text nullable                                 | Required on completion.              |

### **service_of_process**

| **Field**         | **Type / notes**                                         | **Rule**                        |
|-------------------|----------------------------------------------------------|---------------------------------|
| id                | UUID                                                     | PK.                             |
| case_id           | UUID                                                     | Exactly one Case.               |
| court_id          | UUID                                                     | Required if court-related.      |
| scheduled_at      | datetime                                                 | Required for scheduled item.    |
| assigned_user_id  | UUID nullable                                            | Employee/Firm Admin.            |
| recipient_details | text/json nullable                                       | Service target details.         |
| status            | SCHEDULED / COMPLETED / FAILED / RESCHEDULED / CANCELLED | Lifecycle.                      |
| result_notes      | text nullable                                            | Required on completion/failure. |

### **client_meetings**

| **Field**          | **Type / notes**                                | **Rule**                             |
|--------------------|-------------------------------------------------|--------------------------------------|
| id                 | UUID                                            | PK.                                  |
| case_id            | UUID                                            | Client inherited from Case snapshot. |
| scheduled_at       | datetime                                        | Required.                            |
| location_or_method | string                                          | Office / phone / online / other.     |
| subject            | string                                          | Purpose.                             |
| assigned_user_id   | UUID                                            | Primary assignee.                    |
| status             | SCHEDULED / COMPLETED / CANCELLED / RESCHEDULED | Lifecycle.                           |
| outcome_notes      | text nullable                                   | Completion notes.                    |

### **tasks**

| **Field**             | **Type / notes**                                    | **Rule**                |
|-----------------------|-----------------------------------------------------|-------------------------|
| id                    | UUID                                                | PK.                     |
| case_id               | UUID nullable/required for legal work               | Case scope.             |
| linked_entity_type/id | HEARING / SERVICE / MEETING nullable                | Optional activity link. |
| title / description   | string/text                                         | Task content.           |
| assignee_id           | UUID                                                | Primary assignee.       |
| priority              | LOW / NORMAL / HIGH / URGENT                        | Priority.               |
| due_at                | datetime nullable                                   | Calendar if set.        |
| status                | NEW / IN_PROGRESS / WAITING / COMPLETED / CANCELLED | Lifecycle.              |

## **8.5 Documents & Finance**

### **documents**

| **Field**                    | **Type / notes**           | **Rule**                 |
|------------------------------|----------------------------|--------------------------|
| id                           | UUID                       | PK.                      |
| case_id                      | UUID                       | Required.                |
| activity_type/id             | HEARING / SERVICE nullable | Optional association.    |
| category                     | string/lookup              | Document classification. |
| file_name / mime_type / size | metadata                   | Validation.              |
| storage_path                 | string                     | Tenant/case-scoped path. |
| current_version              | int                        | Versioning.              |
| uploaded_by                  | UUID                       | Audit.                   |
| is_archived                  | boolean                    | No standard hard delete. |

### **case_payments**

| **Field**    | **Type / notes**                    | **Rule**                                 |
|--------------|-------------------------------------|------------------------------------------|
| id           | UUID                                | PK.                                      |
| case_id      | UUID                                | Required.                                |
| amount       | decimal \> 0                        | Payment amount.                          |
| paid_at      | date/datetime                       | Required.                                |
| method       | CASH / BANK_TRANSFER / CARD / OTHER | Payment method.                          |
| reference_no | string nullable                     | Optional.                                |
| notes        | text nullable                       | Optional.                                |
| recorded_by  | UUID                                | Audit.                                   |
| is_reversed  | boolean                             | Optional correction mechanism if needed. |

## **8.6 Notifications, Timeline & Audit**

| **Entity**           | **Key fields**                                                                                       | **Rule**                                        |
|----------------------|------------------------------------------------------------------------------------------------------|-------------------------------------------------|
| notifications        | id, user_id, type, title, body_safe, entity_type/id, read_at, created_at                             | User-specific; content must be permission-safe. |
| case_timeline_events | id, case_id, event_type, actor_user_id, summary, before_state, after_state, created_at               | Append-only material Case history.              |
| audit_logs           | id, tenant_id nullable, actor_user_id, action, entity_type/id, before_state, after_state, created_at | Immutable cross-module audit record.            |

## **8.7 Relationship summary**

- Firm 1 -\> many Employees, Cases, Subscriptions(history), Notifications, Audit records.

- Case 1 -\> 1 Case Client snapshot; 0..many Opponent snapshots; 0..many Documents, Hearings, Services of Process, Client Meetings, Tasks, Payments, Access Grants, Timeline events.

- Governorate 1 -\> many Courts; Court 1 -\> many Circuits.

- User(Lawyer) many \<-\> many Case Types through Lawyer Specializations.

- Employee many \<-\> many Cases through Case Access Grants.

- Activity -\> 1 Case and optionally -\> 1 assigned user; Hearing assigned legal user must be a matching Lawyer.

# **9. Permission Catalog**

## **9.1 Platform permissions - Super Admin**

| **Permission**                        | **Meaning**                                                             |
|---------------------------------------|-------------------------------------------------------------------------|
| platform.firm.create                  | Create Firm + Firm Admin.                                               |
| platform.firm.read                    | List/view firm metadata.                                                |
| platform.firm.status.manage           | Change explicit Firm ACTIVE/INACTIVE status.                            |
| platform.firm_admin.permission.manage | Assign/revoke Firm Admin account-level permissions.                     |
| platform.user.metadata.read           | View Firm Admin/Employee account metadata/status only.                  |
| platform.user.status.manage           | Activate/deactivate firm-user account status if operator policy allows. |
| platform.plan.manage                  | Create/edit/disable subscription plans.                                 |
| platform.subscription.manage          | Assign plan, dates, status, activation.                                 |
| platform.audit.read                   | View platform-level audit.                                              |

## **9.2 Firm-level permission catalog**

| **Permission family** | **Representative codes**                                                      | **Scope**                                      |
|-----------------------|-------------------------------------------------------------------------------|------------------------------------------------|
| Firm profile          | firm.profile.read / manage                                                    | Tenant metadata/branding/settings.             |
| Employees             | employee.read / create / edit / permission.manage / status.manage             | Employee administration.                       |
| Cases                 | case.create / case.read / case.edit / case.status.manage / case.access.manage | Case management and delegation.                |
| Activities            | hearing.\*, service.\*, meeting.\*, task.\*                                   | Create/manage/assign activities.               |
| Documents             | document.view / download / upload / edit / manage                             | Document actions.                              |
| Calendar              | calendar.read / calendar.manage                                               | Calendar visibility/creation where applicable. |
| Finance               | finance.case.view / payment.record / manage / finance.firm.read               | Case or firm financial access.                 |
| Reports               | report.operational.read / report.finance.read / export                        | Authorized reporting.                          |
| Audit                 | audit.read                                                                    | Tenant audit visibility if granted.            |

## **9.3 Recommended templates (non-binding)**

| **Template**       | **Suggested permissions**                                             | **Important note**                                                        |
|--------------------|-----------------------------------------------------------------------|---------------------------------------------------------------------------|
| Full Firm Admin    | All tenant management permissions                                     | Recommended default convenience only; Super Admin may remove permissions. |
| Lawyer Employee    | case.view + documents view + hearing view/update + task update        | Still needs Case-specific grants and matching specialization.             |
| Secretary          | case.view + client edit + document upload + calendar/activity support | No automatic finance or unrelated case access.                            |
| Accountant         | finance.case.view/payment.record and optionally finance.firm.read     | Job classification alone grants nothing.                                  |
| Read-only Employee | case.view/document.view only on granted Cases                         | Useful for review/audit support.                                          |

# **10. Key Workflows**

## **10.1 Firm onboarding**

**1.** Super Admin signs in using seeded account.

**2.** Super Admin creates Firm metadata.

**3.** Super Admin creates Firm Admin identity and credentials/invitation.

**4.** Super Admin sets Firm Admin professional classification; if Lawyer, sets specialization(s).

**5.** Super Admin selects Firm Admin account-level permissions.

**6.** Super Admin attaches plan/subscription and sets activation/status.

**7.** Firm Admin logs in and completes profile/appearance settings.

## **10.2 Employee onboarding**

**1.** Firm Admin opens Employees and selects Create Employee. Super Admin may use the same flow after selecting the target Firm.

**2.** Enter identity/contact details and job classification.

**3.** If Lawyer, select one or more specializations from Case Types.

**4.** Assign base permissions.

**5.** Create/activate account.

**6.** Employee logs in and sees no Cases until Case access/activity assignments are made.

## **10.3 Case creation**

**1.** Firm Admin selects Create Case.

**2.** Enter Case identification and choose Case Type.

**3.** Select Governorate; system filters Court list.

**4.** Select Court; system filters Circuit list.

**5.** Enter case-local Client information and optional Opponent information.

**6.** Enter agreed fee if finance is being tracked and user has permission.

**7.** Save Case. Firm Admin becomes operational owner; lawyer assignment is optional and must match Case Type.

**8.** Grant Employees selective Case capabilities as needed.

## **10.4 Granular delegation example**

**1.** Firm Admin opens Case A -\> Access & Assignments.

**2.** Grant Lawyer Ahmed case.view + document.view.

**3.** Grant Secretary Sara client.edit + document.upload.

**4.** Create Hearing \#3 and assign Lawyer Omar; picker includes Omar only if his specialization matches Case Type.

**5.** Create Client Meeting and assign Employee Mahmoud.

**6.** Grant Accountant Ali finance.view + payment.record for Case A only.

**7.** Each Employee dashboard/calendar/notifications update to show only relevant work.

## **10.5 Hearing workflow**

**1.** Create Hearing inside Case.

**2.** Court/Circuit default from Case or are selected from valid filtered hierarchy.

**3.** Optionally assign matching Lawyer.

**4.** Hearing appears on authorized calendars and assigned-user notification center.

**5.** On completion, enter outcome and upload minutes/supporting documents.

**6.** If adjourned, record next hearing or create a new Hearing.

## **10.6 Service of Process workflow**

**1.** Create Service of Process inside Case.

**2.** Enter Court, schedule, recipient/service details, assignee, notes.

**3.** Calendar and notifications are created.

**4.** Assignee records COMPLETED / FAILED / RESCHEDULED / CANCELLED and adds result notes/documents.

**5.** Case timeline records material status changes.

## **10.7 Payment workflow**

**1.** Authorized user opens Case Finance.

**2.** View agreed fee, paid, remaining.

**3.** Record payment amount/date/method/reference/notes.

**4.** Server validates the amount and records audit metadata.

**5.** Case paid/remaining recalculates immediately.

**6.** Firm finance aggregates update from source payment records.

# **11. Acceptance Criteria & Test Scenarios**

| **ID** | **Scenario**                                                         | **Expected result**                                                                                |
|--------|----------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| AC-001 | Run seed twice                                                       | Exactly one Super Admin exists.                                                                    |
| AC-002 | Super Admin creates Firm Admin without required selected permissions | System stores exactly the selected permission set; no hidden full-CRUD role is injected.           |
| AC-003 | Firm Admin creates Lawyer without specialization                     | Creation/activation for legal assignment is blocked until at least one specialization is selected. |
| AC-004 | Create Criminal Case and open lawyer picker                          | Only Lawyers specialized in Criminal are selectable.                                               |
| AC-005 | Bypass UI and submit mismatching lawyer ID                           | API rejects assignment.                                                                            |
| AC-006 | Select Alexandria Governorate                                        | Only Courts seeded under Alexandria are returned/selectable.                                       |
| AC-007 | Submit Court from Cairo with Alexandria Governorate                  | API rejects inconsistent hierarchy.                                                                |
| AC-008 | Create second Case for same client                                   | A new independent case-local Client snapshot is created; no shared client ID is reused.            |
| AC-009 | Grant secretary only document.upload on Case A                       | Secretary can upload Case A document but cannot view Case B or Case A finance.                     |
| AC-010 | Assign lawyer only to Hearing \#3                                    | Lawyer sees Hearing \#3 plus minimum context, not unrelated Case data.                             |
| AC-011 | Employee opens calendar                                              | Only assigned/authorized activities appear.                                                        |
| AC-012 | Firm Admin with calendar.read sees calendar                          | All firm events allowed by their permissions appear.                                               |
| AC-013 | Create Service of Process                                            | Record appears inside Case, calendar, and assignee notification center.                            |
| AC-014 | Record payment                                                       | Paid and remaining recalculate; firm collected/outstanding totals reconcile.                       |
| AC-015 | Accountant job classification without finance permission             | Finance UI/API is denied.                                                                          |
| AC-016 | Grant accountant finance.firm.read                                   | Firm finance dashboard becomes accessible.                                                         |
| AC-017 | Set subscription EXPIRED                                             | No automatic read-only SUSPENDED state is created; subscription status updates only.               |
| AC-018 | Super Admin opens firm details                                       | Can see firm/user metadata but cannot retrieve Case/client/opponent/document content.              |
| AC-019 | Revoke Case grant                                                    | Employee immediately loses Case access and future notifications for it.                            |
| AC-020 | Mobile requests hidden Case                                          | Same API denial as web.                                                                            |
| AC-021 | Switch language to Arabic                                            | UI renders Arabic strings and RTL layout without data/permission changes.                          |
| AC-022 | Search for AI assistant route/module                                 | No v2.0 AI/RAG requirement is exposed or assumed.                                                  |

# **12. Cross-Cutting Requirements**

## **12.1 Localization & RTL**

- All user-facing strings must be localizable; no hard-coded interface text.

- Arabic renders right-to-left with mirrored navigation/layout where appropriate.

- Dates, numbers, currency, and sorting follow locale conventions.

- Global reference data stores English and Arabic labels.

- User-entered documents/notes preserve the original language.

## **12.2 Security & Privacy**

- TLS in transit and strong encryption at rest for sensitive data.

- Password hashing using an industry-standard adaptive algorithm.

- Authorization checked server-side for every API route.

- Tenant scoping on every tenant-owned query and object-storage path.

- PII fields such as national IDs should receive application-layer encryption where appropriate.

- Super Admin endpoints must separate platform metadata from privileged tenant legal content.

## **12.3 Auditability & retention**

- Append-only audit records for permission changes, assignments, Case changes, documents, payments, subscriptions, and account status.

- Case timeline provides a user-facing chronological history of material case events.

- Normal users archive rather than physically delete legal records.

- Data retention/purge policy is an operational policy and must not be conflated with subscription status.

## **12.4 Performance & reliability targets**

| **Aspect**                | **Target**                                                                                                            |
|---------------------------|-----------------------------------------------------------------------------------------------------------------------|
| Availability              | 99.5% monthly target for v2.0 unless infrastructure SLA specifies higher.                                             |
| List/search latency       | Typical tenant lists/searches should return within 2 seconds under expected data volume.                              |
| Authorization consistency | Permission revocation reflected on subsequent requests without stale long-lived authorization caches.                 |
| Backups                   | Daily automated database backups and protected document-store backup/replication with tested restore procedure.       |
| Observability             | Structured logs and error tracking for authentication, permission denials, scheduling jobs, and failed notifications. |

## **12.5 Notification safety**

- Notification text should use minimal safe identifiers for users with limited context.

- No hidden opponent details, financial figures, or document names are pushed to a user without matching permissions.

- Notification click-through rechecks authorization at open time.

# **13. Out of Scope / Deferred**

- AI/RAG, legal research assistant, embeddings, OCR-to-AI pipelines, AI summaries/classification.

- Public signup/self-service firm onboarding.

- Client account/portal, online consultation booking, lawyer marketplace.

- Invoice generation, invoice lifecycle, expense management, payroll, accounting ledger, tax filing.

- Automatic payment retries/dunning and automatic read-only subscription suspension.

- Court-system API integrations, e-filing, e-signature, official notification integrations.

- Cross-firm data sharing or cross-case client identity synchronization.

- Custom firm-created Courts/Governorates/Circuits.

- Permission role-builder/templates beyond optional recommended templates; the authoritative model is direct permissions + Case grants.

# **14. Traceability & Implementation Precedence**

For implementation and QA, every BR-### rule should map to at least one automated test or acceptance test. The following precedence applies when old code, old documentation, or UI behavior conflicts with this specification:

**1.** Business Rules in Section 7 of this v2.0 PRD.

**2.** Scope-lock decisions in Section 0.

**3.** Functional Requirements in Section 6.

**4.** Data Model in Section 8 and Permission Catalog in Section 9.

**5.** Any non-conflicting behavior from the previous v1.0 document may be retained only after confirming it does not violate the above.

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<thead>
<tr class="header">
<th><strong>Critical migration note<br />
</strong>Before declaring v2.0 complete, remove or disable old authorization assumptions that auto-grant by Lawyer/Secretary/Accountant role, old reusable Client/Opponent tables in active workflows, tenant-managed Court CRUD, invoice/expense UI, subscription read-only suspension middleware, and AI/RAG entitlements/routes. Data migrations may preserve historical data, but new behavior must follow v2.0.</th>
</tr>
</thead>
<tbody>
</tbody>
</table>

## **14.1 Minimum implementation migration checklist**

| **Area**          | **Migration action**                                                                                              |
|-------------------|-------------------------------------------------------------------------------------------------------------------|
| Identity          | Migrate existing tenant roles into account_type + job_classification + explicit user_permissions.                 |
| Firm Admin        | Remove hard-coded non-restrictable full CRUD; enforce Super Admin-assigned permission set.                        |
| Employees         | Move lawyer specializations to explicit case_type relation.                                                       |
| Clients/Opponents | Move active v2 workflow to case-local snapshots; prevent new shared master records.                               |
| Courts            | Replace tenant court CRUD with seeded global Governorate/Court/Circuit references.                                |
| Permissions       | Create Case access-grant storage and activity assignments; secure all endpoints with effective permission checks. |
| Finance           | Retire invoice/expense screens and APIs from v2 user flows; retain case fee/payment ledger.                       |
| Subscription      | Remove automatic SUSPENDED/read-only enforcement from subscription state changes.                                 |
| AI                | Hide/disable AI/RAG modules from v2 product scope.                                                                |
| Mobile            | Update mobile data filtering/actions to identical v2 permission rules.                                            |
| QA                | Add cross-tenant, permission-revocation, case-scope, specialization, court-filter, and notification-leak tests.   |

**END OF AUTHORITATIVE HOQOOQ PRD v2.0**
