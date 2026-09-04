# Exercise 6 Iteration Log — Create Architecture

## Baseline Observations

**Starter Prompt:** Generic format requirements, no Context, no Constraints

**Key Questions for Iteration:**
1. Without tech-stack Context, does output remain generic or infer from PRD?
2. Does output include all 8 required sections?
3. Are open technical decisions surfaced?
4. Does privacy-by-schema-design pattern appear without explicit instruction?

**Hypothesis for Context:** Adding explicit tech stack description to Context will make architecture output **meaningfully different** for different stacks. This is the load-bearing test.

---

## Iteration Strategy

**Iteration 1 (Baseline):** Run with minimal Context — observe if architecture is generic
**Iteration 2 (Context Addition):** Add explicit tech stack Context — should improve specificity
**Iteration 3 (Constraints Addition):** Add quality gates and anti-patterns to Constraints
**Iteration 4+:** Load-bearing audit and specialty tests

---

## Key Tests to Implement

### Test A: Tech Stack Context Load-Bearing (Critical)

**Run twice with SAME PRD, DIFFERENT Context:**

**Version 1 - React/Node/Postgres:**
```
Context: Technical environment: 
- Frontend: React 18, TypeScript, Vite, Tailwind CSS
- Backend: Express 4 on Node.js 20 LTS
- Database: PostgreSQL 16 with Prisma ORM
- Auth: Entra ID OIDC via openid-client
- Sessions: Postgres-backed express-session
- Scheduler: In-process polling (no Redis/BullMQ)
```

**Version 2 - Python/FastAPI/MongoDB:**
```
Context: Technical environment:
- Frontend: React 18, TypeScript, Vite, Tailwind CSS (same as above)
- Backend: Python with FastAPI
- Database: MongoDB
- Auth: Auth0 or self-hosted Keycloak
- Sessions: Redis
- Scheduler: Celery with RabbitMQ
```

**Expected Difference:** Architecture documents should be substantively different in backend, database, scheduler, session management sections. If outputs are similar, Context is not load-bearing.

### Test B: All 4 Test Cases

After Context settles, run against all 4 test cases:
1. Required Sections
2. Tech Stack Specificity
3. Privacy-by-Schema
4. Open Technical Decisions

---

## Implementation Plan

(To be filled in as iterations run)

### Iteration 1: Baseline + Context Addition
- [ ] Run with minimal Context
- [ ] Observe: generic or specific?
- [ ] Add tech stack Context
- [ ] Observe: change in specificity?

### Iteration 2: Tech Stack Load-Bearing Test
- [ ] Run with React/Node/Postgres Context
- [ ] Run with Python/FastAPI/MongoDB Context
- [ ] Compare outputs
- [ ] Verify Context is genuinely load-bearing

### Iteration 3: Constraints Addition
- [ ] Add security/privacy constraints
- [ ] Add performance constraints (±60s dispatch tolerance)
- [ ] Re-run to verify no regression

### Iteration 4: Full Test Suite
- [ ] Run all 4 test cases
- [ ] Load-bearing audit (remove each instruction, verify impact)

