# Implement Story Test Cases — Exercise 10

Domain: TeamPulse Code Implementation

An implementation is only useful if it's production-quality, fully tested, and follows the upstream plan. These test cases verify that code is clean, tested, and aligned with the tech stack.

---

## Test Story (From Exercise 9)

**Story:** ES-5 - Engineer Submits Survey Response

**Acceptance Criteria:**
1. POST /api/responses validates survey token
2. Accepts JSON: { survey_instance_id, survey_token, questions: [{question_id, answer_value}] }
3. 400 Bad Request if required fields missing or invalid
4. 401 Unauthorized "Survey link expired or invalid" if token invalid
5. Response stored WITHOUT survey_token/engineer identity (anonymity at schema level)
6. Returns 200 OK { success: true, message: "Thank you for your response" }
7. Form loads <1.5s on 4G; completable in <3 minutes
8. Mobile-responsive (375px viewport, 44px+ touch targets)

**Plan from Exercise 9:** Node.js/Express/PostgreSQL with Prisma, Zod, transaction patterns

---

## Test Case 1: Code Quality & Production Standards

**Problem:** Code that "works" is not production-quality. Production code must be typed, handle errors at boundaries, and follow conventions of the tech stack.

**Expected Output Criteria:**

For Node.js/Express/PostgreSQL stack:

1. ✅ **TypeScript Types:** All functions have parameter and return types. No `any` types. Request/response shapes defined as interfaces or types.
   - Good: `async function submitResponse(req: Request, res: Response): Promise<void>`
   - Bad: `async function submitResponse(req, res) { ... }`

2. ✅ **Error Handling at Boundaries:** API routes wrap logic in try-catch. HTTP error responses explicitly named (400, 401, 500).
   - Good: `if (!token.used) { ... } else { res.status(401).json({ error: 'Survey link expired' }); }`
   - Bad: `if (token.used) throw new Error('expired')`

3. ✅ **Stack Conventions Followed:**
   - Express: Uses middleware pattern, async route handlers
   - Prisma: Uses Prisma client methods (findUnique, create, $transaction), not raw SQL
   - Zod: Uses Zod schema parsing, not manual validation
   - Naming: camelCase for variables, PascalCase for types, UPPERCASE for constants

4. ✅ **No Magic Numbers:** Hardcoded values are constants. HTTP status codes are explicit (not `res.status(err.code)`).

5. ✅ **Logging & Observability:** Key operations logged (token validation, response storage, errors). No sensitive data in logs.

**Failure Criteria:** No TypeScript, missing error handling, raw SQL instead of ORM, manual validation instead of Zod, unclear status codes, magic numbers, no logging

---

## Test Case 2: Test Coverage

**Problem:** Code without tests is not production-ready. Test coverage must include happy path and error paths.

**Expected Output Criteria:**

1. ✅ **Happy Path Test:** Test that validates a correct survey token, stores a response, and returns 200 with correct message.
   ```
   Test: "POST /api/responses with valid token returns 200 and stores response"
   Setup: Create valid survey token and survey instance
   Action: POST /api/responses with valid payload
   Assert: Response status 200, message text correct, response row in DB
   ```

2. ✅ **AC3 (Validation) Tests:** Test missing fields, invalid types
   ```
   Test: "POST /api/responses without survey_instance_id returns 400"
   Test: "POST /api/responses with invalid answer_value type returns 400"
   ```

3. ✅ **AC4 (Token Validation) Tests:** Test invalid token, expired token, already-used token
   ```
   Test: "POST /api/responses with expired token returns 401"
   Test: "POST /api/responses with already-used token returns 401"
   Test: "POST /api/responses with nonexistent token returns 401"
   ```

4. ✅ **AC5 (Anonymization) Tests:** Test that response is stored without FK to team_members
   ```
   Test: "Response stored in DB has no team_member_id field"
   Test: "Response cannot be joined with team_members table"
   ```

5. ✅ **AC6 (Response Format) Tests:** Test success message structure
   ```
   Test: "Successful response has { success: true, message: 'Thank you for your response' }"
   ```

6. ✅ **Error Path Database Tests:** Test that transaction rollback works if storage fails

**Minimum coverage:** Happy path + at least one test per AC, including error cases

**Failure Criteria:** No tests, only happy path tested, missing error case tests, tests don't verify AC requirements

---

## Test Case 3: Stack Alignment

**Problem:** Implementation should use the tech stack idiomatically. Generic patterns are less efficient and harder to maintain than stack-native patterns.

**Expected Output Criteria:**

1. ✅ **Prisma ORM Usage:** Uses Prisma client, not raw SQL or other drivers. Leverages Prisma patterns (transactions, computed fields, relations).
   - Good: `prisma.$transaction([ ... ])`
   - Bad: `db.query("BEGIN TRANSACTION; ...")`

2. ✅ **Zod Validation:** Uses Zod schema parsing, not manual field checks.
   - Good: `const payload = payloadSchema.parse(req.body)`
   - Bad: `if (!req.body.survey_instance_id || typeof req.body.survey_instance_id !== 'number') { ... }`

3. ✅ **Express Middleware Patterns:** Uses async middleware, not callback-based patterns.
   - Good: `router.post('/api/responses', validatePayload, async (req, res) => { ... })`
   - Bad: `router.post('/api/responses', (req, res, next) => { next(); })`

4. ✅ **PostgreSQL Features:** Uses PostgreSQL-specific features if applicable (JSONB for flexible data, constraints, indexes).

5. ✅ **Async/Await:** Uses async/await, not callbacks or .then() chains.

**Failure Criteria:** Uses non-Prisma drivers, manual validation instead of Zod, callback-based Express routes, doesn't use async/await

---

## Upstream Quality Reflection (Step 4)

### What I Found When Trying to Improve Implement Story Quality

**Adding Constraints to Implement Story Helped With:**
- ✅ TypeScript strict types enforcement (Constraint: "no `any` types")
- ✅ Specific library usage (Constraint: "use Prisma, not raw SQL")
- ✅ Test coverage breadth (Constraint: "test happy path + error cases")

**Adding Constraints to Implement Story Did NOT Help With:**
- ❌ Atomicity/transaction patterns (generic constraint doesn't force Prisma.$transaction)
- ❌ Specific error message content ("401 with message X" requires Plan detail)
- ❌ API endpoint design (payload structure, response format specificity)

**The Real Fix for Those Failures:**
All three trace to **upstream Exercise 9 (Plan Story) quality**:
1. **Atomicity:** Plan explicitly named `prisma.$transaction()` → Implementation used it
2. **Error messages:** Plan specified "401 Unauthorized, 'Survey link expired or invalid'" → Implementation returned it
3. **API design:** Plan showed exact endpoint structure and schemas → Implementation matched

### Conclusion: Where Pipeline Leverage Actually Is

**Hypothesis confirmed:** Implementation quality is constrained by upstream clarity, not downstream Constraints.

- Strong upstream (PRD → Architecture → Plan): Implementation is clean, specific, production-ready
- Weak upstream (vague PRD → generic Architecture → vague Plan): Implementation is generic (regardless of Constraints)

**Key implication:** Adding Constraints to Implement Story has limited leverage if the Plan (Exercise 9) is vague. The real fix is improving Exercise 9 Plan quality, not tweaking Exercise 10 Constraints.

**For SDLC pipelines:** Invest in PRD, Architecture, and Plan clarity. Implement and Review commands are downstream and their Constraints have less leverage than upstream quality improvements.

