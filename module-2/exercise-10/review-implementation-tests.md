# Review Implementation Test Cases — Exercise 10

Domain: TeamPulse Code Review

A code review is only useful if it's specific, traces back to requirements, and catches both surface-level and architectural issues. These test cases verify that reviews are rigorous and actionable.

---

## Test Story & Implementation

**Story:** ES-5 - Engineer Submits Survey Response

**Acceptance Criteria:** (Same as Implement Story tests)
1. POST /api/responses validates survey token
2. Accepts JSON payload structure
3. 400 validation errors
4. 401 token errors
5. Response stored anonymously (no FK to team_members)
6. 200 success response format
7. Performance (<1.5s load on 4G, <3 min completion)
8. Mobile responsive

**Implementation:** Node.js/Express/PostgreSQL code (from Implement Story output)

---

## Test Case 1: Review Report Structure & Completeness

**Problem:** A review that says "good work, a few small things" is not useful. A rigorous review addresses every acceptance criterion.

**Expected Output Criteria:**

1. ✅ **Acceptance Criteria Addressing:** Review explicitly addresses EACH AC (1-8). For each, clear pass/fail verdict.
   ```
   AC1 (Token Validation): PASS — findUnique query correctly checks expiration and used flag
   AC2 (Payload Structure): PASS — Zod schema validates all required fields
   AC3 (Validation Errors): PASS — Returns 400 with descriptive error messages
   AC4 (Token Errors): PASS — Returns 401 with correct message
   ...
   ```

2. ✅ **Overall Verdict:** Clear pass/fail summary at top of review. If failing, what's required to pass.
   ```
   VERDICT: PASS — Implementation meets all acceptance criteria
   OR
   VERDICT: FAIL — Missing error handling for expired tokens (AC4)
   ```

3. ✅ **Specific Issues with Code References:** Every issue cited includes file and line number.
   - Good: `responses.service.ts:45 - Missing error handler for findUnique returning null`
   - Bad: `Error handling could be improved`

4. ✅ **Test Coverage Assessment:** Review evaluates whether tests cover all AC and error paths.
   ```
   Test Coverage: PASS — Tests cover happy path and all error cases (400, 401, anonymization)
   OR
   Test Coverage: FAIL — Missing test for expired token case (AC4)
   ```

5. ✅ **Architecture Review:** Review addresses whether implementation follows the planned architecture (generators for pauseable, transactions for atomicity, etc.)

**Failure Criteria:** 
- Review doesn't address all ACs
- No line/file references for issues
- No test coverage assessment
- Generic observations ("code is clean")
- Missing overall verdict

---

## Test Case 2: Specificity & Actionability

**Problem:** A review saying "better error messages would help" is not actionable. A specific review says "Line 45 catches all errors with generic message; should distinguish 401 (expired token) from 400 (bad payload)."

**Expected Output Criteria:**

1. ✅ **Code Citations:** Every issue includes:
   - Filename
   - Line number(s)
   - Exact code snippet quoted
   - What's wrong and why
   - Specific fix recommendation
   
   Example:
   ```
   Issue: Line 45 in responses.service.ts
   Current: 
     if (error) res.status(500).json({ error: 'Failed' });
   Problem: Generic error message doesn't help debugging
   Fix: Check error type and return specific 401 for token errors, 500 for DB errors
   ```

2. ✅ **TypeScript Issues:** If types are missing, review cites specific locations and what types should be.
   ```
   Line 12: Function `submitResponse` missing return type. Should be `Promise<void>`
   ```

3. ✅ **Test Issues:** If tests are missing, review identifies which AC lacks test coverage.
   ```
   Missing test for AC4 (expired token). Need test that validates token.expiresAt > now()
   ```

4. ✅ **Performance Issues:** If relevant to ACs, review checks against performance requirements.
   ```
   AC7 requires <1.5s load on 4G. Review checks: Are database queries optimized? Are indexes on survey_tokens.token?
   ```

5. ✅ **Security/Anonymization Issues:** Review specifically checks AC5 (no FK to team_members).
   ```
   AC5: Verify responses table has no team_member_id column. PASS — only survey_instance_id, questions, submitted_at
   ```

**Failure Criteria:** 
- Issues without file/line references
- Vague recommendations ("improve error handling")
- Generic feedback ("good variable names")
- Missing performance assessment
- Missing security/privacy assessment

---

## Test Case 3: Acceptance Criteria Traceability

**Problem:** A review that doesn't tie findings back to ACs is not actionable. Developers don't know if a failing test is a "nice to have" or a "must fix for AC compliance."

**Expected Output Criteria:**

1. ✅ **Each AC Has Clear Status:** Review section for each AC (1-8) with PASS/FAIL and reasoning.
   ```
   **AC1: POST /api/responses validates survey token**
   Status: PASS
   Evidence: Line 23 of responses.service.ts correctly queries surveyTokens table
   ```

2. ✅ **Issue → AC Mapping:** When an issue is found, review clearly states which AC it affects.
   ```
   Issue (Line 45): Missing error handler
   Impacts: AC4 (401 response for invalid token)
   Status: FAIL until fixed
   ```

3. ✅ **Test Coverage → AC Mapping:** Review assesses test coverage per AC.
   ```
   AC1 (Token Validation):
   - Test 1: Valid token → PASS
   - Test 2: Expired token → PASS
   - Test 3: Already-used token → PASS
   Coverage: COMPLETE
   ```

4. ✅ **Dependencies Between ACs:** Review notes if fixing one issue resolves multiple ACs.
   ```
   Fixing the error handler at Line 45 will resolve both AC3 (400 errors) and AC4 (401 errors)
   ```

**Failure Criteria:** 
- Issues not mapped to ACs
- No per-AC summary
- Test coverage assessment doesn't reference specific ACs
- Can't tell from review which ACs are failing

---

## Upstream Quality Note

[To be filled: How does quality of acceptance criteria in the Story affect Review Implementation specificity?]

