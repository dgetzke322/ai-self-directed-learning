# Command 1: Create PRD — Invocation Boundary Analysis

## 1. What input or context triggers a human to run this command?

A human runs Create PRD when they have a product vision or concept that needs to be formalized into written requirements. The human is usually looking at:

- Notes or sketches (rough product ideas)
- Slack conversations discussing a feature
- Competitive analysis or market research
- Design mockups or user flows
- Their own thinking/whiteboard work on a problem space

**Mental state:** "We should build this. Now I need to write it down clearly so the team understands what 'this' actually means."

---

## 2. Could the model identify that trigger from context alone, without the human explicitly thinking "I should run this command"? Why or why not?

**Short answer: Partially, but with significant ambiguity (~60% accuracy at best)**

### Why it could work:
- Model could detect tone/language shift: "I think we should..." → "Let's build this feature..."
- Model could see product context (design mockups, feature discussion) and infer "time to formalize requirements"
- Model could recognize keywords like "we need," "ship," "launch," "implement"

### Why it wouldn't be reliable:
- **Maturity judgment:** Model can't distinguish "still exploring ideas" from "idea is ready to commit to requirements"
- **Team variation:** Different team members have different thresholds for "ready to PRD"
- **False positives:** Model might see "I'm brainstorming notifications" and invoke PRD, but human meant "just thinking out loud, not committing yet"
- **Incomplete context:** Model can't assess if the idea has enough detail for a PRD or needs more thinking first
- **Ambiguous language:** Human says "I have a rough idea" expecting brainstorming, not formal PRD generation

---

## 3. What is the harm if the model invokes this command at the wrong time?

### Harm from premature invocation (idea still in exploration phase):
- PRD generated before idea is fully baked
- Team sees formal requirements that feel premature; creates friction ("You formalized requirements before we explored alternatives")
- PRD becomes outdated quickly as thinking evolves
- Wasted time on formal requirements for ideas that won't ship or will change significantly
- **Downstream cascade:** Architecture and UX design start based on incomplete/incorrect PRD; rework required later

### Harm from late invocation (after team has already committed direction):
- PRD generated after architectural and design decisions already made
- PRD reads as an audit/documentation of a decision already made, not guidance for decisions
- Team feels controlled rather than enabled ("Why are we formalizing requirements now, after we decided?")
- Less opportunity to catch issues during requirements phase
- **Opportunity cost:** Requirements rigor happens at wrong time

---

## 4. What is the harm if the model fails to invoke it when it should?

### Failure mode: "Human does the work manually" (not catastrophic, but inefficient)

If model doesn't invoke:
- Human writes PRD manually (slower, often less rigorous, less complete)
- Or team proceeds without formal written requirements (common in fast-moving teams)
- Development starts with unclear/vague requirements
- More rework required during architecture and implementation
- Quality and communication suffer, but work still gets done

**This is not a "blocked flow" scenario** — the work continues, just less efficiently.

---

## 5. What ambiguous cases exist where you would not be sure whether to invoke this command? What would the model probably do in those cases?

### Ambiguous Case 1: Brainstorming vs. Committing
**Scenario:** Human says "Let me think out loud about how we'd handle user notifications..."

**Ambiguity:** Is this "brainstorming mode" (don't invoke PRD yet) or "starting to think about a feature we'll actually build" (invoke PRD)?

**What model would probably do:** Listen for keywords like "we should," "let's build," "implement." Might get it wrong in ~30% of cases.

**Example of model error:** Human is just brainstorming; model detects "implement" keyword and invokes PRD prematurely.

---

### Ambiguous Case 2: Wireframe vs. Finalized Design
**Scenario:** Human shows design mockups and says "Here's what I'm thinking for the dashboard"

**Ambiguity:** Is model seeing a low-fidelity wireframe (early thinking stage) or a finalized design ready for PRD?

**What model would probably do:** Assume "finalized design, time for PRD" and invoke. Wrong ~40% of the time.

**Example of model error:** Designer is exploring multiple approaches; model sees mockup and invokes PRD for one direction before alternatives are considered.

---

### Ambiguous Case 3: Deadline vs. Readiness
**Scenario:** Human says "We need to ship this notification feature by next month"

**Ambiguity:** Does this mean PRD should run now (feature is scheduled for development), or has PRD already been written and scheduled for next sprint?

**What model would probably do:** Assume "time to PRD" and invoke, missing that PRD was already completed weeks ago.

**Example of model error:** PRD already exists; model generates a duplicate or an updated version that contradicts the existing PRD.

---

### Ambiguous Case 4: Feedback vs. Generation
**Scenario:** Human asks "Does this PRD look complete? Any missing requirements?"

**Ambiguity:** Should model invoke Create PRD again (wrong — PRD already exists), or just provide feedback on the existing PRD?

**What model would probably do:** Provide feedback without reinvoking PRD; this case is lower risk (~10% error rate).

---

## Summary: Create PRD Invocation Readiness

**Model accuracy at detecting "time to PRD":** ~60%
- Correct invocation: 60% of the time
- Premature invocation: ~20% of the time
- Missed invocation: ~20% of the time

**Conclusion:** Create PRD is not yet ready to be an autonomous skill. Team would need to:
1. Define explicit triggers ("PRD should run when: idea has been sketched in design mockup AND team has identified it as a planned feature")
2. Add test cases for positive/negative/ambiguous scenarios
3. Define fallback behavior ("If I'm unsure, ask the human rather than guessing")
