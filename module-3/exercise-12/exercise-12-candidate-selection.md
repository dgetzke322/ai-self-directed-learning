# Exercise 12 Self-Check: Stronger Candidate for Skill Conversion

**Requirement:** Identify which command is the stronger candidate for skill conversion (will be used in Exercise 13/later exercises)

---

## Candidate Selection: CREATE PRD

**Selected Command:** Create PRD (from Module 2, Exercise 4-5)

**Score:** 60/100 (vs. Plan Story's 40/100)

---

## Why Create PRD is the Stronger Candidate

### 1. Clearer Invocation Trigger
**Create PRD:** "Product vision needs to be formalized into written requirements"
- Single, clear decision point
- Less ambiguity about readiness

**Plan Story:** "Story needs a technical implementation plan"
- Multiple ambiguous decision points (which story? complexity? when exactly?)
- Higher chance of invoking on wrong story or wrong timing

**Winner: Create PRD** — More deterministic trigger

### 2. Lower Invocation Ambiguity
**Create PRD:** ~60% model accuracy at identifying right time
- Model can detect tone shifts ("thinking" → "committing")
- Can recognize product context (mockups, feature discussions)
- False positives (~20%), false negatives (~20%)

**Plan Story:** ~40% model accuracy
- Can't reliably judge story complexity
- Can't know which story to plan if multiple available
- Can't distinguish "reading" from "ready to code"

**Winner: Create PRD** — More reliable invocation detection

### 3. Less Harmful When Wrong
**Create PRD invocation error:**
- Premature: PRD is outdated but doesn't cascade immediately (team reviews before acting)
- Late: PRD is generated after direction set; still useful as documentation
- Recovery: Team can ignore/redo PRD without major impact

**Plan Story invocation error:**
- Wrong story: Implementation started on wrong story; cascades immediately
- Wrong timing: Plan doesn't guide coding (generated after started)
- Recovery: Requires rework of implementation

**Winner: Create PRD** — Lower failure impact

### 4. Simpler Consensus Requirements
**Create PRD team consensus needed:**
- When is a vision "ready to formalize"? (1-2 subjective criteria)
- What triggers should not invoke? (brainstorming, early sketches)
- Relatively simpler to document and test

**Plan Story team consensus needed:**
- Complexity thresholds (measurable but complex)
- Story selection rules (which story if multiple?)
- Team preference variation (always plan vs. rarely plan)
- Time pressure rules (deadline < X hours)
- More complex to document and test

**Winner: Create PRD** — Easier team consensus path

### 5. Precedent in Module 2
**Create PRD was tested extensively:**
- Used across three product domains (TeamPulse, DevLog, Blackjack)
- Proven to generalize (not domain-specific)
- Has established Context/Constraints
- Lower risk to convert

**Plan Story:**
- Also tested but with higher variability across contexts
- More dependent on team/engineer preferences

**Winner: Create PRD** — More proven, lower risk

---

## Comparison Table

| Factor | Create PRD | Plan Story | Winner |
|--------|-----------|-----------|--------|
| Trigger clarity | Clear | Ambiguous | **PRD** |
| Model accuracy | 60% | 40% | **PRD** |
| Failure impact | Medium | High | **PRD** |
| Consensus complexity | Simple | Complex | **PRD** |
| Team variation | Low | High | **PRD** |
| Generalization proof | Yes (3 domains) | Yes (1 domain) | **PRD** |

---

## Conclusion

**CREATE PRD is the stronger candidate for skill conversion.**

**Rationale:** While both commands need team consensus before automation, Create PRD has:
- Clearer, more deterministic invocation triggers
- Lower ambient ambiguity in when to invoke
- Lower cascading harm if invoked at wrong time
- Simpler team consensus requirements
- More proven track record across domains

**If we were to convert one command to a skill (as Exercise 13 requires), Create PRD would be the safer choice.**

---

## Important Note on Recommendation

**Even though Create PRD is the stronger candidate, the recommendation remains:**

Keep it as a command (not yet a skill) because:
1. Team consensus on invocation rules still needs to be written and tested
2. No explicit agreement yet on what makes a vision "ready to PRD"
3. Different team members likely have different thresholds
4. Collect 2-3 sprints of data before automating

**But if team consensus CAN be reached and documented, Create PRD would be the command to convert.**

---

## Exercise 13 Preparation

**Create PRD will be used in Exercise 13** to demonstrate:
- How to convert a command to a skill file
- How to write invocation-aware test cases
- How to define a skill with explicit triggers
- How to handle edge cases and failures
