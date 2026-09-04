# Step 4: Five-Stage Pipeline Check

**Date:** 2026-09-04

## Pipeline Test Setup

Traced quality through entire SDLC:
PRD → Architecture → UX → Epics/Stories → Plan Story

**Input:** TeamPulse product from Exercise 5

## Quality Observations at Each Stage

### Stage 1: PRD (Exercise 5)
**Status:** ✅ High quality
- Specific features named (survey config, dispatch, anonymization)
- Non-functional requirements quantified (±60s dispatch, <1.5s load, <500ms query)
- User roles explicit (managers, engineers)
- Data model detailed

**Impact on downstream:** Clear scope enables architectural decisions

---

### Stage 2: Architecture (Exercise 6)
**Status:** ✅ High quality
- Specific tech stack (React 18, Express 4, PostgreSQL 16, Prisma, Entra ID OIDC)
- Component structure named (Frontend, Backend, Database, Auth, Scheduler)
- Data architecture with privacy pattern (responses table schema-level anonymity)
- Open technical decisions flagged (scheduler scaling, session storage)

**Impact on downstream:** Tech-specific architecture enables detailed UX

---

### Stage 3: UX (Exercise 7)
**Status:** ✅ High quality
- User flows by role (manager config, engineer form)
- Component inventory with states (error states, loading states)
- Mobile specifics (375px viewport, 44px targets, <3 min flow)
- Accessibility notes (keyboard navigation, ARIA)

**Impact on downstream:** Detailed flows enable right-sized stories

---

### Stage 4: Epics & Stories (Exercise 8)
**Status:** ✅ High quality
- 34 stories across 9 epics
- Right-sized scope (one user action per story)
- Testable acceptance criteria (measurable, specific endpoints)
- Explicit dependencies (prerequisite stories for auth, schema)
- Complete coverage (all PRD features, all UX flows, non-functional requirements)

**Impact on downstream:** Clear stories enable actionable plans

---

### Stage 5: Plan Story (Exercise 9)
**Status:** ✅ High quality
- Stack-specific implementation (Express middleware, Prisma ORM, Zod validation)
- Acceptance criteria traced to plan steps
- Technical decisions named (transactions for atomicity, generators for pauseable execution)
- Error handling patterns specific to stack

**Pipeline Result:** Each quality gate enables downstream clarity

---

## Quality Cascade Analysis

### Where Quality Could Break

1. **Weak PRD → Weak Architecture**
   - Example: If PRD said "survey system" without feature specifics, Architecture would lack component boundaries
   - Impact: Vague Architecture → generic UX → oversized stories → unclear plans

2. **Weak Architecture → Weak UX**
   - Example: If Architecture omitted "privacy-by-schema" pattern, UX might describe manager views of individual responses
   - Impact: UX gaps → story misses → plan doesn't address anonymization

3. **Weak UX → Weak Stories**
   - Example: If UX didn't distinguish manager flows from engineer flows, stories would bundle both into "survey feature" epic
   - Impact: Stories oversized → plans too generic

4. **Weak Stories → Weak Plans**
   - Example: If story said "implement survey response API" without specific criteria, plan might say "validate payload and store in database"
   - Impact: Plans not actionable → developers ask clarifying questions

### Observed: No Breaks
- Each stage had sufficient quality to enable the next
- No cascading failures
- Clean information flow from PRD through to actionable Plan

---

## Root Cause Analysis: Quality Dependencies

**PRD Quality** → drives Architecture scope  
**Architecture Quality** → drives UX specificity (tech stack determines interaction patterns)  
**UX Quality** → drives Story right-sizing (flows become epics; interactions become stories)  
**Story Quality** → drives Plan actionability (clear AC trace to implementation steps)

**Conclusion:** The upstream command quality is the primary determinant of downstream plan quality. A strong PRD cannot be rescued by a strong Plan command if the Architecture or UX is weak.

---

## Implications

1. **Invest in Early Stages:** PRD and Architecture quality disproportionately impact implementation clarity
2. **No "Plan-Command Magic":** Even with excellent Plan Story command, weak upstream produces weak plans
3. **Load-Bearing Test:** Run a weak PRD through the entire pipeline to observe cascade of failures

