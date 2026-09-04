# Create UX Test Cases — Exercise 7

Domain: TeamPulse UX Design

UX specifications are user-type dependent and format-specific. These test cases verify that the UX command produces developer-ready specs with audience-appropriate detail and proper interaction flow documentation.

## Test Case 1: Required Elements (Developer-Ready Format)

**Expected Output Criteria:**

A developer-ready UX spec must include:

1. ✅ **Component Inventory** — All UI elements documented (buttons, forms, tables, modals, etc.) with descriptions
2. ✅ **Interaction Flows** — User journeys documented by user type (managers configuring surveys, engineers answering surveys)
3. ✅ **State Handling** — Explicit documentation of error states (validation errors on form, survey closed/expired), empty states (no surveys, no results yet), loading states (form loading, results computing)
4. ✅ **Accessibility Notes** — Mobile responsiveness, keyboard navigation, ARIA labels, color contrast notes

**Failure Criteria:** Missing any required element, components listed without functionality, flows described generically without user type differentiation, no state handling documentation, no accessibility notes

---

## Test Case 2: Audience-Specific Detail (Manager vs. Engineer)

**Expected Output Criteria:**

TeamPulse has two distinct user types with different UX needs:

**For Managers:**
- ✅ Survey configuration interface (setting questions, schedule, distribution list)
- ✅ Results aggregation view (trend dashboard, CSV export, peer comparison)
- ✅ Team management (adding/removing team members, role assignment)
- ✅ Access control (can view only own teams' results)

**For Engineers:**
- ✅ Survey form (receive via email, answer via one-time link, minimal distractions)
- ✅ Mobile-first design (must work on phone, completable in under 3 minutes)
- ✅ No management features (engineers see only the form)
- ✅ One-time link usability (expired link handling, "already answered" state)

**Failure Criteria:** Treating both user types identically, describing a generic "admin panel" without role-specific UX, no mention of engineer-facing form experience vs manager-facing config experience

---

## Test Case 3: Format Specificity (Developer-Ready vs. Designer-Ready)

**Expected Output Criteria:**

Spec must be specific enough that a developer can implement without questions:

1. ✅ **Component Layout** — Wireframes or ASCII mockups showing component arrangement (not just "dashboard with results")
2. ✅ **Input Validation** — Specific rules (e.g., "survey name required, 1-100 chars, alphanumeric + spaces + hyphens")
3. ✅ **Button States** — Every button has explicit states (default, hover, disabled, loading, success)
4. ✅ **API Mapping** — Flows explicitly tied to endpoints (e.g., "clicking Submit calls POST /api/responses")
5. ✅ **Error Messages** — Specific error copy (not "Error" but "Survey closed on Sept 1 at 5pm")

**Failure Criteria:** Vague descriptions ("nice dashboard", "intuitive survey form"), missing button/state documentation, no API mapping, generic error handling without specific messages

---

## Test Case 4: Mobile Accessibility (Specific Requirement)

**Expected Output Criteria:**

PRD specifies: "Survey form must be mobile-accessible and completable in under 3 minutes."

Spec must address:

1. ✅ **Mobile Layout** — Form stacks vertically, readable on 375px width (iPhone SE)
2. ✅ **Touch Targets** — Buttons ≥48px, form inputs ≥44px for tap accuracy
3. ✅ **Completion Flow** — Step-by-step breakdown of timing (email open, link click, form load, answer time, submit)
4. ✅ **Network Resilience** — Handling on slow 4G (form load <1.5s per PRD, what happens if slower?)
5. ✅ **No External Distractions** — Minimal Chrome UI (fullscreen vs embedded), no secondary navigation

**Failure Criteria:** Desktop-first layout, generic mobile mention without specifics, no timing analysis, ignores 4G performance requirement, treats mobile as afterthought

---

## Step 1 Observations (Before Iteration)

**Starter Output (No Context/Constraints):**

Haiku produced output that:
- Began with generic "Document Overview" section
- Listed components (Configuration Page, Survey Form, Results Dashboard) without user-type differentiation
- Described flows generically without distinguishing manager vs. engineer perspectives
- Mentioned "mobile support" without specific layout or timing details
- Did not specify error messages, validation rules, or button states
- Lacked ASCII mockups or layout descriptions

**Key Gaps Identified:**
- Context needed: Explicit user personas (managers vs. engineers), mobile-first platform emphasis
- Constraints needed: Format specificity (wireframes, button states, error messages), timing/performance requirements
- Without these, output is designer-sketch level, not developer-ready

---

## Three-Command Pipeline Check (Step 4)

Will document quality improvement after running PRD → Architecture → UX in sequence.

---

## Kata Stress Test: Tic-Tac-Toe with Unbeatable AI (Step 5)

**Criterion:** Does UX spec produce mode-specific interaction flows?

The kata has three play modes:
1. **Player vs. Player** — Turn-based, simple click-to-place
2. **Easy AI** — Random move selection (simple)
3. **Impossible AI** — Minimax algorithm with move evaluation visualization (shows minimax scores on board)

**Expected:** Separate interaction flows for each mode, with detailed documentation of Impossible AI's minimax score visualization.

**Status:** [Ready to test after Context/Constraints added]

