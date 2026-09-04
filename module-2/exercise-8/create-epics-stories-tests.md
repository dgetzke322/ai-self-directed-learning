# Create Epics and Stories Test Cases — Exercise 8

Domain: TeamPulse Epic and Story Breakdown

Story decomposition is the gateway to implementation. Poor stories lead to:
- Stories that take multiple sprints (hard to track, hard to demo)
- Untestable acceptance criteria (developers guess at requirements)
- Missed dependencies (stories fail because prerequisites are incomplete)
- Duplicate stories (same work, different angles)
- Incomplete coverage (feature shipped without all requirements)

These test cases verify that the command produces developer-ready stories with clear scope, testable acceptance criteria, explicit dependencies, and complete feature coverage.

---

## Test Case 1: Story Size (Right-Sized Scope)

**Problem:** A story that is "too large" is vague without sprint velocity context. Instead, test for signals of scope overflow:

**Expected Output Criteria:**

1. ✅ **Distinct Features as Separate Stories** — If a story says "Manager can create surveys AND teams AND configure notifications", it's one story doing three things. Each should be its own story.
   - Signal: Story description contains "and" multiple times with unrelated features

2. ✅ **No "Admin Configuration Epic as a Story"** — If the entire manager-side configuration is one story, it's too large. Break into "Create Team", "Add Team Members", "Create Survey Config", "Schedule Survey", etc.
   - Signal: Story scope covers multiple manager workflows

3. ✅ **Clear Definition of Done** — Each story should be demonstrable in isolation. Can a developer complete this story and show something meaningful to a stakeholder without waiting for dependent stories?
   - Signal: Story requires N other stories to be "releasable"

4. ✅ **No Vague Scope ("etc. and other features")** — If the story ends with "and implement other features", it's too large or poorly defined.

**Failure Criteria:** Stories that bundle unrelated features, stories that span multiple manager workflows, stories whose acceptance criteria can't be met in isolation, stories with vague scope boundaries

---

## Test Case 2: Testable Acceptance Criteria

**Problem:** "The system should be performant" is not testable. "The survey form submits in under 2 seconds on 4G" is testable.

**Expected Output Criteria:**

For each story, acceptance criteria must be:

1. ✅ **Measurable** — Use numbers, not adjectives. Not "fast" but "<1.5s p95 on 4G". Not "user-friendly" but "form completable in under 3 minutes with no navigation errors".

2. ✅ **Verifiable** — Developer can write a test to check it. "Survey closed after cut-off time" (verifiable via timestamp check) vs "Survey is properly closed" (vague).

3. ✅ **Specific to Implementation** — Criteria should reference actual UI elements, endpoints, or data states, not abstract goals.
   - Good: "POST /api/responses accepts JSON with survey_instance_id, question_id, answer_value"
   - Bad: "Survey responses are persisted"

4. ✅ **No Implicit Assumptions** — Criteria should not assume developer knowledge of what "normal" behavior is.
   - Good: "If survey is closed, form shows 'Survey closed on Sept 1 at 5pm' and submit button is disabled"
   - Bad: "Handle closed surveys appropriately"

5. ✅ **Error Cases Explicit** — Acceptance criteria should name specific error states, not assume happy path only.
   - Good: "Invalid token returns 401 Unauthorized with message 'Link expired'"
   - Bad: "Handle survey token validation"

**Failure Criteria:** Criteria using adjectives (fast, clean, intuitive), criteria without measurable bounds, criteria that omit error cases, criteria that assume developer knows the domain

---

## Test Case 3: Explicit Dependencies

**Problem:** Story A requires Story B, but this is never documented. Team starts Story A, discovers mid-sprint that Story B blocks it.

**Expected Output Criteria:**

1. ✅ **Dependency Graph** — Each story lists explicit "Depends On: [Story ID]" or "Blocked By: [Story ID]"

2. ✅ **Clear Ordering** — If stories have dependencies, the breakdown should surface a clear sequence or identify stories that can be done in parallel.
   - Example: "Auth (Entra ID SSO)" must complete before "Manager dashboard", but "Engineer survey form" can be parallel

3. ✅ **No Circular Dependencies** — Story A can't depend on Story B which depends on Story A

4. ✅ **Database Migrations as Explicit Stories** — If database schema changes are needed (new tables for responses, survey_instances), that's a story: "Create responses table with [columns]". Future stories depend on it.
   - Example: "Create schema: surveys table" is its own story, comes before "Seed initial surveys"

5. ✅ **Infrastructure Stories** — Auth setup, environment config, library setup are stories if other stories depend on them.

**Failure Criteria:** Stories with hidden dependencies, missing DB migration stories, infrastructure setup not called out as prerequisite stories, circular dependencies

---

## Test Case 4: No Duplicate Stories

**Problem:** Two stories describe the same implementation work from different angles, creating confusion and rework.

**Expected Output Criteria:**

1. ✅ **Unique Implementation Scope** — No two stories should describe implementing the same feature or endpoint.
   - Bad example: Story 1 "Create survey config API" and Story 2 "Implement survey settings endpoint" (same thing, different words)

2. ✅ **Clear User Perspective Distinction** — If two stories both involve surveys, they should be from different user types or workflows.
   - Good: Story 1 "Manager creates survey config" vs Story 2 "Engineer answers survey form" (different UX, different endpoints)
   - Bad: Story 1 "Implement survey feature" vs Story 2 "Add survey functionality" (same thing twice)

3. ✅ **No Cross-Story Redundancy in Acceptance Criteria** — If two stories both say "survey submits to database", that's redundant. One story handles it; others reference it as a dependency.

**Failure Criteria:** Two stories with identical or overlapping implementation work, unclear differentiation between similar stories, redundant acceptance criteria across stories

---

## Test Case 5: Complete Coverage

**Expected Output Criteria:**

1. ✅ **All PRD Features Covered** — Every feature mentioned in PRD should map to at least one story. No "manager authentication" without "Manager logs in via Entra ID SSO" story.

2. ✅ **All UX Flows Covered** — Every user flow from UX spec should have corresponding stories.
   - Example: If UX describes "Manager creates survey" flow with 5 steps, stories should cover each step or clearly show how they decompose into stories

3. ✅ **All Architecture Components** — Each major component (Frontend, Backend, Database, Auth, Scheduler) should have stories that implement it. If architecture says "in-process scheduler", there should be stories for scheduler implementation.

4. ✅ **Non-Functional Requirements** — Performance, scale, security requirements from PRD should appear as acceptance criteria or separate stories.
   - Example: "Survey form loads in <1.5s on 4G" should be an acceptance criterion on the form story, not omitted

5. ✅ **Admin/Operational Stories** — Data export (CSV), monitoring, backup, disaster recovery if mentioned in PRD.

6. ✅ **Cross-Cutting Concerns** — Logging, error handling, security headers, rate limiting if implied by architecture or PRD.

**Failure Criteria:** Missing stories for PRD features, uncovered UX flows, no infrastructure/operational stories, non-functional requirements omitted from acceptance criteria, gaps between architecture and stories

---

## Upstream Quality Impact Note (Step 3 — To Be Documented)

Will compare Epics and Stories produced from:
- High-quality upstream: Our finalized PRD + Architecture + UX (Exercises 5-7)
- Low-quality upstream: Weak PRD + generic Architecture + vague UX (RT-only)

Expected: High-quality upstream → precise stories with clear acceptance criteria; low-quality upstream → vague stories, missing dependencies, unclear scope

---

## Kata Stress Test: Snake with Replay System (Step 4 — To Be Documented)

**Criterion:** Ghost snake feature — replaying a prior game while playing a new game simultaneously.

Expected failures in story decomposition:
- Single story "Implement replay" without separating record-game vs playback-game
- Ghost snake acceptance criteria missing "share same grid?", "visually distinct?", "affect live game?", "no prior game fallback?"
- Stories don't decompose the replay data model (what to store, when to store, how to retrieve)

**Status:** [Ready to test after Context/Constraints added]

