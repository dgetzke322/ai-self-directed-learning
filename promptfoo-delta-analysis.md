# Haiku vs Sonnet Assertion Failures — Hypotheses for Exercise 4

## Summary
Haiku fails 5/6 test cases (Tests 2, 3, 4, 5, 6) where Sonnet passes. Test 1 (Audio/Visual) fails for both.
This document captures hypotheses about why Haiku underperforms, for use in refining the prompt.

---

## Test 2: Data Persistence as CSV

**Failing Assertions (Haiku):**
- REST API endpoint specification
- Backend technology/stack details
- Server-side validation requirement

**Hypothesis 1:**
The assertion "The PRD specifies server-side data validation and mentions REST API endpoints for data operations" fails on Haiku but passes on Sonnet. My hypothesis: Sonnet is inferring that backend architecture decisions (API design, tech stack) must be explicitly named and specified in a professional PRD. Haiku is not making this inference. If I add the explicit instruction "The PRD must specify concrete backend technologies (e.g., Node.js/Express, Python/Flask) and define at least three REST API endpoints (GET, POST, PUT/DELETE)" to the [Constraints] section, I predict Haiku will pass this assertion.

---

## Test 3: Dark Mode Support

**Failing Assertion (Haiku):**
- All 4 dark mode assertions fail

**Hypothesis 2:**
The assertion "The PRD indicates that users can select or toggle between light and dark modes" fails on Haiku but passes on Sonnet. My hypothesis: Sonnet is inferring that a professional PRD must include user interaction details (toggling, switching) and technical implementation approach (system preference detection, persistence). Haiku is treating dark mode as a feature statement without the implementation depth. If I add the explicit instruction "The PRD must explain HOW users will select themes (dropdown, toggle, system preference detection) and specify that theme preference persists across sessions" to the [Context] section, I predict Haiku will pass this assertion.

---

## Test 4: Security Compliance (CIS Controls)

**Failing Assertions (Haiku):**
- OWASP password hashing algorithm specification
- Password complexity requirements
- Secure session management (HTTPOnly/Secure)
- Rate limiting specification
- CIS Controls alignment reference
- No hardcoded credentials

**Hypothesis 3:**
The assertion "The PRD mentions using industry-standard password hashing algorithms (bcrypt, argon2, or PBKDF2) — NOT plaintext or weak hashing" fails on Haiku but passes on Sonnet. My hypothesis: Sonnet is inferring that security PRDs must name specific algorithms and standards by name. Haiku is treating "secure passwords" as a general security requirement without naming concrete technologies. If I add the explicit instruction "The PRD must name at least two specific password hashing algorithms (bcrypt, argon2, PBKDF2, SCRYPT) and reference a security standard (OWASP Top 10, CIS Controls, NIST)" to the [Constraints] section, I predict Haiku will pass this assertion.

**Hypothesis 4:**
The assertion "The PRD references CIS Controls alignment (specifically Controls 3, 5, or 6) for data protection and account management" fails on Haiku but passes on Sonnet. My hypothesis: Sonnet is inferring that a security-focused PRD for a compliant organization (Improving's SOC 2 baseline) must reference specific control frameworks by name and number. Haiku is not connecting the security requirement to external framework references. If I add the explicit instruction "When security is emphasized, the PRD must reference at least one specific security framework (CIS Controls X.Y, NIST CSF category, or OWASP category) with the framework name and control number" to the [Context] section, I predict Haiku will pass this assertion.

---

## Test 5: Timer Drift Correction

**Failing Assertions (Haiku):**
- Drift monitoring specification
- ±100ms threshold and automatic correction trigger
- Drift event reporting/logging
- Clear definition of ±100ms vs failure criteria
- No indication that drift cannot be detected

**Hypothesis 5:**
The assertion "The PRD specifies that when drift exceeds ±100ms, automatic correction is triggered" fails on Haiku but passes on Sonnet. My hypothesis: Sonnet is inferring that timing-critical requirements must specify measurable thresholds and automated response behaviors. Haiku is not making the connection between the ±100ms constraint and what action the system should take at that threshold. If I add the explicit instruction "When a timing drift requirement is given with a threshold (e.g., ±100ms), the PRD must specify: (1) drift detection mechanism, (2) exact threshold value, (3) automated correction triggered when threshold exceeded, (4) correction strategy" to the [Constraints] section, I predict Haiku will pass this assertion.

---

## Test 6: Note Taking Feature

**Failing Assertions (Haiku):**
- Note-taking feature specification
- CSV storage integration
- Progress documentation capability
- Optional (not mandatory) design

**Hypothesis 6:**
The assertion "The PRD specifies that notes are stored in the CSV data file for persistence and export" fails on Haiku but passes on Sonnet. My hypothesis: Sonnet is inferring that when a feature (notes) is introduced in the context of existing data persistence architecture (CSV), it must integrate with that architecture. Haiku is treating notes as an isolated feature without connecting it to the CSV data model. If I add the explicit instruction "When multiple features share data storage (e.g., timer sessions AND notes), the PRD must specify how each data type integrates into the shared CSV or data store structure, including field mappings" to the [Context] section, I predict Haiku will pass this assertion.

---

## Common Theme Across All Failures

**Observation:** Haiku appears to:
1. Treat requirements as isolated feature statements rather than integrated architectural decisions
2. Not infer that professional PRDs require specific technology names and measurable thresholds
3. Not automatically reference compliance frameworks or industry standards
4. Not explain "how" implementations work — only that they exist

**Recommended Prompt Refinements for Exercise 4:**
- Add explicit examples showing PRD format with specific algorithm names, threshold values, and framework references
- Include instruction: "PRD must make architectural decisions explicit, not implicit"
- Add guidance: "For each requirement, specify: WHAT (feature), HOW (mechanism), WHERE (system component), THRESHOLD (measurable limit if applicable)"
- Emphasize: "Include specific technology names and standard references, not just generic security/compliance terms"

