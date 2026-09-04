# Skill Readiness Assessment

**Exercise 12: Commands vs. Skills — Analysis for Two Existing Commands**

---

# Command 1: Create PRD

## Invocation Boundary Analysis

### 1. What input or context triggers a human to run this command?

A human runs Create PRD when they have a product vision or concept that needs to be formalized into written requirements. The human is usually looking at notes, Slack conversations, design mockups, competitive analysis, or just thinking through a problem space. They're thinking: "We should build this. Now I need to write it down clearly so the team understands what 'this' actually means."

### 2. Could the model identify that trigger from context alone?

**Partially, but with significant ambiguity (~60% accuracy at best)**

Model could detect tone shifts ("I think we should..." → "Let's build this feature...") and product context (design mockups, feature discussion), inferring "time to formalize requirements." However, it can't distinguish "still exploring ideas" from "idea is ready to commit to requirements." Different team members have different thresholds, and model might see "brainstorming notifications" and invoke PRD when the human meant "just thinking out loud."

### 3. What is the harm if the model invokes at the wrong time?

**Premature invocation:** PRD generated before idea is fully baked; team friction ("You finalized requirements before we explored alternatives"); PRD becomes outdated; wasted time on formal requirements for ideas that won't ship; architecture/design start based on incomplete/incorrect PRD.

**Late invocation:** PRD generated after team already committed to direction; reads as audit not guidance; team feels controlled; less opportunity to catch issues during requirements phase.

### 4. What is the harm if the model fails to invoke when it should?

**Failure mode: "Human does the work manually"** — Human writes PRD manually (slower, less rigorous, less complete) or team proceeds without formal requirements. Development starts with unclear requirements; more rework later. Not catastrophic, but efficiency and quality suffer.

### 5. What ambiguous cases exist?

- **"Let me think out loud about notifications..."** — Is this brainstorming (don't invoke) or feature planning (invoke)? Model wrong ~30% of time.
- **Designer shows mockups:** "Here's what I'm thinking for the dashboard" — Is this wireframe (thinking) or finalized design (ready for PRD)? Model wrong ~40% of time.
- **"We need to ship this by next month"** — Does PRD need to run now or is it already done? Model wrong ~30% of time.

**Skill-Readiness Score: 60/100** — Not ready for shared skill conversion.

---

# Command 2: Plan Story

## Invocation Boundary Analysis

### 1. What input or context triggers a human to run this command?

A human runs Plan Story when they have a written story with acceptance criteria and need to translate it into a technical implementation plan. They're looking at a story card, the story's acceptance criteria, related architecture decisions, and their mental model of the tech stack. They're thinking: "I'm about to code this. Let me make sure I understand what I'm building and how I'll build it."

### 2. Could the model identify that trigger from context alone?

**Partially, but with MUCH higher ambiguity than PRD (~40% accuracy at best)**

Model could detect "I'm starting work on story ES-5" and infer planning time, or recognize assignment notifications. However, it can't reliably distinguish "reading to understand" from "ready to code," can't know which story to plan if multiple available (picking wrong story is worse than not planning), and can't judge if story is complex enough to need a plan. Preferences also vary — some engineers always plan, others rarely plan.

### 3. What is the harm if the model invokes at the wrong time?

**Wrong story selection:** Model plans story X; engineer working on story Y; engineer confused ("I didn't ask for that"); trust in automation decreases.

**Wrong timing (too early):** Story scope still being refined; plan becomes outdated as requirements evolve; engineer sees plan as premature constraint.

**Wrong timing (too late):** Plan generated after coding started; has less value; misses opportunity to guide implementation.

**Wrong granularity:** Planning a 1-hour story takes longer than coding it; engineer loses confidence in automation.

### 4. What is the harm if the model fails to invoke when it should?

**Failure mode:** For complex stories, engineer codes without planning, leading to architectural mistakes, missed edge cases, longer implementation time. For simple stories, no harm. Unlike PRD, this can be catastrophic for complex work.

### 5. What ambiguous cases exist?

- **Opening story card to read it:** Is this "just understanding" or "about to code"? Model wrong ~50% of time.
- **"I'm picking up story ES-5":** Is this simple 1-hour or complex multi-day? Model wrong ~40% of time on complexity judgment.
- **Multiple stories available:** Which one should get a plan? Model guesses; ~50% error rate.
- **Tight deadline:** Should planning be skipped to maximize code time? Model doesn't detect pressure context.
- **Team preference variation:** One engineer always plans, another rarely plans. Skill can't do both.

**Skill-Readiness Score: 40/100** — Not ready for shared skill conversion.

---

# Team Consensus Simulation

**Selected Command: Plan Story**

**Scenario:** Two engineers who independently love the Plan Story command are asked to agree on a shared version — one skill that both will use, with one shared definition of when it should invoke.

## Engineer A: "Always Plan"
- Workflow: Every story gets a detailed plan before coding
- Belief: Planning prevents bugs and rework
- Would invoke Plan Story: For every story assigned

## Engineer B: "Code First"
- Workflow: Only plan complex stories; code simple ones directly  
- Belief: Planning is overhead; coding and iterating is faster
- Would invoke Plan Story: Only for complex stories (~20% of all stories)

---

## Disagreement Scenario 1: Small Story

**Story:** Add a settings button to export user data (straightforward feature, 1-2 hours)

**Engineer A says:** "I want a plan. I need to think through state management, error handling, testing strategy."

**Engineer B says:** "Don't plan this. It's trivial. Planning will take longer than coding it."

**Consequence of disagreement:**
- If skill auto-invokes: Engineer B gets plans for trivial stories, perceives automation as overhead, stops trusting it
- If skill never auto-invokes: Engineer A doesn't get plans, loses automation benefit

**What they'd need to agree on in writing:**
- Explicit complexity criteria: "Invoke Plan Story if ≥ 3 ACs OR ≥ 3 components touched OR new API design required"
- Measurable thresholds both engineers commit to following
- Shared definition of "complex" vs "simple"

---

## Disagreement Scenario 2: Auto-Invocation vs. Explicit Control

**Context:** Sprint starts with three available stories. Engineer hasn't explicitly assigned themselves yet.

**Engineer A's expectation:** "When I start looking at a story, the skill should know I'm about to work on it and create a plan automatically."

**Engineer B's expectation:** "I don't want the skill watching my activity and guessing. That feels like surveillance. I'll explicitly tell you which story I want a plan for."

**Consequence of disagreement:**
- If skill auto-invokes based on activity: Engineer B feels monitored, doesn't trust automation
- If skill requires explicit invocation: Engineer A loses automation convenience

**What they'd need to agree on in writing:**
- Define explicit triggers: "Skill invokes when engineer clicks 'assign to me' in ticket system" (explicit action, not passive observation)
- Or: "Skill invokes when engineer types `/plan-story ES-5`" (explicit command)
- Agreement: "We will not invoke based on passive activity (scrolling, reading, hovering)"

---

## Disagreement Scenario 3: Time Pressure

**Context:** Production bug discovered. 2 hours until end-of-day. Four bug fixes available, estimated 4+ hours to code.

**Engineer A:** "We should plan each fix. Planning takes 30 min but prevents new bugs. Better to ship one solid fix tomorrow."

**Engineer B:** "No time for plans. We code for 2 hours and ship what we can. Speed matters more."

**Consequence of disagreement:**
- If skill always invokes plans: Takes 2 hours planning, 0 hours coding, nothing ships (bad outcome)
- If skill never invokes plans: Engineer A's workflow (always plan) isn't followed

**What they'd need to agree on in writing:**
- Explicit deadline rule: "If sprint has < 2 hours remaining, skip detailed planning or invoke lightweight plan only (10 min max)"
- Or: "Engineer can invoke `plan-story fast` mode to skip detailed planning"
- Define what triggers deadline mode so both understand when planning is skipped

---

## Key Finding

These two engineers have compatible workflows as long as they work independently with the Plan Story command. **But they cannot agree on a single shared skill definition without clarifying:**

1. When is planning required vs. optional? (complexity thresholds)
2. How is complexity judged? (measurable criteria)
3. What triggers auto-invocation? (explicit, deterministic conditions)
4. What happens under time pressure? (deadline rules)

**Conclusion:** Plan Story cannot become a shared skill until team consensus is written, tested, and both engineers commit to it.

---

# Summary & Self-Check

✅ **skill-mechanism-notes.md:** Documented how Claude Code discovers skills, invocation decision factors, signals influencing automation, and key risks

✅ **All five invocation boundary questions answered for each command:**
- Create PRD: Trigger, context identification, harms, failure modes, ambiguous cases
- Plan Story: Trigger, context identification, harms, failure modes, ambiguous cases

✅ **Team consensus simulation completed:** Three disagreement scenarios for Plan Story with specific consequences and required written agreements

✅ **Identified stronger candidate for skill conversion:**
- **Create PRD:** Score 60/100 (more viable for automation)
- **Plan Story:** Score 40/100 (higher invocation ambiguity, not recommended for skill yet)

**Stronger candidate for future skill conversion: Create PRD** (though both need team consensus work before automation is safe)

---

# Recommendation

**Keep both commands as explicit invocation (commands) for at least 2-3 more sprints.**

Collect data on actual usage patterns, then:
1. Write explicit rules based on observed behavior
2. Define measurable thresholds and triggers
3. Test rules with full team consensus
4. Only convert to shared skill after written agreement and testing

**Core principle:** A command can serve multiple workflows. A skill serves one. Until the team agrees on one shared definition, the command is the safer choice.
