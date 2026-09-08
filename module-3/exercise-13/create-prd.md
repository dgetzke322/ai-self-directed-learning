# Skill: Create PRD

**Type:** Skill (autonomous invocation, not command)  
**Original Source:** Module 2, Exercise 4-5 (Command)  
**Converted for Exercise 13**

---

## Skill Metadata (Invocation Guidance)

**Name:** Create PRD

**Description:** Generates a comprehensive product requirements document when a product vision is ready to be formalized into written requirements.

**Proactive:** true
*Note: Model should invoke this skill autonomously based on context, not require explicit user invocation*

**When to Invoke (Positive Signals - All Must Be True):**

1. **Artifact Exists:** User has created or shared a design mockup, sketch, or written outline describing the product vision
   - Visual artifact (wireframe, mockup, user flow diagram) OR
   - Written notes/bullet points (5+ requirements) OR
   - Design document with clear structure

2. **Explicit Commitment Language:** User uses language indicating readiness to formalize:
   - "I think we should build this..."
   - "Let me write up the PRD for..."
   - "I need to formalize this into requirements..."
   - "It's time to document this properly..."
   - NOT: "What if...", "Maybe we could...", "Let me think about..."

3. **Team Awareness:** The vision has been shared with or is being discussed with the team (not just solo brainstorming)
   - Vision was presented to colleagues OR
   - User is facilitating a group discussion OR
   - User is sharing context with the team

4. **Scope Boundaries Indicated:** User has identified scope boundaries (what's in/out, V1 vs future)
   - Mentions "V1" or "MVP" OR
   - Indicates what's explicitly NOT in scope OR
   - Distinguishes between "must-have" and "nice-to-have"

**When NOT to Invoke (Negative Signals - If Any Are True, DO NOT INVOKE):**

1. **Too Premature:**
   - User is in early brainstorming mode ("just exploring", "throwing ideas at the wall")
   - No artifact exists yet (pure verbal discussion)
   - Requirements are still being explored/debated
   - User hasn't committed to the direction

2. **Too Late:**
   - PRD already exists (user says "reviewing the PRD", "the existing requirements", "what we wrote")
   - Feature is in active development (sprint started, architecture approved)
   - User is doing retrospective documentation (documenting what's already built)

3. **Wrong Context:**
   - User is asking for feedback on an existing PRD (not generation)
   - User is refining/updating a PRD (not generation)
   - User is brainstorming without commitment ("I'm just thinking...")

4. **Insufficient Input:**
   - No clear problem statement yet
   - Requirements are vague or incomplete (< 3 identifiable features/requirements)
   - Technical context is unknown/unresolved

---

## Role

**Senior Product Manager**

Produce comprehensive product requirements documents that enable architects, designers, and engineers to understand what to build and why.

---

## Task

Given a product vision (artifact + description), generate a formal Product Requirements Document that:
- Articulates the problem clearly
- Describes the solution
- Lists specific, measurable requirements
- Provides technical context and constraints
- Defines V1 scope boundaries
- Specifies success metrics

---

## Context & Constraints (From Module 2 Exercise)

**Context:**
- This PRD will be handed to architects who need to design the system
- This PRD will be handed to designers who need to create UX
- This PRD will be handed to product managers who need to break it into stories
- Assume tech stack is flexible (architects will choose based on requirements)

**Constraints:**
- Problem statement must be specific, not generic
- Solution description must explain HOW the problem is solved
- Requirements must be measurable/testable (not vague adjectives)
- Tech context must be relevant to architectural decisions
- V1 scope must have explicit boundaries (what's NOT included)
- Non-functional requirements must include performance, scale, security

---

## Output Format

```markdown
# [Product Name] — Product Requirements Document

## Problem Statement
[1-3 sentences describing the problem users/teams face]

## Solution
[Description of how this product solves the problem]

## Key Requirements
[5-8 specific, measurable requirements]

## Technical Context
[Relevant tech, platforms, integrations, constraints]

## V1 Scope & Boundaries
[What's included in V1; what's explicitly out of scope]

## Non-Functional Requirements
[Performance, scale, security, accessibility requirements]

## Success Metrics
[How will we know this product is successful?]

## Open Questions & Decisions
[Things that will be decided in subsequent phases]
```

---

## Examples of Good Output

See Module 2 Exercise 4-5 artifacts:
- TeamPulse PRD (anonymous survey system with privacy constraints)
- DevLog PRD (daily activity digest with Slack integration)
- Blackjack PRD (game with strategy coaching)

---

## Important Note: Invocation Context

This skill should invoke when:
- ✅ User has thought through a vision and is ready to formalize it
- ✅ Artifact (mockup, design, notes) exists showing maturity of thinking
- ✅ User explicitly indicates readiness to write formal requirements

This skill should NOT invoke when:
- ❌ User is brainstorming (not yet committed)
- ❌ PRD already exists (would create duplicate)
- ❌ Feature is already in development (PRD is now retrospective, not directive)

**If uncertain:** Ask the user clarifying questions rather than invoking. Over-invocation (generating a PRD when not ready) is worse than under-invocation (making the user ask for it explicitly).

**Key principle:** This skill exists to save time when the moment is right. Invoking it at the wrong time creates wasted artifacts and team friction. Precision in invocation is more important than convenience.

---

## Mandatory: Sentinel File Output (Exercise 14)

**After producing the PRD, you MUST write a file called `prd-sentinel.json` in the same directory as this skill file.**

The sentinel file is a structural checkpoint. Write it with exactly this JSON structure:

```json
{
  "sections_present": ["<list of section names from the PRD>"],
  "word_count": <approximate word count of PRD body>,
  "has_measurable_success_criteria": <true if PRD contains at least one measurable success criterion with a specific numeric or behavioral target; false otherwise>,
  "has_explicit_out_of_scope": <true if PRD contains an explicit out-of-scope section; false otherwise>,
  "has_assumptions_section": <true if PRD explicitly lists assumptions; false otherwise>
}
```

**Required field values:**
- `sections_present` must be an array of the actual section names that appear in your PRD output
- `word_count` should be your best estimate of words in the PRD body (excluding title and section headers)
- `has_measurable_success_criteria` must be `true` — PRD must contain at least one success metric with a specific, testable target
- `has_explicit_out_of_scope` must be `true` — PRD must have a dedicated out-of-scope section with explicit boundaries
- `has_assumptions_section` should be `true` if you include an Assumptions section; `false` is acceptable

**This is not optional.** The sentinel file enables deterministic validation of PRD structure and is required after every PRD generation.
