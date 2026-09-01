# Exercise 5: TeamPulse Test Cases

Domain: Enterprise team health check system with anonymous survey responses, multi-role access, and data retention requirements.

**Baseline:** Sonnet 100% (1/1 cases passing from Exercise 5 Step 1 run)  
**Target (Green State):** Sonnet 4/4 (all new tests passing); Haiku N/A for this exercise  
**Model:** Sonnet 5 (Module 1 optimized prompt applied)

---

## Test Case [1]: Anonymous Data Handling — Operational Definition

**Domain Gap:** Module 1 Pomodoro tests did not require operationally-defined anonymity. TeamPulse's core value proposition is anonymity, so the PRD must define it concretely, not assert it vaguely.

**Input:**
```
The system must guarantee that survey responses are anonymous. 
Engineers complete a survey and their responses are aggregated, 
but the manager never knows which engineer gave which answer — 
not in the dashboard, not in a CSV export, not even in the raw database.
```

**Expected Output Criteria:**

All of the following must appear explicitly in the PRD:

1. **Schema-level isolation**: The `responses` table has no foreign key, column, or indexed path that references individual team members or their identifying information. Responses cannot be joined back to an individual by ID.

2. **Minimum threshold guard**: If fewer than N responses are submitted (N is specified, e.g., N=4), the aggregate score is not displayed to the manager. This prevents reverse-engineering individual answers on small teams ("if 3 people answered and avg=4.5, one person scored 5").

3. **No attribution in any view**: Not just the dashboard, but explicitly all views including:
   - Database dumps/backups (raw queries cannot reveal attribution)
   - Admin/operator views
   - CSV exports
   - Audit logs

4. **Token separation from responses**: The mechanism for preventing duplicate submissions (e.g., `member_id_hash`) exists separately from the response data and is never joined in aggregation queries.

**Failure Criteria (must NOT occur):**

- PRD uses the word "anonymous" without operational details (e.g., "responses are stored anonymously" with no further explanation)
- PRD mentions anonymity only in Overview, not in Data Model or Security sections
- No minimum threshold guard specified
- PRD says "anonymous in the dashboard" but doesn't address database/backup scenarios
- Token/response separation not mentioned or implied

**Why This Matters:**

A developer reading a vague anonymity requirement ("responses are anonymous") might implement:
- Anonymity only in the UI layer (database still has clear attribution)
- Or build a system that's anonymous until someone exports the CSV (and sees the raw data)

An operational definition prevents this ambiguity and forces schema-level thinking.

---

## Test Case [2]: Multi-Role Requirements — Distinct Access Scopes

**Domain Gap:** Module 1 Pomodoro is a single-user application (timer, notes, persistence for one person). TeamPulse has two distinct user types with fundamentally different workflows and data access. The PRD must address both roles separately, not collapse them into a generic "User."

**Input:**
```
Two user types: engineers and managers.
- Engineers receive a link and answer questions once per survey cycle.
- Managers set up surveys, view results, manage team membership.
These users have completely different access patterns and permissions.
```

**Expected Output Criteria:**

All of the following must appear explicitly in the PRD:

1. **Separate Personas section** (or equivalent) that names both roles and describes their distinct workflows:
   - Manager: configures surveys, views dashboard, manages team members
   - Engineer: receives link, completes survey, no account/login required

2. **Role-scoped API endpoints**: API requirements clearly indicate which endpoints are for which role. For example:
   - Manager-only: `GET /api/teams/:teamId/dashboard`, `PUT /api/survey-config`
   - Engineer (public/tokenized): `GET /api/survey/:token`, `POST /api/survey/:token`
   - Must NOT list a single generic "survey" endpoint used by both roles

3. **Distinct authentication mechanisms**:
   - Manager: session-based (OIDC, login flow)
   - Engineer: token-based (one-time link, no account creation)
   - PRD must explain why they differ (token is stateless, engineer has no account)

4. **Data access rules per role**:
   - Manager sees aggregated data only (never individual responses)
   - Engineer sees only their own survey form, cannot see results or other engineers' responses
   - PRD must state this explicitly in Security or Access Control section

5. **Feature availability per role**:
   - Clear statement: "Dashboard is manager-only. Engineers cannot log in or view any dashboard."
   - Not buried in descriptions; must be explicit

**Failure Criteria (must NOT occur):**

- PRD treats the system as a single-user app (e.g., "User configures surveys and completes them")
- API endpoints are described generically without role clarity (e.g., "GET /survey/:id" used by both roles for different purposes)
- Authentication is single-path (e.g., "all users log in via OIDC") without acknowledging engineers have no account
- No data access rules specified per role
- Persona section combines both roles into one ("User" or "Team Member")

**Why This Matters:**

A developer reading role-ambiguous requirements might implement:
- Same API endpoint handling both manager and engineer requests (security boundary confusion)
- Identical authentication for both (engineers forced to create accounts; breaks "anonymous" because names are now in account table)
- Same dashboard visible to both roles (data leakage)

Clear role separation is essential for both security and feature correctness.

---

## Test Case [3]: Scope Specificity — Four Named Out-of-Scope Items

**Domain Gap:** The TeamPulse description explicitly lists four out-of-scope items for V1. A weak PRD might include a generic "Out of Scope (V1)" section without naming the specific items. A strong PRD verifies all four are named by name, showing the model understood the boundaries.

**Input:**
```
Out of scope for V1: 
- ML-based sentiment analysis or free-text NLP scoring
- Cross-team comparison or org-wide rollups
- HR system integration (Workday, BambooHR, etc.)
- Native mobile apps (mobile web only)
```

**Expected Output Criteria:**

The PRD must include an "Out of Scope" section for V1 that names all four items by name:

1. ✅ Explicitly mentions: "ML-based sentiment analysis or free-text NLP scoring" (or equivalent phrasing)
2. ✅ Explicitly mentions: "Cross-team comparison or org-wide rollups" (or equivalent)
3. ✅ Explicitly mentions: "HR system integration" and names vendors (Workday, BambooHR) or equivalent
4. ✅ Explicitly mentions: "Native mobile apps" vs "mobile web only"

Additional context should appear:
- Why each item is deferred (e.g., "sentiment analysis requires labeled training data; out of scope for V1")
- When it might move in-scope (Phase 2, if product gains traction, etc.)

**Failure Criteria (must NOT occur):**

- Out-of-Scope section is generic (e.g., "Advanced features deferred to V2") without naming items
- Only 3 out of 4 items mentioned by name
- Items are mentioned in Features section ("won't do sentiment analysis") but not consolidated in explicit Out-of-Scope section
- Scope boundary unclear (e.g., "mobile support" mentioned but not explicit "mobile web only, no native")

**Why This Matters:**

A developer reading a vague out-of-scope section might:
- Spend time architecting for "mobile app support later" when native apps are explicitly out of scope
- Build HR system integration hooks "just in case" (scope creep)
- Over-engineer sentiment analysis support when the product explicitly defers it

Named scope boundaries prevent accidental scope creep and set honest expectations.

---

## Test Case [4]: Data Retention & Purging Policy — Enterprise Compliance

**Domain Gap:** Module 1 Pomodoro has no retention requirement (single-user, local app). TeamPulse is multi-tenant, multi-manager, and handles employee engagement data — which triggers compliance questions a developer must know upfront:
- How long are responses kept?
- Can a manager delete old surveys?
- What happens when an employee leaves the company? (GDPR right-to-be-forgotten)
- Does archiving a team delete its data, or preserve it indefinitely?

**Input:**
```
The system is deployed in an enterprise environment with multiple teams 
and managers. Managers may want to archive old surveys and clean up data. 
Employees who leave the company may request deletion of their responses. 
The product must specify data retention clearly.
```

**Expected Output Criteria:**

All of the following must appear explicitly in the PRD:

1. **Retention period for active surveys**: Responses to active surveys are retained for [X days/months/indefinitely]. Default must be specified and configurable.

2. **Retention period for archived teams**: When a team is archived, its associated responses are retained for [Y days] then purged. Specific timeframe required (not "eventually" or "as needed").

3. **Employee deletion / GDPR compliance**: When an employee is removed from a team, their survey responses are either:
   - Deleted immediately, OR
   - Deleted after a grace period, OR
   - Anonymized/disassociated from that employee
   
   The choice must be explicit and justified.

4. **Audit trail for deletions**: When data is purged or deleted, it is logged (who initiated, when, what was deleted). This allows compliance teams to prove data was destroyed.

5. **Admin API for manual deletion**: If a manager or admin needs to delete a specific survey instance or employee's responses, what API exists? (e.g., `DELETE /api/admin/survey-instances/:instanceId` with audit logging)

6. **Cascade behavior**: When a team is deleted, what happens to:
   - Survey configs (deleted immediately? archived? soft-deleted?)
   - Survey instances (deleted immediately? archived?)
   - Responses (same as archived team policy?)
   
   All must be explicit.

**Failure Criteria (must NOT occur):**

- PRD says "responses are retained indefinitely" with no retention policy or compliance justification
- Retention period is mentioned but not configurable (no env var or config setting)
- No mention of employee departure / GDPR right-to-be-forgotten
- "Archive" and "delete" are used interchangeably; unclear if archived data is purged or preserved
- No audit trail for deletions mentioned
- No cascade delete behavior specified (does deleting a team delete its responses?)

**Why This Matters:**

A developer reading vague retention requirements might:
- Assume responses are kept forever (no purge logic built in)
- Store employee names in the responses table (makes future GDPR deletion impossible without re-engineering the schema)
- Not implement cascade deletes (manager deletes team; orphaned responses stay in DB forever)
- Miss audit logging for compliance (can't prove data was destroyed during an audit)

A compliance or legal team later asks: "Can we prove we deleted that employee's data?" Developer has no audit trail, and if the schema stores names with responses, the question becomes an architectural problem.

Clear retention & deletion policy prevents re-engineering downstream.

---

## Summary: Teampulse Test Cases

| Test | Focus | Module 1 Parallel | Severity |
|------|-------|-------------------|----------|
| Test 1 | Anonymous Data (Operational Definition) | N/A (new domain) | Critical — core value prop |
| Test 2 | Multi-Role Requirements (Access Scopes) | N/A (new domain) | Critical — security/auth |
| Test 3 | Scope Specificity (4 Named Items) | Parallels "Constraints" clarity | High — prevents scope creep |
| Test 4 | Data Retention & Purging (Compliance) | N/A (new domain) | High — compliance/schema |

**Total new assertions:** 4 tests  
**Expected Baseline:** Sonnet 4/4 (Module 1 prompt is optimized; should handle enterprise PRD well)  
**Model Ladder (Haiku):** Not evaluated in Exercise 5 (Sonnet-only run expected)

---

## Evaluation Strategy

**Run command:**
```bash
promptfoo eval -c exercise-5-teampulse-prd-full.yaml --no-cache
```

**Scoring:**
- PASS: All assertions met for a test case
- FAIL: Any assertion not met

**Hypothesis:** Module 1 prompt (with Timing & Drift section + Security specificity + Feature optionality instructions) should pass all 4 tests, indicating the prompt has sufficient enterprise domain knowledge. If any test fails, that gap becomes an Exercise 5 iteration target (similar to Model Ladder audit in Module 1).

