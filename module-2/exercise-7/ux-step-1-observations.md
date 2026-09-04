# Step 1: Starter Observation — Create UX

**Date:** 2026-09-04
**Test:** Starter create-ux.md (no Context, no Constraints) against TeamPulse PRD
**Result:** 1/1 PASSED

## Model Output Analysis

Haiku produced a UX specification titled "TeamPulse UX Specification" with generic structure:

### What the Model Assumed (Without Context)

1. **User Type Assumption:** Generic/indifferent
   - No distinction between manager and engineer user flows
   - Treated all features as equally important for all users
   - Did not differentiate access patterns

2. **Format Assumption:** Designer-sketch level
   - Started with "Document Overview" section
   - Listed components without interaction details
   - No button states documented
   - No input validation rules specified
   - No error message copy provided

3. **Platform Assumption:** Desktop-primary
   - Mobile mentioned generically ("responsive design")
   - No specific mobile layout details (viewport, touch targets, stacking)
   - No performance/timing analysis for mobile forms

### What Was Omitted (Developer Needs)

1. **Component Inventory:** Missing specificity
   - Components listed (Configuration Page, Survey Form, Results Dashboard)
   - But no documentation of individual UI elements (buttons, form fields, tables)
   - No accessibility attributes mentioned

2. **Interaction Flows:** Undifferentiated
   - Generic flow described without user-type variants
   - Missing: "Manager sees X, Engineer sees Y"
   - No step-by-step user actions → system responses

3. **State Handling:** Not addressed
   - No error states (validation failures, expired links, survey closed)
   - No empty states (no teams, no results yet)
   - No loading states documented

4. **Mobile Accessibility:** Vague
   - "Mobile support" mentioned without specifics
   - No viewport size, touch target size, timing requirements
   - Missed the < 3-minute completion requirement

5. **Developer-Ready Details:** Absent
   - No ASCII mockups or layout descriptions
   - No button state documentation (default, hover, disabled, loading, success)
   - No input validation rules (what's required? max length? character restrictions?)
   - No specific error messages (just generic "error handling")
   - No API mapping (which endpoints are called by which actions?)

## Gaps Identified (Context vs. Constraints)

### Context Needed
- **Audience specificity:** Engineering managers vs. engineers have different needs and technical sophistication
- **Platform emphasis:** Mobile-first is critical (mobile-accessible, < 3 min completion)
- **User sophistication:** Managers expect guided config; engineers expect instant, distraction-free experience

### Constraints Needed
- **Format specificity:** Spec must include components, flows, states, accessibility, mockups
- **Button/state documentation:** Every interactive element must have explicit states
- **Error messages:** Specific copy, not generic
- **Validation rules:** Character limits, required fields, allowed characters
- **Mobile performance:** <1.5s load time on 4G, < 3 minute completion flow

## Hypothesis for Iteration 1

Adding explicit Context (audience differentiation, mobile platform emphasis) and Constraints (format requirements: mockups, button states, error messages, validation) will improve output specificity toward developer-ready level.
