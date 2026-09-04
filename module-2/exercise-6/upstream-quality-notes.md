# Upstream Quality Impact on Architecture

## Test Setup

**High-Quality PRD:** TeamPulse from Exercise 5 (full multi-section PRD with detailed specs)
**Weak PRD:** Minimal description (2-3 sentences, vague requirements)

## Expected Impact

### High-Quality PRD Should Produce:
- ✅ Specific component descriptions (React 18, Express 4, PostgreSQL 16, Prisma)
- ✅ Detailed data model (managers, teams, survey_configs, survey_instances, responses, survey_tokens)
- ✅ Schema-level privacy design (no FK from responses to team_members)
- ✅ Specific performance bounds (±60s dispatch, ±30s close, <1.5s p95 form, <500ms p95 dashboard)
- ✅ Multi-tenant isolation explanation (manager_id scoping)
- ✅ Open decisions with "why it matters" (scheduler scaling, session storage, analytics)
- ✅ Explicit drift-correction mechanism (wall-clock reconciliation, scheduler_log, drift reporting)

### Weak PRD ("Anonymous team survey system") Would Produce:
- ❌ Generic component descriptions ("frontend/backend/database")
- ❌ Minimal data model (tables mentioned but relationships unclear)
- ❌ Vague privacy approach ("keep data anonymous")
- ❌ No specific performance targets
- ❌ Multi-tenancy mentioned but not architectured
- ❌ No open decisions or design rationale
- ❌ Drift correction mentioned but not specified

## Key Finding

**Better PRDs → Better Architectures** — The architecture command synthesizes from what's available. A weak PRD cannot yield specific architectural decisions; a rich PRD enables deep architecture work.

This validates that the **create-prd command quality directly gates architecture quality**. An SDLC pipeline depends on upstream output quality.

## Implication for Module 2+

Commands are ordered: PRD → Architecture → UX → Epics → Plan → Implement → Review

If Create-PRD output is vague, all downstream commands will struggle to make specific decisions. This justifies Exercise 5's focus on making create-prd robust and specific.
