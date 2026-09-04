# AI Self-Directed Learning: SDLC Prompt Engineering

A comprehensive study in Explicit Deliberate Documentation (EDD) and prompt engineering for Large Language Models. Building and optimizing a family of SDLC commands (Product Requirements Documents, Architecture, UX, Epics, Planning, Implementation, Code Review) using iterative prompt refinement and model-specific optimization.

## Project Structure

```
/module-1          — Create-PRD command (Pomodoro timer domain)
  /commands        — Prompt definitions and test configurations
  /analysis        — Test results, audits, and reflections
  README.md        — Module 1 overview

/module-2          — SDLC pipeline extension (TeamPulse domain + future)
  /exercise-5      — Create-PRD validation on enterprise domain
  /commands        — Shared command prompts
  /analysis        — Cross-command analysis
  /checkpoints     — Model Ladder and regression status
  README.md        — Module 2 overview

/docs              — Cross-cutting documentation
  create-prd-progression.md — Command improvement across domains
  README.md        — Docs index

/claude.js         — Anthropic SDK integration for prompt evaluation
```

## Quick Start

### Module 1: Create-PRD Command

See [module-1/README.md](module-1/README.md) for:
- Prompt baseline and final state
- 6 test cases (Pomodoro timer)
- Load-bearing instruction audit
- Model Ladder analysis

**Result:** Sonnet 6/6 (100%) Green State ✅

### Module 2: Exercise 5 (Create-PRD on TeamPulse)

See [module-2/README.md](module-2/README.md) for:
- Create-PRD validation on enterprise domain
- 4 new test cases (Scope, Roles, Retention, Anonymity)
- Domain-agnostic instruction discovery
- Haiku-only eval transition guidance

**Result:** Sonnet 4/4 (100%), Haiku 1/4 (25%) — 3 instructions reusable

## Key Concepts

### Explicit Deliberate Documentation (EDD)
A structured approach to building and optimizing LLM prompts:
1. Write test cases first (before modifying prompt)
2. Run baseline eval
3. Diagnose failures (Context gap vs. Constraint gap)
4. Iterate with hypotheses
5. Load-bearing audit new instructions
6. Document learnings

### Model Ladder
Performance gap between two LLM models (e.g., Sonnet vs. Haiku). Used to diagnose:
- Which instructions are truly load-bearing (not decorative)
- Which inference patterns one model makes but another doesn't
- Where to add explicit scaffolding for weaker models

### Green State
All test cases passing for the target model. For Module 1: Sonnet 6/6. Indicates the prompt is well-specified and no instructions are missing.

## Results Summary

| Exercise | Domain | Sonnet | Haiku | Delta | Key Achievement |
|----------|--------|--------|-------|-------|-----------------|
| Module 1 | Pomodoro | 6/6 ✅ | 1/6 | 4 | Green state; 2 instructions load-bearing |
| Ex 5 | TeamPulse | 4/4 ✅ | 1/4 | 3 | 2 instructions transferable to new domain |

**Net Progress:** +25 pp improvement on complex domain with only 2 new instructions

## Next Steps

- **Exercises 6-10:** Build 5 new SDLC commands (Architecture, UX, Epics, Plan, Implement, Review)
  - Each: Haiku-only evals, 1-2 iterations, load-bearing audit
  - Expected pattern: 2-3 new instructions per command

- **Exercise 11:** Full SDLC pipeline stress test using Blackjack kata
  - Run all 7 commands end-to-end
  - Measure consistency and quality across domains

## File Naming Conventions

- **Prompts:** `create-{command}-prompt.yaml` or `create-{command}-prompt.md`
- **Tests:** `create-{command}-{domain}-tests.yaml`
- **Results:** `{domain}-test-results.md`, `{domain}-iterations.md`, `{domain}-analysis.md`
- **Audits:** `load-bearing-audit.md`, `model-ladder-audit.md`
- **Checkpoints:** `model-ladder-checkpoint.md`, `regression-check.md`

## Repository Status

✅ **Module 1 Complete:** Create-PRD command built and optimized  
✅ **Exercise 5 Complete:** Validated on enterprise domain  
🔄 **Module 2 in Progress:** Building SDLC pipeline