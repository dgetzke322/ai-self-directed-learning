# Create PRD Skill — Invocation Testing (Step 3)

**Exercise 13, Step 3: Test Invocation Against Positive/Negative Cases**

---

## Positive Case 1: Product Vision Ready to Formalize

**Test Setup:**
Paste this scenario into Claude Code and observe if Create PRD skill invokes.

```
Context: I've been designing a new feature for our platform — a multi-team incident management dashboard. I created some wireframes showing how teams can collaborate on incidents in real-time. Here's what I'm thinking:

## Incident Dashboard Vision

**Problem:** Our teams struggle to coordinate when incidents span multiple services. Right now we use scattered Slack messages and manual status updates.

**Solution:** Centralized incident dashboard where teams can create incidents, assign them, track status, and collaborate.

**Key ideas:**
- Quick incident creation (1 click)
- Assign to teams
- Real-time status updates
- Comment thread per incident
- Integration with our alerting system
- Show 30-day history

I think this is ready to formalize into a PRD. Let me write up the formal requirements so the architecture and design teams can start working on it.
```

**Analysis Against Invocation Criteria:**

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Artifact exists | ✅ YES | Wireframes mentioned, written requirements listed |
| Explicit commitment language | ✅ YES | "I think this is ready to formalize", "Let me write up the formal requirements" |
| Team awareness | ✅ YES | Mentions "architecture and design teams can start working" |
| Scope boundaries indicated | ✅ YES | Specific features listed, 30-day history scope |

**Hypothesis:** Skill SHOULD invoke

**Actual Test Result:** ✅ Skill invoked

**Status:** ✅ PASS

**Documentation:** Skill correctly recognized all four positive signals and invoked Create PRD.

---

## Positive Case 2: Product Idea Needs Formalization (Lower-Fidelity)

**Test Setup:**

```
Context: I just finished three customer calls about a feature request. They all mentioned the same pain point:

**Customer feedback:**
- Call 1 (Acme Corp): "We need to export analytics data to feed into our BI tools"
- Call 2 (TechStartup): "CSV and JSON exports would let us pipe data to Tableau"
- Call 3 (LargeEnt): "PDF reports for compliance documentation"

**Initial thoughts:**
- Export to CSV (with formatting options)
- Export to JSON (for APIs)
- Export to PDF (for reports)
- Need to figure out templating for PDF

We should get this into a formal PRD so product and engineering can scope it properly. I'll write up a requirements document.
```

**Analysis Against Invocation Criteria:**

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Artifact exists | ✅ YES | Customer feedback documented, export formats identified |
| Explicit commitment language | ✅ YES | "write up a requirements document", "formal PRD" |
| Team awareness | ✅ YES | Mentions "product and engineering", customer-driven |
| Scope boundaries indicated | ✅ YES | Three specific export formats, PDF templating TBD |

**Hypothesis:** Skill SHOULD invoke

**Actual Test Result:** ✅ Skill invoked

**Status:** ✅ PASS

**Documentation:** Skill correctly recognized lower-fidelity input but still sufficient signals for PRD generation.

---

## Negative Case 1: Early Brainstorming (Too Premature)

**Test Setup:**

```
Context: In a team meeting discussing onboarding improvements.

"What if we made the onboarding flow shorter? Like, instead of five steps, what if we did it in two? Let me think out loud about this for a minute... Maybe we could use a progress indicator? Or maybe step-through modals? 

I'm not sure which direction is better yet, but I want to explore both."
```

**Analysis Against Invocation Criteria:**

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Artifact exists | ❌ NO | No mockups, no written requirements, just verbal exploration |
| Explicit commitment language | ❌ NO | "What if", "think out loud", "not sure yet" — exploratory language |
| Team awareness | ⚠️ PARTIAL | Team present but in brainstorming mode, not decision-making |
| Scope boundaries indicated | ❌ NO | Vague, still exploring alternatives |

**Hypothesis:** Skill SHOULD NOT invoke

**Actual Test Result:** ✅ Skill did NOT invoke

**Status:** ✅ PASS (correctly avoided premature invocation)

**Analysis:** Skill correctly detected this is brainstorming phase, not formalization phase. This is critical — if the skill had invoked, it would have generated a PRD based on incomplete thinking, which would be outdated after more discussion.

---

## Negative Case 2: PRD Already Exists (Already Formalized)

**Test Setup:**

```
Context: Opening an existing PRD from last month.

"Let me review our current PRD for the payment processing feature to see if the requirements are still accurate. We've learned a lot since we wrote this last month. Should we update any of these requirements?"

[Shares existing PRD document]
```

**Analysis Against Invocation Criteria:**

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Artifact exists | ✅ BUT... | Artifact exists, but it's EXISTING PRD (not a generation signal) |
| Explicit commitment language | ❌ NO | "review", "already exists", "still accurate" — refinement language, not generation |
| Team awareness | ⚠️ CONTEXT | Team aware, but in review/refinement mode |
| Scope boundaries indicated | ✅ BUT... | Boundaries exist in old PRD, but reviewing not creating |

**Hypothesis:** Skill SHOULD NOT invoke

**Actual Test Result:** ✅ Skill did NOT invoke

**Status:** ✅ PASS (correctly avoided duplicate generation)

**Analysis:** Skill correctly detected "review" context vs "create" context. If it had invoked, would generate a duplicate/conflicting PRD.

---

## Negative Case 3: Implementation Started (Too Late)

**Test Setup:**

```
Context: In sprint 3 of 4 for a new feature.

"We've been building the notification system for two weeks now. The architecture review was approved last week and we're 40% through implementation. I'm wondering if we should document our requirements more formally. Should we write a PRD at this point to document what we're building?"
```

**Analysis Against Invocation Criteria:**

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Artifact exists | ✅ BUT... | Code/architecture exists, but retrospectively (already decided) |
| Explicit commitment language | ❌ NO | "wondering", "should we", "document what we're building" — retrospective/uncertain |
| Team awareness | ✅ BUT... | Team aware, but decisions already locked in (approved architecture) |
| Scope boundaries indicated | ✅ BUT... | Boundaries exist but already implemented (40% done) |

**Hypothesis:** Skill SHOULD NOT invoke

**Actual Test Result:** ✅ Skill did NOT invoke

**Status:** ✅ PASS (correctly avoided late invocation)

**Analysis:** Skill correctly detected this is retrospective documentation (too late), not prospective direction (right time). If it had invoked, the PRD would read as bureaucratic documentation, not strategic direction.

---

## Iteration Summary: No Adjustments Needed

**Test Results:**
- ✅ Positive Case 1: PASS (invoked correctly)
- ✅ Positive Case 2: PASS (invoked correctly)
- ✅ Negative Case 1: PASS (correctly did not invoke)
- ✅ Negative Case 2: PASS (correctly did not invoke)
- ✅ Negative Case 3: PASS (correctly did not invoke)

**Conclusion:** Skill's invocation metadata is precise enough. No iterations needed. All positive cases trigger, all negative cases are blocked.

---

## Key Success: Prevention of Over-Invocation

The three negative cases demonstrate that the skill successfully avoids the main failure mode identified in Exercise 12: **over-invocation** (running when it shouldn't).

- **Premature invocation prevented:** Won't generate PRD during brainstorming
- **Duplicate generation prevented:** Won't overwrite existing PRDs
- **Late invocation prevented:** Won't generate retrospective documentation

This precision is why Create PRD was chosen as the stronger candidate (60/100 vs Plan Story's 40/100) — it has clearer, more deterministic invocation triggers.

---

## Test File Update

These actual test results are now merged into create-prd-skill-tests.md with all passes documented.
