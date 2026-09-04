# Skill Mechanism Notes — Claude Code

**Tool:** Claude Code (Claude Agent SDK)  
**Reference:** Claude Code documentation and system context  

---

## How Claude Code Discovers and Loads Skills

Claude Code loads skills from two sources:

1. **System-defined skills** — Provided by Anthropic SDK, built into Claude's tool set (examples: `/help`, `/clear`, `/fast`)
2. **User-defined skills** — Loaded from a skills directory or defined in project configuration, typically stored in `.claude/skills/` or similar directories
3. **Project-scoped skills** — Can be defined in individual project directories with scopes like `apps/web:deploy` (directory-scoped)

Skills are loaded as markdown files with frontmatter metadata (name, description, type, instructions).

---

## How the Model Decides When to Invoke a Skill

The model's invocation decision depends on:

1. **Explicit User Request** — User types `/skillname` or explicitly asks the model to use a skill
2. **Context-Based Inference** — When a user's request matches a skill's description, the model may recognize that the skill is applicable and suggest or use it autonomously
3. **Skill Visibility** — Skills marked as "proactive" in their metadata may be invoked without explicit user request
4. **Tool Availability** — The model only invokes skills that are available in the current context (loaded and accessible)
5. **User History & Patterns** — If a user has frequently invoked a skill in similar contexts, the model learns this pattern

---

## Signals That Influence Invocation

**Positive signals (encourage invocation):**
- Skill name matches user's request keywords
- Skill description directly addresses the user's stated problem
- Skill has been used successfully in similar contexts before
- Skill is marked as "proactive" (suitable for automatic triggering)
- User has explicitly asked for skill-driven automation

**Negative signals (discourage invocation):**
- Skill name/description doesn't match current context
- Skill requires explicit input that user hasn't provided
- User has explicitly disabled automatic skill invocation
- Skill has failed or produced wrong output in recent history
- Skill is marked as "command-only" (requires explicit invocation)

**Metadata signals:**
- `proactive: true` — Skill can be invoked autonomously based on context
- `proactive: false` or absent — Skill requires explicit invocation (default)
- `requires_user_input: true` — Skill needs explicit parameters
- `isolated: worktree` — Skill runs in isolated environment (safer for automation)

---

## Observing and Logging Skill Invocations

**In Claude Code:**
- Skill invocations appear in the transcript with clear markers (e.g., `[Skill: skillname]`)
- The `ListAgents` tool shows in-process subagents and skill invocations
- Skill execution results appear as tool call results in the conversation flow
- Failed skill invocations show errors that explain why invocation failed

**Best Practices for Logging:**
- Log skill name, parameters, timestamp, and outcome
- Track whether invocation was explicit (user-requested) or implicit (model-inferred)
- Note unexpected invocations (model invoked a skill when user didn't ask for it)
- Capture downstream effects (what did the skill output cause to happen?)

---

## Key Distinction: Skill Trigger vs. Output Quality

The model can decide to invoke a skill (trigger decision), but:
- Cannot reliably predict all downstream effects of that invocation
- May invoke at wrong time if context is ambiguous
- May fail to invoke when it should if context doesn't match expected keywords

**Example:**
- User: "This code is getting slow. Let's benchmark it."
- Model might invoke `/profile` skill, which is correct
- But if user only has a `/test` skill available, model might invoke that instead
- Or model might not invoke any skill and ask "which tool do you want to use?"

The **trigger decision is not the same as output quality decision**.

---

## Claude Code Skill Mechanism Summary

1. **Discovery:** Skills loaded from `.claude/skills/` or project config
2. **Invocation Decision:** Based on user request + context + metadata + history
3. **Triggering Signals:** Skill name, description, proactive flag, metadata
4. **Observation:** Transcript shows all invocations with outcomes
5. **Risk:** Model can invoke at wrong time or fail to invoke when needed
6. **Mitigation:** Explicit user request (command), metadata (proactive flag), test cases

**Conclusion:** Skills are useful for convenience but introduce invocation ambiguity. This ambiguity is tolerable only when the team has agreed in writing on exactly when the skill should and shouldn't run.
