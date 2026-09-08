# Automation Spectrum Assessment

## Overview

This assessment evaluates the automation potential of key commands across the self-directed learning program, categorizing them by automation level and implementation complexity.

---

## Commands by Automation Level

### Level 5: Fully Automated with Governance (Highest)

**create-prd** (Skill)
- **Status:** ✅ Implemented
- **Automation:** Reads input → generates PRD → validates sentinel → auto-chains to next step
- **Governance:** Validation gate blocks insufficient PRDs
- **Race condition handling:** Yes (hook retry logic for file timing)
- **Folder-agnostic paths:** Yes (./script.sh from any directory)
- **Output:** Deterministic (same input always produces same result)
- **Complexity:** Medium (requires skill system + hooks + chaining logic)
- **Used in:** Exercise 15

**create-architecture** (Skill)
- **Status:** ✅ Implemented
- **Automation:** Reads PRD → generates architecture → writes output
- **Governance:** Only invokes if PRD passed validation
- **Chains from:** create-prd (auto-invoked on validation pass)
- **Folder-agnostic paths:** Yes
- **Output:** Deterministic
- **Complexity:** Medium (requires skill system + proper PRD dependency handling)
- **Used in:** Exercise 15 (chained from create-prd)

---

### Level 4: Automated Workflow with Manual Trigger (High)

**Potential candidates for conversion:**
- create-prd (earlier iterations without auto-chaining)
- create-architecture (if invoked standalone)
- Any prompt-based command that reads input files and writes structured output

---

### Level 3: Semi-Automated (Medium)

**Characteristics:**
- Manual input required
- Structured output file generation
- Potential for validation hooks
- Could chain to other workflows

**Candidates:**
- Commands that generate tests/assertions
- Commands that create documentation
- One-way transformations (requirements → implementation sketches)

---

### Level 2: Manual with Tool Assistance (Low)

**Characteristics:**
- Human-driven workflow
- AI assistance for content generation
- Manual quality review required
- Output requires human validation before progression

**Examples:**
- create-prd (early versions without validation)
- create-architecture (standalone invocation)
- Any adhoc design/analysis command

---

### Level 1: Pure Manual (Lowest)

**Characteristics:**
- No automation
- Ad-hoc invocation
- Human-decided progression
- No deterministic validation

---

## Automation Barriers and Solutions

### Barrier 1: Determining Readiness to Proceed
**Problem:** How does the system know when to auto-invoke the next step?
**Solution:** Sentinel files + validation hooks
**Used in:** Exercise 15 (proceed-to-architecture.flag)
**Applicability:** Any two-step workflow where step 2 depends on step 1 output

### Barrier 2: File Timing (Race Conditions)
**Problem:** Multiple hooks fire in parallel; one might check for a file before another writes it
**Solution:** Polling/retry loops with configurable wait intervals
**Used in:** architecture-trigger-hook.sh (wait up to 2s for flag)
**Applicability:** Any hook-based automation with sequential dependencies

### Barrier 3: Folder-Agnostic Paths
**Problem:** Scripts in one directory can't find files in another when invoked from different working directories
**Solution:** Use relative paths (./script.sh) and ensure scripts are copied to working directory
**Used in:** Exercise 15 (all scripts use ./relative/paths)
**Applicability:** Any distributed workflow across multiple exercise directories

### Barrier 4: Validation vs Quality
**Problem:** Structural validation (all sections present) ≠ content quality (vision is compelling, metrics are measurable)
**Solution:** Two-tier validation: sentinel gates for structure, Promptfoo for quality
**Used in:** Exercise 15 (sentinel validates structure; Scenario 3 shows quality gap)
**Applicability:** Any workflow where deterministic gates are needed but human judgment required for quality

### Barrier 5: Deterministic Behavior
**Problem:** Same input should produce same output and same gate decision
**Solution:** Structured input files + schema validation + deterministic validation rules
**Used in:** Exercise 15 (jq-based validation of JSON structure)
**Applicability:** Any workflow where reproducibility is required

---

## Automation Patterns

### Pattern 1: Linear Chaining (Simplest)
```
Command A → Validation Gate → Command B
```
**Example:** create-prd → sentinel validation → create-architecture
**Complexity:** Medium (requires inter-skill communication)
**Used in:** Exercise 15

### Pattern 2: Conditional Branching (More Complex)
```
Command A → Validation Gate → Branch:
  - PASS: Command B
  - FAIL: Retry with user input
```
**Complexity:** High (requires decision logic and user interaction handling)
**Not yet implemented**

### Pattern 3: Parallel Gates (Most Complex)
```
Command A → Gate 1 ✓
Command B → Gate 2 ✓
Command C → Gate 3 ✗ (blocks downstream)
  ↓ (all gates must pass)
Command D
```
**Complexity:** Very high (requires multi-step coordination)
**Not yet implemented**

---

## Implementation Complexity Matrix

| Automation Level | Skill System | Hooks | Validation | Chaining | Folder-Agnostic | Complexity |
|---|---|---|---|---|---|---|
| Level 5 | ✅ | ✅ | ✅ | ✅ | ✅ | **Very High** |
| Level 4 | ✅ | ✅ | ✅ | - | ✅ | **High** |
| Level 3 | ✅ | ✓ | ✓ | - | ✅ | **Medium** |
| Level 2 | ✓ | - | - | - | - | **Low** |
| Level 1 | - | - | - | - | - | **None** |

**Legend:** ✅ = Required, ✓ = Optional, - = Not applicable

---

## Automation Readiness Checklist

To convert a command to Level 5 (Fully Automated with Governance):

- [ ] **Input:** Structured file format (Markdown, YAML, JSON)
- [ ] **Output:** Deterministic (same input → same output)
- [ ] **Validation schema:** Defined with clear pass/fail criteria
- [ ] **Gate logic:** Implemented in hook script
- [ ] **Chaining:** Next command identified and invoked if gate passes
- [ ] **Error handling:** Clear messages for failures
- [ ] **Folder-agnostic paths:** All scripts use ./relative/paths
- [ ] **Race condition handling:** Polling/retry if parallel hooks depend on files
- [ ] **Test scenarios:** GO path (pass), NO-GO path (fail), GAP (pass/quality issue)
- [ ] **Documentation:** Test results, governance explanation, automation spectrum assessment

---

## Recommendations

### For Exercise 16+ (If Applicable)

1. **Identify Level 4 candidates:** Commands that generate structured output and could benefit from validation gates
   - Look for: Any two-step workflow where step 2 depends on step 1

2. **Implement sentinel patterns:** Create schema files for validation (similar to create-prd-sentinel-schema.md)
   - One sentinel = one validation gate
   - Multiple sentinels = multiple gates in series

3. **Add governance to weak points:** Find commands where validation is currently done manually
   - Move validation logic to hooks
   - Create deterministic gates instead of "hope it's good"

4. **Document trade-offs:** Every gate has a cost (complexity, maintenance) vs benefit (catching bad inputs early)
   - Only automate gates where false positives are rare
   - Accept that Scenario 3 cases (pass gate, fail quality) need higher-level review

---

## Current Status

- **Level 5 implementations:** 2 (create-prd, create-architecture)
- **Level 4 implementations:** 0
- **Level 3+ implementations:** 2
- **Automation coverage:** 2/11 commands (if 11 commands total in program)
- **Automation pattern used:** Linear chaining with sentinel validation

### Next Opportunity

Convert a command that currently requires manual quality review into a Level 4 workflow (automated with deterministic validation, but not full chaining). Good candidates:
- Any multi-step design process with clear interim checkpoints
- Any command that currently outputs files that need manual inspection before next step
