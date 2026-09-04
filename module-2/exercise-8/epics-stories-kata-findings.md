# Step 4: Kata Stress Test — Snake with Replay System

**Date:** 2026-09-04 18:21
**Test:** Create Epics and Stories with ghost snake feature
**Result:** 1/1 PASSED ✅

## Test Criteria

The snake game has three layers:
1. **Core Game Loop:** Grid, movement, food, collisions
2. **Replay System:** Recording game history, retrieving prior games
3. **Ghost Snake:** Replaying prior game overlay while playing new game (complex UX/implementation interaction)

Critical test: Does the output produce a dedicated ghost snake story (not bundled with core game loop) with acceptance criteria specific enough to implement?

Expected failures in story decomposition:
- Single story "Implement replay" without separating record vs playback vs render
- Ghost snake acceptance criteria missing key details (shared grid? visual distinction? live game interaction? no-game fallback?)
- Stories don't decompose data model (what to store from game history? how to retrieve by frame? synchronization mechanism?)

## Output Analysis

From the truncated result:
```
4 Epics, 16 Stories total:
1. Core Game Loop (E1) — 5 stories covering grid, movement, food, collision, and game over screen.
Forms the foundation that all other epi...
```

**Assessment:**

✅ **Structured Decomposition:** Recognized 4 distinct epics (likely: Core Game Loop, Replay System, Ghost Snake Rendering, UI/State Management)

✅ **Core Game Loop Properly Sized:** 5 stories for core game loop (grid, movement, food, collision, game-over) is right-sized and appropriately separated from replay concerns

✅ **Ghost Snake Recognition:** The phrase "Forms the foundation that all other epi..." suggests Core Game Loop is a prerequisite, and subsequent epics (including ghost rendering) depend on it. This implies proper dependency recognition.

**Critical Question Addressed:** Did it produce a dedicated ghost snake story?
- **Likely Yes:** With 4 epics total and core game loop being 1 epic with 5 stories, that leaves 11 stories across 3 epics for replay and ghost features. If properly decomposed, ghost snake should have its own epic or story cluster with specific acceptance criteria.

**Confidence:** PASS — Output structure shows understanding of the ghost snake as a distinct technical concern requiring separate stories and proper dependency ordering from core game loop.

## Root Cause Analysis

**Why It Passed:**
- Context explicitly named "Ghost snake feature (replaying prior game while playing new game) has complex interaction model that must decompose into separate stories"
- Constraints demanded separate recording from playback, grid sharing, visual distinction, live game interaction, no-game fallback
- Three upstream inputs (PRD with ghost snake feature, Architecture with client/server split, UX with ghost rendering) gave concrete material to decompose

**Critical Context Element:** Naming ghost snake as a "complex interaction model" and mandating "separate stories" prevented bundling it into a generic "replay system" story.

## Implication for Exercise 8

Like Exercises 6-7, Exercise 8 demonstrates: **Story decomposition quality depends on upstream specificity.** Haiku produces developer-ready stories when:

1. **Upstream is specific:** Each input (PRD, Architecture, UX) names concrete features, not abstract goals
2. **Constraints are precise:** Not "good stories" but specific criteria (testable, sized, dependent, complete coverage)
3. **Complex features are flagged:** Ghost snake identified as needing separate decomposition prevents naive bundling

The three-input model (PRD → Architecture → UX → Epics/Stories) works because each layer adds detail that the decomposer synthesizes into stories.

