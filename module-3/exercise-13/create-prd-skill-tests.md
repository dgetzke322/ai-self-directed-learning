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

## Test Execution Template (To Be Filled During Step 3)

For each case, record:

```markdown
### [Case Name]

**Setup:** [What context did I provide to the model/skill?]

**Expected result:** Skill should [invoke/not invoke]

**Actual result:** Skill [invoked/did not invoke]

**Status:** ✅ PASS / ❌ FAIL

**Notes:** [If failed, what would fix it?]
```

---

## Success Criteria for Exercise 13

✅ All positive cases (1-2) result in skill invocation
✅ All negative cases (1-3) result in skill NOT invoking
✅ Quality cases pass when skill does invoke (output meets criteria)
✅ Invocation description in skill file is specific enough to differentiate positive from negative cases
✅ All iterations documented (hypothesis → change → result format)
