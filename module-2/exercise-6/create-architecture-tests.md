# Create Architecture Test Cases — Exercise 6

Domain: TeamPulse Architecture Design

Architecture documents are heavily context-dependent. These test cases verify that the architecture command includes required sections, reflects the specific tech stack from the PRD, and surfaces important design patterns.

## Test Case 1: Required Sections

**Expected Output Criteria:**

1. ✅ **System Overview Diagram** — Component boxes with specific tech names (React 18, Express 4, PostgreSQL 16, not generic "Frontend/Backend/Database")
2. ✅ **Component Architecture** — Each component (Frontend, Backend, Database, Auth, Scheduler) specifies technology, responsibilities, communication protocol
3. ✅ **Data Architecture** — Core tables documented (managers, teams, survey_configs, survey_instances, responses). **Critical: responses table has NO FK to team_members** (privacy-by-schema design)
4. ✅ **API Surface** — Manager and engineer endpoints listed with HTTP methods
5. ✅ **Security Architecture** — Authentication (Entra ID OIDC), authorization (tenant scoping), token security, rate limiting
6. ✅ **Deployment & Operations** — Docker container, docker-compose, scheduler, environment variables, monitoring (scheduler_log)
7. ✅ **Open Technical Decisions** — Specific decisions still to be made (scheduler scaling, session storage, notifications, analytics, multi-region)
8. ✅ **Tradeoffs & Rationale** — Why this architecture, known limitations, future pivot points

**Failure Criteria:** Missing sections, generic component names, missing schema isolation pattern, no open decisions

---

## Test Case 2: Tech Stack Specificity (Context Load-Bearing)

**Expected Output Criteria:**

Architecture must reflect specific tech choices from PRD:

- ✅ Frontend: React 18, TypeScript, Vite, Tailwind, React Query, Recharts (not generic "SPA")
- ✅ Backend: Express 4 on Node.js 20 LTS with TypeScript (not "Node framework" or Flask/FastAPI)
- ✅ Database: PostgreSQL 16 with Prisma ORM (not MySQL, MongoDB, or generic "database")
- ✅ Auth: Entra ID OIDC via openid-client (not Auth0, Okta, or generic SSO)
- ✅ Sessions: Postgres-backed express-session via connect-pg-simple (not Redis)
- ✅ Scheduler: In-process polling with drift correction (not BullMQ, Celery, or separate worker)
- ✅ Email: nodemailer SMTP relay (not SendGrid, Mailgun, SES)
- ✅ Containerization: Multi-stage Docker, single runtime, docker-compose for Postgres

**Context Load-Bearing Test:** Run same PRD with Context "Tech stack: Python, FastAPI, MongoDB, Auth0, Redis, Celery"
- Outputs should differ meaningfully in all 8 points above
- If they don't, Context is not load-bearing

**Failure Criteria:** Recommending alternative tech, using generic names, missing any specific choice

---

## Test Case 3: Privacy-by-Schema-Design

**Expected Output Criteria:**

Architecture must explain how anonymity is enforced at schema level:

1. ✅ **Responses table isolation:** Explicitly document NO FK to team_members or survey_tokens
2. ✅ **Token separation:** member_id_hash prevents duplicates but is never queried with responses
3. ✅ **Aggregation queries:** Show how results are computed without attribution
4. ✅ **Admin view guarantee:** Managers see only aggregates, never raw responses
5. ✅ **Minimum threshold guard:** If count < 4, results withheld (prevent reverse-engineering)

**Failure Criteria:** Treating anonymity as UI-only, suggesting managers can "click for individual responses", missing schema isolation pattern

---

## Test Case 4: Open Technical Decisions

**Expected Output Criteria:**

Must list specific decisions still to be made:

- ✅ Scheduler scaling (in-process for V1, worker for 50+ teams?)
- ✅ Session storage scaling (Postgres for V1, Redis if concurrency spikes?)
- ✅ Notifications at scale (sync email for V1, job queue if latency issue?)
- ✅ Analytics (none for V1, how to preserve anonymity while enabling analysis?)
- ✅ Multi-region (single region for V1, implications of distributed scheduling?)

Each decision should explain: why it matters, implications, recommended path.

**Failure Criteria:** No open decisions, generic decisions ("error handling?"), not specific to this product, no "why it matters"

---

## Upstream Quality Impact Note (Post-Iteration)

Will document after running architecture against high-quality vs. weak PRD:

### High-Quality PRD (TeamPulse) produces:
- [specific strengths]

### Weak PRD produces:
- [specific gaps]


---

## Upstream Quality Note (Step 4)

**PRD quality impact on Architecture:**

### High-Quality PRD (TeamPulse from Exercise 5) produces:
- ✅ Specific component descriptions (React 18, Express 4, PostgreSQL 16, Prisma)
- ✅ Detailed data model with relationships and privacy implications
- ✅ Schema-level privacy design (no FK from responses to team_members)
- ✅ Specific performance bounds (±60s dispatch, ±30s close, <1.5s p95)
- ✅ Multi-tenant isolation explained (manager_id scoping at query layer)
- ✅ Open decisions with "why it matters" (scheduler scaling, session storage)

### Weak PRD ("Build a survey system") produces:
- ❌ Generic component descriptions ("frontend/backend/database")
- ❌ Minimal data model, relationships unclear
- ❌ Vague privacy ("keep data anonymous" without schema design)
- ❌ No specific performance targets
- ❌ Multi-tenancy mentioned but not architectured

**Conclusion:** Architecture quality is bounded by upstream PRD quality.

---

## Kata Stress Test: Conway's Game of Life (Step 5)

**Criterion:** Does architecture surface double-buffering pattern for cell state management?

**Expected:** Explicitly recommend two-buffer swap pattern (not mutate-in-place)

**Status:** [Ready to test after Exercise 6 completion]
