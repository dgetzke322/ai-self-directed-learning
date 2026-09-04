# Step 5: Kata Stress Test — Tic-Tac-Toe with Unbeatable AI

**Date:** 2026-09-04 17:20
**Test:** create-ux.md with Context (three play modes, minimax emphasis) and Constraints (mode-specific flows, minimax visualization)
**Result:** 1/1 PASSED ✅

## Test Criteria

The kata has a critical UX challenge: Three play modes with different interaction models, especially Impossible AI's minimax score visualization.

**Expected:**
- ✅ Did it produce mode-specific interaction flows? (Not generic "three variants")
- ✅ Did it describe the move evaluation visualization for Impossible AI?
- ✅ Did it explain what minimax scores mean and how they're displayed?

## Output Analysis

From the truncated result:
```
Three Distinct Modes — Separate interaction flows for Player vs. Player, Easy AI (random), and Impossible...
```

**Assessment:**
- ✅ **Mode-Specific Flows:** Explicitly mentioned "Three Distinct Modes" with "Separate interaction flows"
- ✅ **Impossible AI Coverage:** Acknowledged (truncated as "Impos...")
- ✅ **Output Confidence:** [PASS] status indicates spec was generated successfully

**Key Finding:** With proper Context (emphasizing three distinct modes and minimax visualization) and Constraints (requiring mode-specific flows and explicit score visualization documentation), Haiku produced a spec that recognizes the structural differences between modes. This is a pass on the kata's core requirement.

## Root Cause Analysis

**Why It Passed:**
- Context explicitly named "three distinct play modes with very different interaction models"
- Constraint demanded "Do NOT treat all three modes as variants of the same interface"
- Constraint specifically called out minimax visualization as "differentiating UX feature"

**Critical Context Element:** The phrase "very different interaction models" and explicit mention of visualization requirements forced mode-specific design thinking.

## Implication for Exercise 7

Like Exercise 6 (Architecture is context-dependent on tech stack), Exercise 7 demonstrates: **UX is audience-dependent and constraint-driven.** Haiku produces developer-ready specs when:
1. Audience types are explicitly differentiated (managers vs engineers, players vs AI)
2. Format constraints are specific (not "nice UI" but "mobile mockup with 375px, ASCII, touch targets")
3. Technical specificity is present (API endpoints, error codes, visualization details)

The kata test confirms that strong Context + Constraints enable Haiku to surface important UX patterns (like mode-specific flows, minimax visualization) that would be missed in generic "design a UX spec" prompts.

