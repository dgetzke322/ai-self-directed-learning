# Task Management System — Architecture Document

## 1. System Overview Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Web Browser                              │
│                  (React Single-Page App)                          │
└────────────────────┬────────────────────────────────────────────┘
                     │ HTTPS (REST)
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                   API Gateway / Load Balancer                     │
│                      (Cloud provider)                             │
└────────────────────┬────────────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
   ┌─────────┐  ┌─────────┐  ┌─────────┐
   │ Backend │  │ Backend │  │ Backend │
   │  API #1 │  │  API #2 │  │  API #3 │
   │Node/Exp │  │Node/Exp │  │Node/Exp │
   └────┬────┘  └────┬────┘  └────┬────┘
        │            │            │
        └────────────┼────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │  PostgreSQL Database   │
        │   (Connection Pool)    │
        └────────────────────────┘
                     │
        ┌────────────┴────────────┐
        ▼                         ▼
   ┌─────────────┐         ┌──────────────┐
   │ Redis Cache │         │ Backup Store │
   │  (optional) │         │  (Cloud Obj) │
   └─────────────┘         └──────────────┘
```

The system consists of a React-based frontend communicating via HTTPS with a horizontally-scalable Node.js/Express backend. All state is persisted in PostgreSQL. An optional Redis cache layer can reduce database load during peak usage. The system is deployed on a cloud provider (AWS, GCP, or Azure) with load balancing and auto-scaling.

## 2. Component Architecture

### Frontend
- **Technology**: React 18+ (TypeScript recommended)
- **Responsibilities**: User interface, task creation/editing, team list viewing, status updates, form validation
- **Communication**: REST API over HTTPS
- **Deployment**: Static build deployed to CDN (Cloudfront, Cloudflare, or Cloud CDN)
- **State Management**: React Context or Redux (TBD in open decisions)
- **Scaling**: Client-side caching, code splitting, lazy loading

### Backend API
- **Technology**: Node.js 18+ with Express framework
- **Responsibilities**: Request routing, business logic, task CRUD operations, assignment logic, permission enforcement, database queries
- **Communication**: REST JSON endpoints, receives HTTP requests from frontend
- **Database Connection**: Connection pooling to PostgreSQL (PgBouncer or node-postgres with pooling)
- **Stateless Design**: Each instance can handle any request; no session affinity required
- **Scaling**: Horizontal scaling via container orchestration (Kubernetes or container service)
- **Typical Instance Resources**: 1-2 CPU, 2GB RAM for small teams

### PostgreSQL Database
- **Technology**: PostgreSQL 14+
- **Responsibilities**: Persistent storage of teams, users, tasks, assignments
- **Consistency**: ACID transactions for data integrity
- **Connection Model**: Connection pooled from backend instances
- **Scaling**: Vertical scaling (larger machine) for V1; read replicas for V2
- **Backup Strategy**: Automated daily snapshots, 30-day retention
- **Recovery**: Point-in-time recovery to any timestamp within backup window

### Cache Layer (Optional)
- **Technology**: Redis 7+ or Memcached
- **Responsibilities**: Cache recently accessed task lists, user permissions, team metadata
- **Use Case**: Reduce database load for frequently viewed tasks
- **TTL**: 5-minute expiration on cached task lists
- **Fallback**: Database hit if cache miss (no stale data problems)
- **Scaling**: Single Redis instance sufficient for V1 (small teams); cluster mode for V2

## 3. Data Architecture

### Core Entities

**Teams Table**
```
id (UUID, PK)
name (VARCHAR)
created_at (TIMESTAMP)
created_by (UUID, FK to users)
workspace_name (VARCHAR, unique)  -- Single workspace per team
```

**Users Table**
```
id (UUID, PK)
team_id (UUID, FK to teams)
email (VARCHAR, unique within team)
full_name (VARCHAR)
role (VARCHAR) -- "admin", "member"
created_at (TIMESTAMP)
last_login (TIMESTAMP)
```

**Tasks Table**
```
id (UUID, PK)
team_id (UUID, FK to teams)
title (VARCHAR, required)
description (TEXT, nullable)
status (VARCHAR) -- "open", "in_progress", "closed"
assigned_to (UUID, FK to users, nullable)
created_by (UUID, FK to users)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
due_date (DATE, nullable)
```

**Task Assignments History (Audit Trail)**
```
id (UUID, PK)
task_id (UUID, FK to tasks)
assigned_to (UUID, FK to users)
assigned_by (UUID, FK to users)
assigned_at (TIMESTAMP)
```

### Relationships
- One team has many users (1:N)
- One user can create many tasks (1:N)
- One task is assigned to zero or one user (1:N, nullable)
- One team has many tasks (1:N)

### Consistency Model
- **ACID**: All operations use database transactions to ensure consistency
- **Task updates**: Optimistic locking via updated_at timestamp to prevent concurrent edit conflicts
- **Assignment changes**: Logged in audit table for team visibility

### Indexing Strategy
- Primary keys on all tables
- Unique constraint on (team_id, email) for users
- Index on tasks(team_id, status) for filtering open tasks
- Index on tasks(assigned_to) for user's task list
- Index on tasks(created_at) for sorting

### Schema Design Rationale
- Task assignment is nullable to support unassigned tasks
- Single workspace per team (team_id = workspace_id) simplifies V1 scope
- Audit trail on assignments enables future "who assigned this?" queries

## 4. API Surface

All endpoints require JWT authentication token in Authorization header.

### Task Endpoints

**GET /api/v1/teams/:teamId/tasks**
- Query params: `status=open&assigned_to=userId&limit=50&offset=0`
- Returns: Array of task objects
- Response time SLA: < 1 second (via cache or index optimization)
- Rate limit: 100 requests/minute per user

**POST /api/v1/teams/:teamId/tasks**
- Request body: `{ title, description?, status, assigned_to?, due_date? }`
- Returns: Created task object with ID
- Validation: title required, max 255 chars; status must be valid enum
- Authorization: Any team member

**GET /api/v1/teams/:teamId/tasks/:taskId**
- Returns: Single task object with full details
- Authorization: Any team member

**PATCH /api/v1/teams/:teamId/tasks/:taskId**
- Request body: Partial task object (any updatable fields)
- Returns: Updated task object
- Concurrency: Optimistic locking via ETag header
- Authorization: Creator or assigned team member or admin

**DELETE /api/v1/teams/:teamId/tasks/:taskId**
- Returns: 204 No Content
- Authorization: Task creator or team admin only

### Team Endpoints

**GET /api/v1/teams/:teamId**
- Returns: Team details and member list
- Authorization: Team member

**GET /api/v1/teams/:teamId/members**
- Returns: Array of user objects in team
- Authorization: Team member

### Authentication & Authorization

**Authentication Mechanism**: JWT tokens issued at login
- Token lifetime: 24 hours
- Refresh token: 30-day lifetime (for mobile, not needed for V1 web)
- Header format: `Authorization: Bearer <jwt_token>`

**Authorization Model**: Role-based (team level)
- **admin**: Full access including user management
- **member**: Read/write tasks, assign to self or others, read team info

**Permission Enforcement**:
- All endpoints validate team_id match from URL against user's teams
- Task edit/delete limited to creator, assigned person, or admin

### Error Handling

Standard HTTP status codes:
- 200 OK: Successful request
- 201 Created: Resource created
- 400 Bad Request: Invalid input (validation error, missing required fields)
- 401 Unauthorized: Missing or invalid token
- 403 Forbidden: User lacks permission for action
- 404 Not Found: Resource not found
- 409 Conflict: Concurrency conflict (optimistic lock failed)
- 429 Too Many Requests: Rate limit exceeded
- 500 Internal Server Error: Unexpected server error

Error response format:
```json
{
  "error": "CONFLICT",
  "message": "Task was modified by another user",
  "details": { "field": "updated_at" }
}
```

### Rate Limiting

- **Unauthenticated**: 10 requests/minute per IP
- **Authenticated**: 100 requests/minute per user
- **Burst allowance**: 20 requests in 1-second window
- Enforcement: Leaky bucket algorithm via Redis

## 5. Security Architecture

### Authentication
- **Method**: JWT (JSON Web Tokens)
- **Issuer**: Backend API at `/auth/login` endpoint
- **Storage**: HttpOnly cookie (prevents XSS token theft) + optional localStorage fallback
- **Validation**: Signature verified on every request using HMAC-SHA256
- **Token rotation**: New token issued on refresh; old token invalidated

### Authorization
- **Model**: Team-based role-based access control (team admin vs. member)
- **Enforcement**: Every endpoint checks user's team membership and role
- **Implementation**: Middleware that verifies JWT, then loads user permissions from cache/DB

### Multi-Tenancy
- **Model**: Multi-tenant-single-database (all teams in one database)
- **Isolation**: Row-level security via team_id foreign key on all team data
- **Enforcement**: Middleware adds WHERE team_id = :userTeamId to all queries
- **Risk**: No logical database per team means shared infrastructure; suitable for V1

### PII Protection
- **Data Classification**: Emails and names are PII; tasks are internal only
- **At Rest**: Database encryption at rest (provider managed)
- **In Transit**: HTTPS/TLS 1.3 enforced on all endpoints
- **Handling**: Never log user emails in access logs; use user IDs instead
- **Retention**: User data deleted when team is deleted (cascading delete)

### Audit Logging
- **What to log**: User login/logout, task assignments, permission changes
- **Where**: Separate audit table (tasks_assignments_history)
- **Retention**: Audit logs retained for 90 days
- **Access**: Only admins can view audit logs (future feature)

### DDoS & Rate Limiting
- **Strategy**: Rate limiting per user + per IP + per endpoint
- **Implementation**: Redis-backed sliding window counter
- **Thresholds**: See section 4 (API Surface)

### Secrets Management
- **Database password**: Stored in environment variables or managed secrets store (AWS Secrets Manager, etc.)
- **JWT signing key**: Rotated quarterly; old key kept for 30 days for token validation
- **API keys** (if external services): Never committed to source code

## 6. Deployment & Operations

### Infrastructure
- **Platform**: Cloud provider (AWS, GCP, or Azure recommended)
- **Compute**: Containerized Node.js application
- **Orchestration**: Kubernetes (EKS/GKE/AKS) or managed container service (Fargate, Cloud Run)
- **Database**: Managed PostgreSQL service (RDS, Cloud SQL, or Azure Database)
- **Cache**: Managed Redis (ElastiCache, Cloud Memorystore, or Azure Cache)

### Containerization
- **Base Image**: `node:18-alpine` (minimal, secure)
- **Docker Build**: Multi-stage build to minimize final image size
- **Image Registry**: Cloud provider's container registry (ECR, GCR, ACR)

### Configuration Management
- **Environment variables**: `DB_HOST`, `DB_PORT`, `REDIS_URL`, `JWT_SECRET`, `NODE_ENV`
- **Secrets**: Managed via provider's secrets service (not in .env files)
- **Config files**: None; all config via env vars or CLI flags

### Monitoring & Observability

**Metrics** (collected via Prometheus or cloud provider):
- Request rate (requests/second)
- Request latency (p50, p95, p99)
- Error rate (4xx, 5xx per endpoint)
- Database connection pool utilization
- Cache hit rate
- Task creation rate (business metric)

**Logging**:
- Application logs: Structured JSON format, sent to log aggregator (CloudWatch, Stackdriver, ELK)
- Log level: INFO in production; DEBUG in staging
- No PII in logs (use user IDs, not emails)

**Tracing** (optional for V1):
- Distributed tracing via OpenTelemetry or Jaeger
- Trace all external service calls (database, cache, auth)

### Alerting
- **Database unavailable**: Alert if connection pool exhausted or query latency > 5s
- **High error rate**: Alert if 5xx errors > 1% of traffic
- **Cache failure**: Alert if Redis connection lost (service continues but slower)
- **Service down**: Alert if health check fails on all instances

### Backup & Disaster Recovery
- **Database backup**: Automated daily snapshots, 30-day retention
- **Backup testing**: Monthly restore test to verify integrity
- **RTO**: 1 hour (recovery time objective)
- **RPO**: 24 hours (recovery point objective)
- **Backup location**: Different region from primary

### Database Migrations
- **Strategy**: Backward-compatible migrations (add column before using it)
- **Tool**: Liquibase or Flyway for version control
- **Deployment**: Run before deploying new code; automatic via CI/CD
- **Rollback**: Schema version can be downgraded if needed

### Deployment Pipeline
1. **Code commit to main branch**
2. **CI/CD** (GitHub Actions, GitLab CI, or cloud provider):
   - Run unit tests, linting, type checking
   - Build Docker image, push to registry
   - Run integration tests in staging
   - Run security scan (vulnerability scanning)
3. **Deploy to staging** (manual trigger or auto)
4. **Smoke tests** in staging
5. **Deploy to production** (manual approval):
   - Rolling deployment (1-2 instances at a time)
   - Automatic rollback if error rate spikes
   - Health checks ensure instance is ready before routing traffic

### Scaling Strategy
- **Horizontal scaling**: Add/remove backend instances based on CPU and memory utilization
- **Auto-scaling rules**:
  - Scale up if CPU > 70% for 2 minutes
  - Scale down if CPU < 30% for 5 minutes
  - Minimum 2 instances; maximum 10 instances for small team V1
- **Database scaling**: Vertical scaling (larger machine) for V1; read replicas for V2

## 7. Open Technical Decisions

### 1. State Management Library (Frontend)
- **What**: How to manage application state in React?
- **Why it matters**: Impacts complexity of frontend, debugging difficulty, team productivity
- **Options considered**:
  - React Context + useReducer (minimal, no external dep)
  - Redux (powerful but verbose for small app)
  - Zustand (lightweight and trending)
  - TanStack Query (best for server state)
- **Recommended**: TanStack Query for server state + React Context for UI state
- **Rationale**: TanStack Query handles caching, refetching, and sync with backend; Context keeps UI state simple
- **Fallback**: Plain React Context if team prefers simplicity

### 2. Concurrent Editing Conflict Resolution
- **What**: How to handle when two users edit the same task simultaneously?
- **Why it matters**: Could lose user's edits if handled poorly
- **Options considered**:
  - Optimistic locking (last write wins) — simple, risk of data loss
  - Pessimistic locking (lock task while editing) — safe, but blocks collaboration
  - Operational transformation (merge concurrent edits) — complex, ideal collaboration
  - Conflict detection + UI prompt (user chooses) — good UX, manual resolution
- **Recommended**: Optimistic locking with conflict detection (ETag header)
- **Rationale**: Small teams unlikely to edit same task; if conflict, user sees message to retry
- **Fallback**: Pessimistic locking if conflicts are frequent

### 3. Notification Strategy
- **What**: How to notify user when assigned to task or when assignment changes?
- **Why it matters**: User needs to know; impacts feature scope
- **Options considered**:
  - In-app toast only (no external notification)
  - Email notification on assignment (slow, out-of-scope for V1)
  - Webhook-based integrations (too complex for V1)
  - WebSocket for real-time UI update (nice to have, not required)
- **Recommended**: In-app toast on assignment + task list refresh
- **Rationale**: Fits V1 scope; WebSocket can be V2+ enhancement
- **Fallback**: None; skip notifications if too complex

### 4. Session Storage Mechanism
- **What**: Where to store user session state on frontend?
- **Why it matters**: Impacts security, persistence across page reloads
- **Options considered**:
  - HttpOnly cookie only (most secure, survives page reload)
  - LocalStorage only (vulnerable to XSS, but survives reload)
  - Memory + cookie fallback (balance security and UX)
- **Recommended**: HttpOnly cookie + refresh token in localStorage
- **Rationale**: Cookie prevents XSS token theft; refresh token enables long sessions
- **Fallback**: HttpOnly cookie only if localStorage not available

### 5. Search Implementation
- **What**: How to implement task search across tasks in PRD?
- **Why it matters**: V1 requires "search files" (presumably task search)
- **Options considered**:
  - Simple SQL LIKE query on title/description
  - Full-text search (PostgreSQL native FTS)
  - Elasticsearch (overkill for small dataset)
- **Recommended**: PostgreSQL full-text search with basic UI
- **Rationale**: Good performance on small datasets; no external service needed
- **Fallback**: SQL LIKE query if FTS too complex

### 6. Database Choice
- **What**: SQL vs. NoSQL for task data?
- **Why it matters**: Schema flexibility, query patterns, transaction support
- **Options considered**:
  - PostgreSQL (ACID, relational, mature)
  - MongoDB (flexible schema, eventual consistency)
  - Firebase Realtime DB (easy but expensive at scale)
- **Recommended**: PostgreSQL
- **Rationale**: ACID guarantees important for task integrity; relational model fits task/team/user structure
- **Fallback**: MongoDB if schema flexibility becomes critical in early feedback

## 8. Tradeoffs & Rationale

### Why This Architecture

**Simplicity over sophistication**: This architecture avoids unnecessary complexity. No event-driven architecture, no microservices, no distributed transactions. A monolithic backend is sufficient for small teams; refactor to services only if bottlenecks emerge.

**PostgreSQL over NoSQL**: Chosen for ACID guarantees and relational structure. Task dependencies and team permissions are easier to model and enforce in SQL.

**Stateless backend**: Every instance can serve any request, enabling simple horizontal scaling and zero-downtime deployments.

**Team-based multi-tenancy**: All data in one database per deployment, not separate database per customer. Acceptable for V1 where there's one organization; V2 can split to separate databases if needed.

### Known Limitations

1. **No real-time collaboration**: Multiple users editing the same task don't see each other's changes in real-time (must refresh). WebSockets can be added in V2.

2. **Single region**: No geographic redundancy. If the deployment region goes down, service is unavailable. Add replicas in V2.

3. **Limited analytics**: PRD explicitly defers analytics to V2. Current data model doesn't track task completion time or team velocity.

4. **No offline mode**: Mobile users cannot work offline (in-app only, no mobile app in V1 scope anyway).

5. **Basic search**: Full-text search is pattern matching, not semantic search. Elasticsearch or vector search can be added if needed.

### Future Pivot Points

- **Mobile app**: Currently web-only. React Native reuse of API; separate mobile backend if performance differs.
- **High volume**: If > 1,000,000 tasks, consider database partitioning by team_id.
- **Real-time sync**: Add WebSocket server for live task updates across browsers.
- **Integrations**: Currently none planned. Webhook system for third-party tools would go in V2.
- **Self-hosted**: Currently cloud-only. Helm charts and self-hosted guide in V2+.

### Performance vs. Complexity Tradeoffs

| Tradeoff | V1 Choice | V2+ Consideration |
|----------|-----------|-------------------|
| Caching | Optional Redis | Cache required if 10k+ users |
| Search | Full-text SQL | Elasticsearch if search dominant use case |
| Notifications | In-app only | Push notifications + email for V2 |
| Real-time | Polling | WebSocket for collaborative editing |
| Sessions | JWT + cookies | OAuth2 if integrating with external IdP |

### Deferred Decisions & Why

**Mobile app** — Deferred because V1 is web-only. Adds 40% scope if included.

**Analytics & reporting** — Deferred because not in V1 success metrics. Adds dashboard complexity; can query database directly for basic reports.

**Third-party integrations** — Deferred because no mention in requirements. Webhooks or Zapier integration in V2.

**Advanced permissions** — Deferred because V1 assumes small teams with role-based access (admin/member). Fine-grained permissions in V2.

---

## Summary

This architecture provides a **scalable, maintainable, secure foundation** for a small-team task management system. It prioritizes simplicity and correctness over premature optimization. The system can run on any major cloud provider with minimal configuration. Open decisions are explicitly marked for future refinement as the product learns from real users.

**Estimated development time**: 6-8 weeks for experienced team
**Estimated infrastructure cost**: $200-500/month for 100 users (cloud provider dependent)
