# Command 2: Plan Story — Invocation Boundary Analysis

## 1. What input or context triggers a human to run this command?

A human runs Plan Story when they have a written story (with acceptance criteria) and need to translate those requirements into a technical implementation plan. The human is usually looking at:

- A story card (from Jira, GitHub Projects, Linear, or similar ticketing system)
- The story's acceptance criteria
- Related architecture decisions or prior work on similar stories
- Their own mental model of the tech stack and project state

**Mental state:** "I'm about to code this. Let me make sure I understand what I'm building and how I'll build it." Or: "I'm in a planning/pairing session and need to think through the technical approach together."

---

## 2. Could the model identify that trigger from context alone, without the human explicitly thinking "I should run this command"? Why or why not?

**Short answer: Partially, but with MUCH higher ambiguity than Create PRD (~40% accuracy at best)**

### Why it might work:
- Model could detect "I'm starting work on story ES-5" and infer "time to plan"
- Model could see assignment notifications (engineer assigned to a ticket) and infer planning time
- Model could recognize keywords like "starting," "picking up," "working on," "sprint"

### Why it wouldn't be reliable:
- **Story selection ambiguity:** If multiple stories are available, model doesn't know which one to plan. Picking the wrong story is worse than not planning at all
- **Preference variation:** Engineers have different philosophies — some always plan, others only plan for complex stories, others code first and plan later. No consensus model behavior
- **Timing ambiguity:** "I'm reading this story to understand requirements" (reading phase) is hard to distinguish from "I'm ready to code it" (planning phase)
- **Granularity problem:** A 1-hour story might not need a plan (faster to code); a 3-day story definitely needs planning. Model can't reliably judge complexity
- **Unclear boundaries:** "Starting work" is vague — does it mean "I just opened the ticket" or "I'm about to start coding" or "I'm in a planning meeting"?

---

## 3. What is the harm if the model invokes this command at the wrong time?

### Harm from wrong story selection:
- Model plans story X; engineer is actually about to work on story Y
- Engineer sees a detailed plan for the wrong story and is confused: "I didn't ask for a plan for X"
- Trust in automation decreases significantly ("Why did it plan the wrong thing?")
- Downstream: Planned output is ignored or accidentally actioned on the wrong story

### Harm from wrong timing (too early — before engineer understands story):
- Story scope still being refined; acceptance criteria might change
- Plan becomes outdated as story requirements evolve
- Engineer sees plan as a premature constraint ("I wasn't ready to commit to that approach yet")
- Plan has less value because it's based on incomplete understanding

### Harm from wrong timing (too late — after engineer started coding):
- Plan is generated for work already in progress
- Plan reads as documenting existing code, not guiding new code
- Plan has less value (should have come before coding started)
- Misses opportunity to catch design issues before implementation

### Harm from wrong granularity (planning a trivial story):
- Engineering time wasted on planning a 1-hour story ("the plan took longer than coding would")
- Engineer loses confidence in automation ("why did you plan something that simple?")
- Automation is perceived as overhead, not help

---

## 4. What is the harm if the model fails to invoke it when it should?

### Failure mode: "Human does the work manually" or "skip planning entirely" (depends on complexity)

If model doesn't invoke:
- **For simple stories (1-3 hours):** Engineer codes directly; no harm (coding is faster than planning for simple work)
- **For complex stories (3+ days):** Engineer codes without a plan, leading to:
  - Architectural mistakes that require rework
  - Missed edge cases and error handling
  - Longer overall implementation time
  - Quality issues that surface later in review or production

**Unlike Create PRD:** This is sometimes a catastrophic failure mode. Complex stories without planning can significantly delay shipping or introduce bugs.

---

## 5. What ambiguous cases exist where you would not be sure whether to invoke this command? What would the model probably do in those cases?

### Ambiguous Case 1: Reading vs. Ready to Code
**Scenario:** Engineer opens a story card to read the acceptance criteria

**Ambiguity:** Is this "I'm just understanding what the story requires" (reading phase, don't plan yet) or "I'm reading then I'll plan" (planning phase, invoke now)?

**What model would probably do:** Wait for more context (safer). But might miss the right moment to invoke (~50% error rate).

**Example of model error:** Engineer reads story, closes ticket, goes to code editor to start. Model never detected planning time, so no plan generated.

---

### Ambiguous Case 2: Story Complexity Judgment
**Scenario:** Human says "I'm picking up story ES-5"

**Ambiguity:** Is ES-5 a simple 1-hour story (don't plan — just code it) or a complex multi-day story (plan it)?

**What model would probably do:** Guess based on story title, description, or AC count. Often wrong (~40% error rate on complexity).

**Example of model error:** Model sees "Fix typo in error message" (simple) and invokes Plan Story; wastes time on trivial story. Or model sees "Implement payment processing" (complex) and doesn't invoke; engineer codes without planning.

---

### Ambiguous Case 3: Team Preference Variation
**Scenario:** Sprint with two engineers: one who always plans, one who rarely plans

**Ambiguity:** Which engineer's preference should the automation follow? The skill can't do both (can't both auto-invoke and never auto-invoke for the same context).

**What model would probably do:** Pick one arbitrarily or pick based on who made the most recent request. Violates the other engineer's workflow.

**Example of model error:** Skill configured for "always plan." Engineer B (who never plans) gets constant plan outputs; gets frustrated; stops trusting automation. Or skill configured for "never plan auto-invoke." Engineer A (who always plans) doesn't get plans unless explicit; loses automation value.

---

### Ambiguous Case 4: Multiple Stories Available
**Scenario:** Sprint planning done. Engineer has freedom to pick from three available stories: bug fix, feature, tech debt.

**Ambiguity:** Model doesn't know which story engineer will choose. Should it plan all three? Wait for assignment? Guess the most important one?

**What model would probably do:** Wait for explicit assignment. But might miss opportunity to plan ahead (~50% miss rate).

**Example of model error:** Engineer decides to work on story X. Model doesn't automatically plan it. Engineer has to manually request the plan, defeating automation.

---

### Ambiguous Case 5: Planning vs. Coding Trade-Off Under Time Pressure
**Scenario:** Late in sprint. Deadline in 2 hours. Three stories remaining, estimated 3 hours to code.

**Ambiguity:** Should model invoke Plan Story (takes 30 min per story, total 1.5 hours, leaves 30 min for coding) or skip it (no time for planning, focus on shipping code)?

**What model would probably do:** Not detect deadline context. Plan normally, causing engineer to miss deadline.

**Example of model error:** Model invokes Plan Story on all three. Plans take 1.5 hours. Only 30 minutes left for coding. Engineer ships nothing. Missed deadline.

---

## Summary: Plan Story Invocation Readiness

**Model accuracy at detecting "time to plan":** ~40%
- Correct invocation: 40% of the time
- Wrong story selected: ~20% of the time
- Wrong timing (too early/late): ~20% of the time
- Missed invocation (should have planned but didn't): ~20% of the time

**Conclusion:** Plan Story is NOT ready to be an autonomous skill. The invocation boundary is too ambiguous. Team would need to:

1. **Define explicit triggers:** "Invoke Plan Story when: (a) engineer explicitly assigns themselves to story in ticket system AND (b) story has complexity_level ≥ 3"
2. **Define complexity thresholds:** "Complexity 1-2: coding only. Complexity 3-5: invoke plan. Complexity 5+: escalate to tech lead"
3. **Add escape hatch:** "If engineer dismisses a plan and explains why, log it and refine rules"
4. **Test extensively:** Run 2-3 sprints with logging before converting to shared skill
5. **Handle edge cases:** Explicitly code for time pressure, multiple available stories, engineer preference variation

**Current recommendation:** Keep as a command (explicit invocation only) for at least two more sprints while collecting data on actual usage patterns.
