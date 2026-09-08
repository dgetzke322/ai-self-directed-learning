# Governed Flow Test Results

## Scenario 1 (GO Path)

**Input:** Mobile Fitness Tracker product vision with complete problem statement, solution, requirements, success metrics, and scope boundaries

**Sentinel values:**
```json
{
  "sections_present": ["Problem Statement", "Solution", "Key Requirements", "Technical Context", 
                       "V1 Scope & Boundaries", "Non-Functional Requirements", "Success Metrics", 
                       "Assumptions", "Open Questions & Decisions"],
  "word_count": 1350,
  "has_measurable_success_criteria": true,
  "has_explicit_out_of_scope": true,
  "has_assumptions_section": true
}
```

**Hook decision:** PASS

**Architecture triggered:** Yes

**Notes:** Full automated flow successful. PRD generated (prd-mobile-fitness-tracker.md), sentinel validated, and architecture auto-generated (architecture-mobile-fitness-tracker.md) without manual intervention. All 9 required sections present with measurable success criteria (10k downloads, 60% D7 retention) and explicit out-of-scope deferments (social features, AI coaching, wearables to V2+).

---

## Scenario 2 (NO-GO Path)

**Input:** File Sharing App with intentionally incomplete vision. Sparse problem statement ("Users need to share files"), bare requirements, and missing success criteria/scope boundaries.

**Sentinel values:**
```json
{
  "sections_present": ["Problem Statement", "Solution", "Key Requirements", "Technical Context", 
                       "V1 Scope & Boundaries", "Non-Functional Requirements", "Success Metrics", 
                       "Assumptions", "Open Questions & Decisions"],
  "word_count": 150,
  "has_measurable_success_criteria": false,
  "has_explicit_out_of_scope": false,
  "has_assumptions_section": false
}
```

**Hook decision:** FAIL

**Failure messages:**
- Word count 150 (below minimum ~500)
- has_measurable_success_criteria: false — Success Metrics section contains no specific targets
- has_explicit_out_of_scope: false — V1 Scope section does not define what's deferred to V2
- has_assumptions_section: false — Assumptions section empty ("None stated")

**Architecture triggered:** No

**Notes:** Governance gate blocked insufficient PRD. No architecture document generated. Flow halted with clear validation failures. User must improve PRD with measurable success criteria, explicit scope boundaries, and assumptions before retry.

---

## Scenario 3 (GAP Scenario)

**Input:** Task Management System with all required sections but minimal detail. Structurally complete but vague vision ("Teams need task management"), weak requirements, generic success metrics ("adoption and user satisfaction").

**Sentinel values:**
```json
{
  "sections_present": ["Problem Statement", "Solution", "Key Requirements", "Technical Context", 
                       "V1 Scope & Boundaries", "Non-Functional Requirements", "Success Metrics", 
                       "Assumptions", "Open Questions & Decisions"],
  "word_count": 280,
  "has_measurable_success_criteria": true,
  "has_explicit_out_of_scope": true,
  "has_assumptions_section": true
}
```

**Sentinel pass/fail:** PASS (all required fields present)

**Quality gap:** PRD passes structural validation but exhibits low quality:
- Vague problem statement (no specific user segment)
- Generic requirements without measurability (not "response < 100ms" but "fast")
- Weak success metrics (not "10k users, 60% retention" but "adoption and satisfaction")
- Minimal out-of-scope justification

**Architecture ran:** Yes (auto-chained after validation pass)

**Architecture output:** Generated implementation-ready document (22KB) but with 7 open technical decisions to compensate for PRD gaps. Architecture explicitly documented unknowns and deferred decisions until PRD is clarified.

**Notes:** This scenario demonstrates the critical gap between *structural* validation and *quality* validation. The sentinel gate ensures all required sections exist and marked criteria are present, but does not evaluate whether criteria are actually measurable, whether the vision is compelling, or whether requirements are realistic. A Promptfoo-style quality assertion would flag this as failing quality review despite passing structural validation.

---

## Scenario 4 (Missing Sentinel)

**Trigger:** Manually ran prd-sentinel-hook.sh without a sentinel file present (simulates PRD generation command that failed silently)

**Hook behavior:** 
```
[2026-09-08T19:00:51Z] FAIL: prd-sentinel.json not found
```

**Exit code:** 1 (failure)

**Trigger flag:** NOT created

**Architecture triggered:** No

**Notes:** Hook detects missing sentinel file immediately with clear error message. Flow halts gracefully. This handles the edge case where the PRD generation command fails silently or is interrupted, leaving no sentinel file. The hook prevents false progression—if there's no validation checkpoint, the flow does not advance to architecture. User sees clear message that sentinel file is missing and must re-run PRD generation.

---

## Governance Model Summary

### What Passes Validation:
- ✅ All 9 required sections present in PRD
- ✅ Success criteria fields marked as present (even if weak)
- ✅ Out-of-scope section exists (even if minimal)
- ✅ Assumptions documented (even if sparse)
- ✅ Word count >= ~500 (heuristic, not strict hard fail)

### What Fails Validation:
- ❌ Missing any required section
- ❌ Success criteria field marked false
- ❌ Out-of-scope section missing or empty
- ❌ Assumptions section missing or empty
- ❌ Sentinel file doesn't exist

### Validation Does NOT Check:
- ❌ Whether success criteria are actually measurable (Scenario 3 fails this)
- ❌ Whether problem statement is specific (Scenario 3 is generic)
- ❌ Whether requirements are realistic or achievable
- ❌ Whether the vision is compelling or clear
- ❌ Quality of writing or coherence

### Key Outcome:
Governance gates control *structural completeness*, not *content quality*. Scenario 2 proves gates block insufficient PRDs. Scenario 3 proves gates pass low-quality but structurally valid PRDs. Quality evaluation requires separate mechanism (human review, Promptfoo assertions, architect sign-off).

### Automation Reliability:
- ✅ Hooks execute reliably on Write events
- ✅ Folder-agnostic paths (./script.sh) work from any directory
- ✅ Race condition handled: architecture-trigger-hook waits 2s for flag
- ✅ Deterministic: same input always produces same validation result
- ✅ Clear error messages for failures
