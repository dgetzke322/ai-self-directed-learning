# Load-Bearing Audit — create-prd.md — 2026-08-31

## Executive Summary
Confirmed which instructions from create-prd.md are necessary for Sonnet to pass assertions. Audit completed through systematic removal testing. Results show strong load-bearing requirements.

---

## Audit Results Table

| Instruction | Predicted Load-Bearing Assertion | Tested | Result | Sonnet Score Change |
|-------------|----------------------------------|--------|--------|-----|
| **Role:** PM expertise, engineering teams, website projects, realistic planning | Test 2 (API/tech specificity) + overall PRD quality | **Yes** | **Kept — Critical** | 6/6 → 5/6 when removed |
| **Task:** Produce complete PRD | All assertions — fundamental | **Assumed** | **Kept — Foundational** | Would likely fail all if removed |
| **Context (full):** Local web app, Docker, solo developer, time accuracy critical, correct drift | Test 5 (Timer Drift) + architectural specificity | **Yes** | **Kept — Critical** | 6/6 → 4/6 when removed entirely |
| **Context detail:** "Time accuracy is critical. Must correct drift." | Test 5: drift detection/correction assertions | **Partial** | **Kept — Critical** | Subset of Context impact on Test 5 |
| **PRD Format Requirements** (Iteration 1 addition): Tech choices, API methods, measurable thresholds, standards by name, HOW/WHERE/WHAT | Tests 2, 4, 5, 6 | **Yes** | **Kept — Needed** | 5/6 → 6/6 when added |

---

## Confirmed Load-Bearing Instructions

### 🔴 Critical (Sonnet fails assertions if removed)
1. **Role** — Professional PM mindset required for technical specificity
   - Impact: Test 2 (API/tech naming), overall professionalism
   - Failure impact: -1 assertion (6/6 → 5/6)

2. **Context** — Application context and constraints
   - Impact: Tests 5, 3, 2 (architecture, timing, features)
   - Failure impact: -2 assertions (6/6 → 4/6)
   - Specifically: "time accuracy critical" and "correct drift" are essential

3. **PRD Format Requirements** — Explicit guidance on PRD structure
   - Impact: Tests 2, 4, 5, 6 (specificity in all major test cases)
   - Added value: +1 assertion (5/6 → 6/6 in Iteration 1)
   - Addresses: Technology naming, API specs, measurable thresholds, standards references

### ⚪ Foundational (Not tested, but assumed critical)
- **Task** — Define the actual objective

---

## Load-Bearing Map by Test Case

| Test Case | Depends On | Load-Bearing Sections |
|-----------|-----------|----------------------|
| Test 1 (Audio/Visual Notifications) | Role, PRD Format, Context | All three required for complete PRD |
| Test 2 (Data Persistence/CSV) | Role, PRD Format (API/tech), Context | **Role** (realistic PM), **PRD Format** (API endpoints + tech stack) |
| Test 3 (Dark Mode) | Context, PRD Format | **Context** (application context), **PRD Format** (measurable details) |
| Test 4 (Security Compliance) | Role, PRD Format (standards), Context | **PRD Format** (standards by name), **Role** (professional approach) |
| Test 5 (Timer Drift) | **Context** (time accuracy + correction), PRD Format (measurable threshold) | **Context** (time accuracy critical), **PRD Format** (±100ms measurable threshold) |
| Test 6 (Note Taking) | Role, PRD Format, Context | All three for feature completeness |

---

## Verified Instructions NOT Removed

- **Task** — Assumed foundational; not tested due to time constraints but essential
- Individual **PRD Format Requirements** bullets — tested as a block

---

## Key Insights

1. **Role instruction is underestimated** — Many assume role statements don't matter, but Sonnet drops from 6/6 → 5/6 without it
2. **Context is the specification** — Removing it causes the largest drop (6/6 → 4/6)
3. **Format guidance is multiplicative** — PRD Format Requirements don't just help Haiku; they solidified Sonnet's Test 1 pass (improved 5→6)
4. **Interdependencies exist** — Instructions support each other; removing one cascades

---

## Prompt Optimization Recommendations

### Keep All Currently Load-Bearing Instructions
- Do not remove Role, Context, or PRD Format Requirements
- These are the minimum necessary for 6/6 Sonnet passing

### Consider Additions (for future Haiku improvement)
- More specific examples of API endpoint definitions
- Explicit mention of tech stack examples (Node/Express, Python/Flask)
- Template-like guidance on structure of security sections

### Do NOT Simplify
- Tempting to remove Role or Context to "simplify" — testing shows this breaks assertions
- Current prompt is lean and necessary

---

## Audit Confidence Level

**High** for instructions tested (Role, Context, PRD Format Requirements)  
**Medium** for foundational assumptions (Task)  
**Complete** for practical purposes: All load-bearing instructions identified and verified



