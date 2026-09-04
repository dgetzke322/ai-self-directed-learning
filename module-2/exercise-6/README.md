# Exercise 6: Create Architecture Command

**Status:** Framework complete, ready for iteration (Haiku-only evals per Module 2 transition)

## Completed Work

### 1. ✅ Starter Prompt (Step 1)

`create-architecture-prompt.md` — Senior architect role with 8 required sections:
1. System Overview Diagram (named technologies)
2. Component Architecture (tech, responsibilities, protocols)
3. Data Architecture (schemas, relationships, consistency)
4. API Surface (endpoints, methods, auth flows)
5. Security Architecture (auth, authz, tokens, rate limiting)
6. Deployment & Operations (container, scheduler, monitoring)
7. Open Technical Decisions (with "why it matters")
8. Tradeoffs & Rationale (why this design, limitations, pivots)

**Context & Constraints:** Placeholders ready to fill via iteration

### 2. ✅ Test Cases (Step 2)

`architecture-test-cases.md` — 4 comprehensive test criteria committed before iteration:

**Test 1: Required Sections** — All 8 sections present with specific tech names (not generic layers)

**Test 2: Tech Stack Specificity** — Output reflects React/Node/Postgres/Entra ID stack specifically
- **Context load-bearing test:** Same PRD with different tech stacks (Python/FastAPI/MongoDB) should produce meaningfully different architectures

**Test 3: Privacy-by-Schema-Design** — Responses table isolation, token separation, aggregation without attribution, minimum threshold guard

**Test 4: Open Technical Decisions** — Scheduler scaling, sessions, notifications, analytics, multi-region all explicitly flagged with "why it matters"

### 3. ✅ Test Configuration (Step 3 Setup)

`create-architecture-tests.yaml` — Promptfoo config with:
- Condensed TeamPulse PRD (small enough for Haiku eval)
- Tech stack in Context section
- Privacy and scheduling constraints
- Haiku as sole provider (per Module 2 transition)

### 4. ✅ Iteration Plan

`architecture-iterations.md` — Planned iterations:
- **Iteration 1:** Baseline + Context addition
- **Iteration 2:** Tech stack load-bearing test (React/Node vs Python/FastAPI)
- **Iteration 3:** Constraints addition
- **Iteration 4:** Full test suite + load-bearing audit

---

## Next Steps (To Complete Exercise 6)

### Run Iterations (Step 3 — 75 min budget)

```bash
# Iteration 1: Context addition
promptfoo eval -c module-2/exercise-6/create-architecture-tests.yaml --no-cache

# Document results → architecture-iterations.md
# Hypothesis: specificity improves with Context
```

### Step 4: Upstream Quality Check (20 min)

- Run finalized prompt against high-quality PRD (TeamPulse from Exercise 5)
- Run finalized prompt against weak PRD (minimal 2-3 sentence description)
- Document in architecture-test-cases.md: which sections improved, which gaps appeared

### Step 5: Conway's Game of Life Kata Stress Test (25 min)

Test criteria:
- Does architecture surface **double-buffering pattern** for cell state management?
- Does it identify rendering optimization needs for 10,000 cells?
- Does it recommend efficient state model beyond naive `useState`?

Record: pattern recognition, optimization awareness, domain-specific insights

### Step 6: Model Ladder Checkpoint (15 min)

Haiku score: X/Y (from test suite)
- Gaps closed this exercise
- Gaps accepted (with reasoning)

### Step 7: Commit

All Exercise 6 artifacts:
- Final create-architecture-prompt.md (with Context + Constraints)
- architecture-test-cases.md (with upstream quality notes + kata test results)
- create-architecture-tests.yaml
- architecture-iterations.md (completed iteration log)
- Sample architecture outputs (vs weak PRD, vs different tech stack)

---

## Key Design Decisions

### Why Context is Load-Bearing for Architecture

Unlike Create-PRD (which works across domains), Architecture is **fundamentally dependent** on tech stack. A React/Node/Postgres architecture is different from Python/FastAPI/MongoDB:

- **Different components** (Express vs FastAPI middleware)
- **Different patterns** (Prisma ORM vs SQLAlchemy)
- **Different deployment** (Node single-process vs Python/Gunicorn)
- **Different scaling** (Postgres sessions vs Redis)

Testing with two different tech stacks will make this clear: Context is not decorative, it's structurally essential.

### Privacy-by-Schema as Load-Bearing Constraint

TeamPulse's core requirement is that "no individual response is ever attributable, including in admin/database views." This forces a specific schema design:

```sql
-- CORRECT (schema-level isolation)
CREATE TABLE responses (
  id, survey_instance_id fk, question_id fk, answer_value, submitted_at
);
-- No FK to team_members, no FK to survey_tokens — cannot be joined

-- WRONG (data leakage)
CREATE TABLE responses (
  id, survey_instance_id fk, team_member_id fk, answer_value
);
-- Can be joined → privacy violation
```

This constraint should force a specific architectural pattern and is a good test of whether the architect understood the privacy requirement.

---

## Expected Green State Criteria

Haiku should pass all 4 test cases when:

1. ✅ **All 8 sections** appear with specific technology names
2. ✅ **Tech stack specificity:** React 18, Express 4, PostgreSQL 16, Entra ID, etc. (not generic choices)
3. ✅ **Privacy pattern:** Schema isolation explicitly designed (no FK from responses to members)
4. ✅ **Open decisions:** Scheduler scaling, session storage, notifications, analytics all flagged with reasoning

If Haiku fails any criterion after 3 iterations, document as acceptable gap (architecture generation is complex for smaller models).

---

## Module 2 Readiness

After completing this exercise:

- **Baseline command:** Create Architecture (Haiku-optimized)
- **Known gaps:** (To be documented in checkpoint)
- **Reusable instructions:** (To be identified in load-bearing audit)
- **Ready for:** Exercise 7 (Create UX), Exercise 8+ (remaining SDLC commands)

