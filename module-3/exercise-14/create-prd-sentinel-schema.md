# PRD Sentinel File Schema

## Purpose

The PRD sentinel file (`prd-sentinel.json`) is a structured checkpoint that the `create-prd` command writes after producing a PRD. The hook reads this file to enforce a minimum quality bar deterministically — checking for required sections, appropriate length, and critical content properties. 

The hook is **not** a quality evaluator (that's Promptfoo's job). It is a **gatekeeper** — it verifies that the PRD has the structural prerequisites for quality evaluation.

---

## Schema

```json
{
  "sections_present": ["overview", "requirements", "success_criteria", "out_of_scope"],
  "word_count": 850,
  "has_measurable_success_criteria": true,
  "has_explicit_out_of_scope": true,
  "has_assumptions_section": true
}
```

---

## Required Properties

| Property | Type | Required Value | On Failure |
|----------|------|---------------|------------|
| `sections_present` | array[string] | must include: `overview`, `requirements`, `success_criteria`, `out_of_scope` | **HALT** (exit 1) |
| `word_count` | number | between 500 and 3000 | **WARN** (log warning, exit 0) |
| `has_measurable_success_criteria` | boolean | must be `true` | **HALT** (exit 1) |
| `has_explicit_out_of_scope` | boolean | must be `true` | **HALT** (exit 1) |
| `has_assumptions_section` | boolean | must be `true` | **WARN** (log warning, exit 0) |

---

## Validation Logic

**HALT conditions (exit 1):** Any of these failures stops the workflow and requires manual review:
- Missing any critical section (overview, requirements, success_criteria, out_of_scope)
- Missing measurable success criteria (prevents testability)
- Missing explicit out-of-scope section (invites scope creep)

**WARN conditions (exit 0):** These log as warnings but do not stop the workflow:
- Word count outside expected range (length alone doesn't indicate quality, but extremes are suspicious)
- Missing assumptions section (nice to have, but not critical for a valid PRD)

---

## What This Does NOT Validate

This sentinel file **cannot** detect:
- Whether success criteria are actually measurable or specific (e.g., "fast" vs. "< 100ms response time")
- Whether requirements are realistic or technically sound
- Whether the out-of-scope section is justified or whether scope decisions are good
- Whether assumptions are well-reasoned or likely to hold
- Writing quality, tone, clarity, or audience appropriateness

**These are Promptfoo's responsibility.** The sentinel is a structural checkpoint only.

---

## Hook Behavior Summary

| Scenario | Sentinel Present? | Required Fields OK? | Hook Action | Exit Code |
|----------|---|---|---|---|
| Perfect PRD | Yes | Yes | Log PASS | 0 |
| Missing section | Yes | No | Log FAIL + section name | 1 |
| No success criteria | Yes | No | Log FAIL + specific reason | 1 |
| Good structure, short | Yes | Yes (but word count low) | Log WARN + count | 0 |
| Sentinel missing | No | N/A | Log FAIL + file not found | 1 |

---

## Example Hook Output

**PASS:**
```
[2026-09-08T15:15:23Z] PASS: PRD sentinel validation passed. Sections: overview, requirements, success_criteria, out_of_scope. Word count: 1245.
```

**FAIL (missing section):**
```
[2026-09-08T15:15:23Z] FAIL: PRD missing required section: out_of_scope
```

**WARN (word count low):**
```
[2026-09-08T15:15:23Z] WARN: PRD word count (280) is below recommended minimum (500). Validate content quality manually.
```
