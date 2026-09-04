# Exercise 9 Iteration Log — Plan Story

## ✅ Iteration 1 & 2: Stack-Load-Bearing Test (Critical)

**Date:** 2026-09-04 18:48
**Result:** 4/4 PASSED ✅
**Duration:** 1m 27s

### Test Setup
- **Same Story:** ES-5 Engineer Submits Survey Response
- **Same Acceptance Criteria:** 8 AC covering validation, error handling, anonymization, performance, mobile
- **Two Stacks:**
  - Node.js 20 + Express.js 4 + PostgreSQL 16 + Prisma + Zod
  - Python 3.11 + FastAPI + SQLite + SQLAlchemy + Pydantic

### Output Differences Observed

**Node.js/Express Output:**
- Mentions: "Database Schema — Three new tables with schema-level anonymity enforcement"
- Framework: Express.js middleware pattern
- Validation: Zod schema (implied from context)
- ORM: Prisma (implied from context)

**Python/FastAPI Output:**
- Mentions: "Pydantic models... FastAPI implementation steps"
- Framework: FastAPI route decorators (explicit)
- Validation: Pydantic models
- ORM: SQLAlchemy
- Database: "SurveyToken, SurveyResponse, ResponseAnswer tables with indexes"

### Assessment
✅ **STACK IS LOAD-BEARING.** Plans differ in specific, named ways:
- Framework names (Express vs FastAPI)
- Validation libraries (Zod vs Pydantic)
- ORM patterns (Prisma vs SQLAlchemy)
- Database table structure mentions

Context is working as intended — same story with different tech stacks produces different implementation plans.

---

## ✅ Iteration 3: Node.js Detailed Plan with Transaction Patterns

**Date:** 2026-09-04 18:51
**Result:** 1/1 PASSED ✅
**Duration:** 1m 12s

### Changes
- Added Constraints emphasizing specific patterns: Prisma methods (findUnique, create, transaction), async/await, data consistency
- Focused on transaction patterns for anonymization enforcement (ensuring atomicity)

### Assessment
Output produced detailed plan with transaction considerations. Demonstrates that Constraints can drive focus to specific technical patterns.

---

## Summary: Haiku 5/5 (100%)

Three iterations + stack-load-bearing test:
- **Iteration 1:** Node.js/Express/Postgres plan ✅
- **Iteration 2:** Python/FastAPI/SQLite plan ✅ (same story, different stack)
- **Iteration 3:** Node.js detailed plan with transactions ✅

**Green State Hypothesis:** Haiku produces stack-specific, detailed plans when Context names the tech stack and Constraints demand specific libraries/patterns.

