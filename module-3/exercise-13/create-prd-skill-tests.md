# Create PRD Skill — Test Cases

**Exercise 13, Step 1: Invocation and Quality Test Cases**

**Skill:** Create PRD (converted from Module 2, Exercise 4-5 command)

**Key Principle:** A skill is tested on TWO dimensions:
1. **Invocation correctness** — Does the skill invoke when it should? Does it NOT invoke when it should not?
2. **Output quality** — When the skill does invoke, is the output high-quality?

Over-invocation (skill runs when it shouldn't) is worse than under-invocation (skill doesn't run when it should). This test file focuses on preventing over-invocation.

---

## Positive Invocation Cases (Skill SHOULD Invoke)

### Positive Case 1: Product Vision Ready to Formalize

**Scenario:** Engineer has sketched out a new feature (multi-team incident management dashboard) and is ready to translate the vision into formal requirements for the team.

**Context:**
- Engineer has spent 2-3 hours thinking about the feature
- Created a design mockup (rough but clear)
- Written 5-6 bullet points of high-level requirements
- Shared mockup and notes with the team
- Explicitly says: "I think this is ready for a formal PRD. Let me write up the requirements."

**Signals that indicate this is correct invocation time:**
- Explicit commitment language ("I think we should build this")
- Mockup/design artifact exists (not just brainstorming)
- Requirements points are documented (not vague)
- Team is engaged (not just the visionary thinking alone)

**Expected behavior:** Skill invokes Create PRD

**Expected output quality:** PRD should include:
- Clear problem statement
- Solution description
- Key requirements (4+ features)
- Technical context (if applicable)
- V1 scope boundaries
- Non-functional requirements

---

### Positive Case 2: Product Idea Needs Formalization (Lower Fidelity Input)

**Scenario:** Product manager has collected feedback from three customer conversations about a missing feature (better analytics export). Notes are rough but complete.

**Context:**
- Notes from three customer calls
- High-level observation: "Customers want data in multiple formats"
- Initial scope thoughts: "Export to CSV, JSON, PDF for reports"
- Rough timeline: "Needed in next quarter"
- Explicitly says: "We need a PRD for this. Let me get it written up."

**Signals that indicate this is correct invocation time:**
- Explicit request to formalize ("need a PRD")
- Input data exists (customer feedback, not just ideas)
- Scope is bounded (specific features, not vague)
- Team awareness (shared with colleagues, not hidden)

**Expected behavior:** Skill invokes Create PRD

**Expected output quality:** PRD should cover:
- Problem (customer pain points)
- Solution (export formats)
- Requirements (3+ export options)
- V1 scope (what ships first)

---

## Negative Invocation Cases (Skill SHOULD NOT Invoke)

### Negative Case 1: Early Brainstorming (Too Premature)

**Scenario:** Engineer is in a brainstorming session with colleagues, exploring ideas for a new onboarding flow.

**Context:**
- Team is discussing: "What if we made onboarding shorter?"
- No design artifact yet (just talking)
- No written notes or requirements
- Engineer says: "Let me think out loud about this for a minute..."
- Tone: exploratory, not committing

**Why skill should NOT invoke:**
- Idea is still being explored (not ready to formalize)
- No artifact to base PRD on
- Premature PRD would become outdated quickly as thinking evolves
- Failure mode: Generated PRD contradicts direction after more brainstorming

**What should happen instead:**
- Continue brainstorming
- Wait for "I think we should build this" statement
- Wait for design artifact or written requirements
- Then invoke skill

**How to recognize this negative case:**
- Language: "What if...", "Maybe we could...", "Let me think about..."
- No artifacts or notes yet
- Team is still exploring alternatives

---

### Negative Case 2: PRD Already Exists (Already Formalized)

**Scenario:** Engineer is reviewing an existing PRD that was written last month. Discussion: "Does this PRD still reflect our thinking?"

**Context:**
- PRD was written and shipped 4 weeks ago
- Engineer is opening the document to review it
- Says: "Let me review this PRD to see if it's still accurate"
- Team is assessing whether requirements have changed

**Why skill should NOT invoke:**
- PRD already exists (don't generate a duplicate)
- This is a review/refinement scenario, not a generation scenario
- Generating a new PRD would overwrite the existing one
- Failure mode: New PRD contradicts the original; confusion about which is current

**What should happen instead:**
- Provide feedback on existing PRD
- Suggest edits or revisions
- Update the existing PRD if needed
- Only generate new PRD if the old one is being deprecated

**How to recognize this negative case:**
- Language: "reviewing", "checking", "updating"
- Reference to existing artifact ("this PRD", "the requirements we wrote")
- Intent is refinement, not generation

---

### Negative Case 3: Implementation Has Started (Too Late)

**Scenario:** Team has been building the feature for 2 weeks. Architecture has been approved. Engineering is now asking: "Should we formalize the requirements in a PRD?"

**Context:**
- Feature is in active development (sprint 3 of 4)
- Architecture reviewed and approved by tech lead
- Implementation is 40% complete
- Engineer asks: "Do we need to write a formal PRD at this point?"

**Why skill should NOT invoke:**
- Decision-making phase is over (architecture already set)
- PRD generated now would document decisions already made, not guide them
- Development timeline already committed
- Failure mode: PRD generated late feels like bureaucracy, not direction

**What should happen instead:**
- Use PRD retrospectively for documentation (optional)
- Focus on completing implementation
- Save PRD effort for the next feature

**How to recognize this negative case:**
- Language: "we're building", "should we formalize what we've done", "retrospective"
- Active development context (sprint in progress)
- Decisions about architecture/scope already locked in

---

## Quality Test Cases (Given Skill Did Invoke)

### Quality Case 1: Output Completeness

**Condition:** Skill invoked and generated a PRD for the incident dashboard feature (Positive Case 1)

**Expected quality criteria:**

✅ **Problem Statement:** Clearly articulates the problem (teams struggle to manage multi-team incidents)

✅ **Solution Description:** Describes how PRD solves the problem (centralized incident dashboard with team collaboration)

✅ **Key Requirements:** Lists 5+ specific features:
- Real-time incident creation
- Team assignment
- Status tracking
- Comment/notes log
- Integration with alerting system

✅ **Technical Context:** Mentions relevant tech (React frontend, PostgreSQL backend, Slack integration preferred)

✅ **V1 Scope Boundaries:** Clear about what's NOT in V1 (no AI, no cross-region, no incident history before launch)

✅ **Non-Functional Requirements:** Performance, scale, security constraints mentioned (incident creation < 2s, support 50+ concurrent users, Entra ID auth)

**Failure criteria:**
- ❌ Generic requirements (vague, not specific to incident management)
- ❌ Missing tech context (team can't make architecture decisions from PRD)
- ❌ No scope boundaries (team doesn't know what to deprioritize)
- ❌ Missing non-functional requirements

---

### Quality Case 2: Output Clarity for Downstream Handoff

**Condition:** Skill invoked and generated a PRD for analytics export feature (Positive Case 2)

**Expected quality criteria:**

✅ **Actionable by Architects:** PRD provides enough context that architects can create an architecture document without asking clarifying questions

✅ **Actionable by Designers:** PRD provides enough context that designers can sketch UX without asking clarifying questions

✅ **Acceptance Criteria Clear:** Each requirement is framed as a testable acceptance criterion (not just a feature name)

Example good: "Export to CSV with column headers and data validation errors"
Example bad: "Support multiple export formats"

✅ **Dependencies Explicit:** PRD mentions dependencies (e.g., "Requires analytics data pipeline from Feature X" or "Requires S3 bucket setup")

✅ **Open Decisions Documented:** PRD mentions things that still need to be decided (e.g., "PDF export: template design TBD", "Rate limiting: to be determined in architecture phase")

**Failure criteria:**
- ❌ Vague features (downstream teams ask clarifying questions)
- ❌ Missing dependencies (team discovers mid-sprint)
- ❌ No open decisions (team locks into decisions that should be flexible)

---

## Test Execution Results (Step 3: Invocation Testing)

### Positive Case 1: Product Vision Ready to Formalize

**Setup:** Engineer has design mockup + 6 requirements + explicit "I think this is ready to formalize"

**Expected result:** Skill SHOULD invoke

**Actual result:** ✅ Skill invoked

**Status:** ✅ PASS

**Hypothesis:** "High-fidelity input with all positive signals (artifact, commitment, team, scope) → skill invokes"
**Change:** N/A (passed on first test)
**Result:** ✅ Confirmed

---

### Positive Case 2: Product Idea Needs Formalization

**Setup:** Customer feedback documented + 3 export formats identified + "We need a PRD"

**Expected result:** Skill SHOULD invoke

**Actual result:** ✅ Skill invoked

**Status:** ✅ PASS

**Hypothesis:** "Lower-fidelity but sufficient input (feedback documented + scope) → skill invokes"
**Change:** N/A (passed on first test)
**Result:** ✅ Confirmed

---

### Negative Case 1: Early Brainstorming

**Setup:** Exploratory discussion, no artifact, exploratory language ("What if...")

**Expected result:** Skill SHOULD NOT invoke

**Actual result:** ✅ Skill did NOT invoke

**Status:** ✅ PASS

**Hypothesis:** "Brainstorming phase (no artifact, exploratory language) → skill correctly blocks"
**Change:** N/A (passed on first test)
**Result:** ✅ Confirmed — correctly prevented premature PRD generation

---

### Negative Case 2: PRD Already Exists

**Setup:** Reviewing existing PRD, "let me review our current PRD"

**Expected result:** Skill SHOULD NOT invoke

**Actual result:** ✅ Skill did NOT invoke

**Status:** ✅ PASS

**Hypothesis:** "Refinement context (review, existing PRD) → skill correctly blocks"
**Change:** N/A (passed on first test)
**Result:** ✅ Confirmed — correctly prevented duplicate generation

---

### Negative Case 3: Implementation Started

**Setup:** Sprint in progress, architecture approved, "Should we formalize what we're building?"

**Expected result:** Skill SHOULD NOT invoke

**Actual result:** ✅ Skill did NOT invoke

**Status:** ✅ PASS

**Hypothesis:** "Retrospective context (implementation in progress) → skill correctly blocks"
**Change:** N/A (passed on first test)
**Result:** ✅ Confirmed — correctly prevented late invocation

---

## Quality Test Execution Results (Step 4: Quality Validation)

### Quality Case 1: Output Completeness

**Condition:** Skill invoked (Positive Case 1), generated incident dashboard PRD

**Expected:** Problem, solution, 5+ requirements, tech, scope, NFRs all specific (not vague)

**Actual Results:**
- ✅ Problem statement: Clear, specific (incident coordination challenge)
- ✅ Solution: Explains HOW dashboard solves problem
- ✅ Requirements: 7 specific, measurable features
- ✅ Tech context: React, Node/Express, WebSockets, Slack Bolt named
- ✅ V1 scope: Explicit in/out (multi-team yes, cross-region no)
- ✅ NFRs: Performance < 2s, scale 50+ concurrent, 99.9% uptime

**Status:** ✅ PASS

---

### Quality Case 2: Output Clarity for Downstream

**Condition:** Skill invoked (Positive Case 2), generated analytics export PRD

**Expected:** Architects/designers/PMs can act without clarification questions

**Actual Results:**
- ✅ Architects: Data source (PostgreSQL), backend (Node), storage (S3), email specified
- ✅ Designers: One-click interface, date filtering, export options clear
- ✅ PMs: 7 testable requirements, dependencies explicit, open decisions documented
- ✅ No questions needed: All sections provide actionable guidance

**Status:** ✅ PASS

---

## Iteration Summary

**Total iterations:** 0 (no changes needed)

**Hypothesis:** "Skill invocation metadata is precise enough on first attempt"
**Result:** ✅ Confirmed — all 5 test cases passed on first execution
**Conclusion:** Invocation criteria are sufficiently specific to differentiate positive from negative cases

---

## Self-Check for Exercise 13 Step 5

✅ **Skill test file committed before skill file was built:** create-prd-skill-tests.md committed at Step 1

✅ **At least 2 positive, 2 negative, and 2 quality test cases:** 
- 2 positive cases
- 3 negative cases (exceeds requirement)
- 2 quality cases

✅ **All positive cases invoke the skill:** 
- Case 1: ✅ PASS (invoked)
- Case 2: ✅ PASS (invoked)

✅ **All negative cases do NOT invoke the skill:**
- Case 1 (premature): ✅ PASS (did not invoke)
- Case 2 (duplicate): ✅ PASS (did not invoke)
- Case 3 (too-late): ✅ PASS (did not invoke)

✅ **Quality test cases pass for output produced by invocation:**
- Case 1 (completeness): ✅ PASS
- Case 2 (downstream clarity): ✅ PASS

✅ **Iteration record committed (hypothesis, change, result format):**
- All 5 invocation cases documented with hypothesis/change/result
- All 2 quality cases documented with results
- 0 iterations needed (all passed first attempt)

✅ **Skill file is committed in the location your tool expects for skills:**
- Skill file: module-3/exercise-13/create-prd.md
- Includes invocation metadata, role, task, context, constraints
- Ready for deployment in Claude Code skill system
