# Plan Story Test Cases — Exercise 9

Domain: TeamPulse Technical Implementation Planning

A plan is only useful if it's specific: instead of "create an API", the plan must name Express.js, the endpoint path, the validation library, the database interaction pattern, and error handling. This test file covers the most critical aspects of actionable technical plans.

---

## Test Story (Selected from Exercise 8 Output)

**Source:** Exercise 8, Epic: Engineer Survey Flow, Story ID: ES-5

**Story:** Engineer Submits Survey Response

**Description:** An engineer who receives a survey link via email clicks it, answers survey questions, and submits responses anonymously. The system validates the one-time token, stores responses without identity linkage (privacy-by-schema), and returns confirmation.

**Acceptance Criteria:**
1. ✅ POST /api/responses endpoint validates survey token (checks token is valid, not expired, not yet used)
2. ✅ Endpoint accepts JSON: { survey_instance_id, survey_token, [questions: {question_id, answer_value}] }
3. ✅ Validation fails with 400 Bad Request if required fields missing or answer_value invalid
4. ✅ Invalid token returns 401 Unauthorized with message "Survey link expired or invalid"
5. ✅ Response is stored WITHOUT any reference to survey_token or engineer identity (anonymity enforced at schema level)
6. ✅ Returns 200 OK with { success: true, message: "Thank you for your response" }
7. ✅ Survey form loads in <1.5s on 4G and is completable in <3 minutes total
8. ✅ Form is mobile-responsive (375px viewport, 44px+ touch targets, no horizontal scroll)

---

## Test Case 1: Technical Specificity (Stack-Specific)

**Problem:** A generic plan says "create API endpoint and validate". A specific plan names the framework, ORM, validation library, database patterns, and error handling approach specific to the tech stack.

**Expected Output Criteria:**

For Node.js/Express/PostgreSQL stack:

1. ✅ **Framework Specificity:** Plan mentions "Express.js" explicitly, describes middleware pattern (e.g., "POST /api/responses middleware that...")
2. ✅ **Validation Library:** Names "Zod" or "Joi" for schema validation (not generic "validation logic")
3. ✅ **ORM Specificity:** References "Prisma ORM" and specific Prisma patterns (e.g., "Prisma client.responses.create() with Prisma transaction to ensure atomicity")
4. ✅ **Database Patterns:** Mentions PostgreSQL-specific patterns if applicable (e.g., "use serial ID for responses, UUID for survey_token, FOREIGN KEY for survey_instance_id")
5. ✅ **Error Handling:** Describes Express error middleware or try-catch pattern with specific HTTP status codes (400, 401, 500)
6. ✅ **Authentication:** References how token validation is performed (e.g., "query survey_tokens table for matching token with expiration check")
7. ✅ **Anonymization Implementation:** Specifies schema-level enforcement (e.g., "responses table has no FK to team_members or survey_tokens; only stores survey_instance_id and answers")

For Python/FastAPI/SQLite stack (if tested):
- All above replaced with Python/FastAPI equivalents: FastAPI route decorators, Pydantic models, SQLAlchemy ORM, SQLite pragmas, FastAPI exception handlers, etc.

**Failure Criteria:** 
- Generic plan: "create API endpoint with validation and error handling" (no tech names)
- Stack-agnostic: "use a validation framework" instead of naming Zod/Pydantic
- Missing ORM: "store response in database" instead of "Prisma create()"
- Vague error handling: "return error response" instead of "401 Unauthorized with message 'Survey link expired'"

---

## Test Case 2: Stack-Load-Bearing (Context is Load-Bearing)

**Problem:** Context (tech stack) should drive the plan. Same story with different stacks should produce different plans. If plans are identical, Context is not load-bearing.

**Expected Output Criteria:**

**Test Setup:**
- Same story (Engineer Submits Survey Response)
- Same acceptance criteria
- **Context 1:** Express.js + Node.js 20 + PostgreSQL 16 + Prisma
- **Context 2:** FastAPI + Python 3.11 + SQLite + SQLAlchemy

**Plans Must Differ Specifically In:**

1. ✅ **Framework & Routing:**
   - Node.js: "Express app.post('/api/responses', middleware)"
   - Python: "FastAPI @app.post('/api/responses')"

2. ✅ **Validation:**
   - Node.js: "Zod schema: z.object({ survey_instance_id: z.number(), survey_token: z.string(), questions: z.array(...) })"
   - Python: "Pydantic model: class ResponsePayload(BaseModel): survey_instance_id: int, survey_token: str, questions: List[QuestionAnswer]"

3. ✅ **ORM & Database Interaction:**
   - Node.js: "const response = await prisma.responses.create({ data: { survey_instance_id, answers: JSON.stringify(questions) } })"
   - Python: "response = db.query(Responses).add(Responses(survey_instance_id=survey_instance_id, answers=json.dumps(questions)))"

4. ✅ **Token Validation Query:**
   - Node.js: "const token = await prisma.surveyTokens.findUnique({ where: { token: survey_token }, select: { id, expiresAt, used } })"
   - Python: "token = db.query(SurveyTokens).filter(SurveyTokens.token == survey_token).first()"

5. ✅ **Error Handling:**
   - Node.js: "if (!token || token.used) return res.status(401).json({ error: 'Survey link expired or invalid' })"
   - Python: "if not token or token.used: raise HTTPException(status_code=401, detail='Survey link expired or invalid')"

6. ✅ **Database Features:**
   - Node.js/PostgreSQL: "use PostgreSQL FOREIGN KEY constraints, UNIQUE for survey_token"
   - Python/SQLite: "use SQLite UNIQUE constraint on token, note that SQLite has limited FK support"

7. ✅ **Async/Concurrency:**
   - Node.js: "Express uses async/await, request handler: async (req, res) => { ... }"
   - Python: "FastAPI uses async, route: async def submit_response(payload: ResponsePayload): ..."

**Failure Criteria:** 
- Identical plans for both stacks (Context not load-bearing)
- Plan doesn't name specific frameworks/ORM/validation for either stack
- Differences are cosmetic (just different variable names) not structural

---

## Test Case 3: Acceptance Criteria Traceability

**Problem:** A plan should address every acceptance criterion. Missing a criterion in the plan means it might not be implemented.

**Expected Output Criteria:**

For each acceptance criterion from the story:

1. ✅ **AC1 (Token Validation):** Plan includes "Step: Validate survey token against survey_tokens table; check expiration; check not already used"

2. ✅ **AC2 (Payload Structure):** Plan includes "Define request payload shape: { survey_instance_id, survey_token, questions: [{ question_id, answer_value }] }"

3. ✅ **AC3 (Validation Errors):** Plan includes "Validation: If survey_instance_id missing or not integer, return 400. If questions array empty or malformed, return 400. Include error message in response."

4. ✅ **AC4 (Token Errors):** Plan includes "If token not found or expired, return 401 Unauthorized with message 'Survey link expired or invalid'"

5. ✅ **AC5 (Anonymization):** Plan includes "Database: responses table stores only survey_instance_id, question_id, answer_value, submitted_at. No FK to team_members or survey_tokens. No team_member_id field in responses."

6. ✅ **AC6 (Success Response):** Plan includes "On success, return HTTP 200 with { success: true, message: 'Thank you for your response' }"

7. ✅ **AC7 (Performance):** Plan includes "Performance target: Form load <1.5s on 4G. Acceptance: Use compression, minimize JS, lazy load non-critical assets. Submission roundtrip <500ms. API endpoint should be fast (Prisma/SQLAlchemy query optimization)."

8. ✅ **AC8 (Mobile Responsive):** Plan includes "Frontend: CSS media queries for mobile (375px viewport). Form elements: buttons/inputs ≥44px. No horizontal scroll. Use vertical stacking on mobile."

**Failure Criteria:** 
- Plan missing implementation steps for any AC
- Plan says "handle mobile responsiveness" without specific CSS/viewport details
- Plan says "optimize performance" without naming specific techniques (compression, lazy loading, query optimization)

---

## Five-Stage Pipeline Note (Step 4 — To Be Documented)

Will trace quality from PRD → Architecture → UX → Epics/Stories → Plan Story and identify gaps at each stage.

---

## Kata Stress Test: Sorting Algorithm Visualizer (Step 5 — To Be Documented)

**Criterion:** Step-through execution model for pauseable/resumeable algorithm animation.

Expected to test: Does plan mention generators, step-queues, or equivalent pauseable execution?

**Status:** [Ready to test after Context/Constraints added]

