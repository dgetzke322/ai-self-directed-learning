# Module 2: SDLC Pipeline Commands

This directory contains all work for **Module 2 of the EDD exercise**: extending the Module 1 `create-prd` command to new domains and building 6 additional SDLC commands (architecture, UX, epics, plan, implement, review).

## Structure

- **exercise-5/** — Create-PRD validation on TeamPulse (enterprise domain)
  - `README.md` — Exercise 5 summary and Module 2 readiness assessment
  - `teampulse-analysis.md` — Step 1: Analysis of Module 1 prompt against 4 criteria
  - `teampulse-test-cases.md` — Step 2: 4 new test cases (domain-specific)
  - `teampulse-iterations.md` — Step 3: Detailed iteration log with hypotheses and load-bearing audit

- **commands/** — Prompt definitions and test configurations
  - `create-prd-teampulse-prompt.yaml` — Create-PRD prompt template (generic, domain-agnostic)
  - `create-prd-teampulse-tests.yaml` — Create-PRD test harness with TeamPulse tests

- **checkpoints/** — Model Ladder analysis and regression checking
  - `model-ladder-checkpoint.md` — Final Model Ladder state; transition to Haiku-only evals
  - `regression-check.md` — Module 1 kata compatibility verification

- **analysis/** — Will contain analysis for future commands

## Exercise 5: Create-PRD on TeamPulse Domain

**Purpose:** Validate that Module 1 prompt generalizes to more complex (enterprise) domains and identify domain-specific gaps.

### Results

| Metric | Module 1 (Pomodoro) | Exercise 5 (TeamPulse) |
|--------|------------------|----------------------|
| Sonnet | 6/6 (100%) | 4/4 (100%) ✅ |
| Haiku | 1/6 (17%) | 1/4 (25%) |
| Delta | 4 | 3 |
| Iterations | 3 | 3 |

### Key Improvements

1. **Scope Boundary Extraction** — Added to Context; fixed Test 3 (Scope Specificity) for both models
2. **Data Retention & Compliance** — Added to PRD Format; stabilized Test 4 for enterprise products
3. **Generic Context** — Removed Pomodoro-specific language; enabled domain-agnostic evaluation

### Domains Analyzed

- **Pomodoro** (Module 1): Simple, timing-critical, single-user
- **TeamPulse** (Exercise 5): Complex, enterprise, multi-tenant, data-protecting, compliance-aware

## Module 2 Transition: Haiku-Only Evals

**Starting Exercise 6**, all Promptfoo configurations run against Haiku only (not Sonnet/Haiku pairs):

- **Reasoning:** A prompt that passes Haiku is well-specified; Sonnet automatically passes
- **Efficiency:** Single-model evals reduce overhead without losing diagnostic info
- **Rigor:** Haiku constraint actually improves specification quality
- **Target:** Green on Haiku = command is done

See `checkpoints/model-ladder-checkpoint.md` for full transition guidance.

## Baseline for Exercise 6+

All new SDLC commands (architecture, UX, epics, plan, implement, review) use this baseline:

```yaml
Context: Generic (product-agnostic)
PRD Format Requirements:
  - Technical Requirements (specific choices)
  - API Requirements (endpoints with HTTP methods)
  - Non-Functional Requirements (measurable thresholds)
  - Security (OWASP/CIS/NIST with control numbers, algorithms, flags)
  - Feature Requirements (HOW/WHERE/WHAT, role, data integration)
  - Scope Boundary Extraction (extract out-of-scope items by name)
  - Data Retention & Compliance (retention, deletion, GDPR, cascade, audit)
Timing & Drift (if timing-critical)
```

## Expected Remaining Work (Exercises 6-11)

- **Exercises 6-10:** Build 5 new SDLC commands (architecture, UX, epics, plan, implement, review)
  - Each command: 1-2 iterations, Haiku-only eval, load-bearing audit
  - Expected pattern: 2-3 new instructions per command

- **Exercise 11:** Full SDLC pipeline stress test using Blackjack kata
  - Run all 7 commands end-to-end
  - Measure quality and consistency across domains

