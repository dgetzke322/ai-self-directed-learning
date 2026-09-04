# Step 3: Team Consensus Simulation — Plan Story

**Selected Command:** Plan Story

**Scenario:** Two engineers who independently love the Plan Story command are asked to agree on a shared version — one skill that both will use, with one shared definition of when it should invoke.

---

## Engineer A: "Always Plan"
- Workflow: Every story gets a detailed plan before coding
- Belief: Planning prevents bugs and rework
- Would invoke Plan Story: For every story assigned to them

## Engineer B: "Code First"  
- Workflow: Only plan complex stories; code simple ones directly
- Belief: Planning is overhead; coding and iterating is faster
- Would invoke Plan Story: Only for complex stories, maybe 20% of all stories

---

## Disagreement Scenario 1: Small Story

**Story:** Add a settings button to export user data (straightforward feature, 1-2 hours)

**Engineer A says:** "I want a plan. I need to think through state management, error handling, testing strategy."

**Engineer B says:** "Don't plan this. It's trivial. Planning will take longer than coding it."

**Consequence of this disagreement:**
- If skill auto-invokes (Engineer A's preference): Engineer B gets plans for trivial stories, perceives automation as overhead, stops trusting it
- If skill never auto-invokes (Engineer B's preference): Engineer A doesn't get plans for stories they want planned, loses the automation benefit

**What they'd need to agree on in writing:**
- Explicit complexity criteria: "Invoke Plan Story if story has ≥ 3 acceptance criteria OR touches ≥ 3 components OR requires new API design"
- Both sign off: "We will follow this definition for all stories"
- Define what qualifies as "complex": specific, measurable thresholds, not subjective judgment

---

## Disagreement Scenario 2: Multiple Available Stories in Sprint

**Context:** Sprint starts with three available stories. Engineer hasn't explicitly assigned themselves to any yet.

**Engineer A's expectation:** "When I start looking at a story, the skill should know I'm about to work on it and create a plan automatically."

**Engineer B's expectation:** "I don't want the skill watching my activity and guessing what I'll work on. That feels like surveillance. I'll tell you which story I want a plan for, explicitly."

**Consequence of this disagreement:**
- If skill auto-invokes based on activity detection (Engineer A's preference): Engineer B feels their autonomy is being monitored; doesn't trust automation
- If skill requires explicit invocation (Engineer B's preference): Engineer A has to manually request plans; loses the automation convenience

**What they'd need to agree on in writing:**
- When is auto-invocation OK? Define explicit triggers: "Skill invokes when engineer clicks 'assign to me' in ticket system" (explicit action, not passive observation)
- Or: "Skill only invokes when engineer types `/plan-story ES-5`" (explicit command)
- Both agree: "We will not invoke based on passive activity (scrolling, reading, hovering)"

---

## Disagreement Scenario 3: Under Time Pressure

**Context:** Production bug discovered. 2 hours until end-of-day. Four bug fixes available, estimated 4+ hours to code.

**Engineer A:** "We should plan each fix. Planning takes 30 min but prevents us from introducing new bugs. Better to ship one solid fix tomorrow."

**Engineer B:** "No time for plans. We code for 2 hours and ship what we can. Speed matters more than planning."

**Consequence of this disagreement:**
- If skill always invokes plans (Engineer A's preference): Takes 2 hours planning, 0 hours coding, nothing ships (bad outcome)
- If skill never invokes plans (Engineer B's preference): Engineer A's preferred workflow (always plan) isn't followed

**What they'd need to agree on in writing:**
- Explicit deadline rule: "If sprint has < 2 hours remaining, do lightweight planning only (10 min max) or skip"
- Or: "Engineer can invoke `plan-story fast` mode to skip detailed planning"
- Define what triggers deadline mode so both engineers understand when planning gets skipped

---

## Synthesis: What Needs to Be Written Before Skill Conversion

For Plan Story to become a shared skill, Engineer A and Engineer B must agree on and document:

1. **Complexity thresholds** (measurable criteria for when to plan)
2. **Invocation triggers** (explicit, deterministic conditions that trigger auto-invocation)
3. **Escape hatches** (when and how engineers can opt out)
4. **Edge case handling** (deadline mode, multiple available stories, etc.)

**If they cannot write these agreements, Plan Story is not ready to be a shared skill.**

---

## Conclusion

These two engineers have compatible workflows as long as they work independently with the Plan Story command. But they cannot agree on a single shared skill definition without clarifying:

- When is planning required vs. optional?
- How is complexity judged?
- What triggers auto-invocation?
- What happens under time pressure?

**The exercise reveals the core principle:** A command can serve multiple workflows. A skill can only serve one. Until the team agrees on one shared definition, the command should remain a command.
