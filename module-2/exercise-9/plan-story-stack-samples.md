# Sample Plans — Stack Variations

## Test Story
**ES-5: Engineer Submits Survey Response**

Same story, two tech stacks, different plans.

---

## Plan 1: Node.js/Express/PostgreSQL Stack

**Tech Stack:** Node.js 20 LTS, Express.js 4, PostgreSQL 16, Prisma ORM, Zod validation

### Key Architecture Decisions

**1. Endpoint Implementation**
```
POST /api/responses
Express route with async middleware chain
```

**2. Request Validation**
```
Zod schema parsing:
z.object({
  survey_instance_id: z.number().positive(),
  survey_token: z.string().uuid(),
  questions: z.array(z.object({
    question_id: z.number(),
    answer_value: z.string() // or z.enum() for multiple choice
  }))
})
```

**3. Token Validation**
```
const token = await prisma.surveyTokens.findUnique({
  where: { token: survey_token },
  select: { id, expiresAt, used }
});

if (!token || new Date() > token.expiresAt || token.used) {
  return res.status(401).json({ error: 'Survey link expired or invalid' });
}
```

**4. Response Storage (Transaction Pattern)**
```
const response = await prisma.$transaction(async (tx) => {
  // Mark token as used
  await tx.surveyTokens.update({
    where: { token: survey_token },
    data: { used: true, usedAt: new Date() }
  });
  
  // Store response (anonymously - no FK to team_members)
  return await tx.responses.create({
    data: {
      survey_instance_id,
      answers: questions, // stored as JSONB in PostgreSQL
      submitted_at: new Date()
    }
  });
});
```

**5. Error Handling**
```
Express error middleware:
app.post('/api/responses', async (req, res, next) => {
  try {
    // ... validation and processing
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Invalid request format', details: error.errors });
    }
    next(error); // Pass to error handler
  }
});
```

**6. Performance Optimization**
- Database index on survey_tokens.token (UNIQUE)
- Connection pooling via Prisma connection pool
- Compression middleware for response bodies
- Frontend: lazy-load non-critical JS, inline critical CSS

---

## Plan 2: Python/FastAPI/SQLite Stack

**Tech Stack:** Python 3.11, FastAPI, SQLite, SQLAlchemy ORM, Pydantic validation

### Key Architecture Decisions

**1. Endpoint Implementation**
```
@app.post("/api/responses")
async def submit_response(payload: ResponsePayload):
    # Route handler
```

**2. Request Validation**
```
Pydantic model:
class ResponsePayload(BaseModel):
    survey_instance_id: int
    survey_token: str  # or UUID
    questions: List[QuestionAnswer]

class QuestionAnswer(BaseModel):
    question_id: int
    answer_value: str  # or Literal[...] for multiple choice
```

**3. Token Validation**
```
from datetime import datetime

token_record = db.query(SurveyTokens).filter(
    SurveyTokens.token == payload.survey_token,
    SurveyTokens.expires_at > datetime.now(),
    SurveyTokens.used == False
).first()

if not token_record:
    raise HTTPException(
        status_code=401,
        detail="Survey link expired or invalid"
    )
```

**4. Response Storage (Transaction Pattern)**
```
from sqlalchemy import text

try:
    # SQLite has limited FK support; enforce manually if needed
    # Mark token as used
    token_record.used = True
    token_record.used_at = datetime.now()
    
    # Store response (anonymously - no FK to team_members)
    response = Response(
        survey_instance_id=payload.survey_instance_id,
        answers=json.dumps([q.dict() for q in payload.questions]),
        submitted_at=datetime.now()
    )
    
    db.add(response)
    db.add(token_record)
    db.commit()
    
except Exception as e:
    db.rollback()
    raise HTTPException(status_code=500, detail="Database error")
```

**5. Error Handling**
```
from fastapi import HTTPException

@app.post("/api/responses")
async def submit_response(payload: ResponsePayload):
    try:
        # ... validation and processing
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal server error")
```

**6. Performance Optimization**
- SQLite PRAGMA settings (journal_mode, synchronous)
- Index on survey_tokens(token) UNIQUE
- FastAPI automatic gzip compression
- Frontend: same as Node.js (lazy-load, inline critical CSS)

---

## Plan Comparison Summary

| Aspect | Node.js/Express | Python/FastAPI |
|--------|-----------------|----------------|
| **Framework** | Express.js middleware | FastAPI dependency injection |
| **Validation** | Zod schema | Pydantic model |
| **ORM** | Prisma (fluent API) | SQLAlchemy (ORM methods) |
| **Transaction** | prisma.$transaction() | SQLAlchemy session + rollback |
| **Error Handling** | Express error middleware | FastAPI HTTPException |
| **Async Pattern** | async/await in middleware | async/await in route handler |
| **Database** | PostgreSQL (full-featured) | SQLite (limited FK, pragmas needed) |
| **Connection Pool** | Prisma connection pool | SQLAlchemy engine pool |

---

## Key Finding: Stack-Load-Bearing

**Same story, different stacks → different implementation approaches.**

Node.js/Express emphasizes:
- Middleware chain patterns
- Prisma's fluent transaction API
- PostgreSQL's JSONB for flexible data

Python/FastAPI emphasizes:
- Dependency injection for validation
- SQLAlchemy ORM patterns
- SQLite pragmas for performance

Both achieve the same business logic (validate token, store response anonymously, return 200/401/400), but the technical paths differ significantly.

**Implication:** Context specifying tech stack is load-bearing. A plan command without stack context cannot produce these specific, actionable plans.

