# Mobile Fitness Tracker — Architecture Document

## 1. System Overview Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    END-TO-END ENCRYPTION BOUNDARY            │
│                                                              │
│  ┌──────────────────┐              ┌──────────────────┐     │
│  │  iOS App         │              │  Android App     │     │
│  │  (Swift/SwiftUI) │              │ (Kotlin/Compose) │     │
│  │                  │              │                  │     │
│  │ • Core Data      │              │ • Room Database  │     │
│  │ • Local Crypto   │              │ • Local Crypto   │     │
│  │ • HealthKit      │              │ • Sensors        │     │
│  │ • APNs          │              │ • FCM            │     │
│  └────────┬─────────┘              └────────┬─────────┘     │
│           │                                  │               │
│           └──────────────┬───────────────────┘               │
│                          │                                   │
│                   HTTPS (Encrypted Payload)                  │
│                          │                                   │
│           ┌──────────────▼───────────────────┐               │
│           │  Sync Engine                     │               │
│           │  • Crypto wrapper                │               │
│           │  • Conflict resolution           │               │
│           │  • Queue management              │               │
│           └─────────────┬─────────────────────┘              │
└─────────────────────────┼──────────────────────────────────┘
                          │
                   HTTPS (Encrypted)
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
   ┌────▼────────┐  ┌─────▼──────┐  ┌──────▼──────┐
   │  REST API   │  │  Strava    │  │ Apple       │
   │ (Node.js +  │  │  REST API  │  │ HealthKit   │
   │  Express)   │  │            │  │ API         │
   │             │  └────────────┘  └─────────────┘
   │ • Auth      │
   │ • Sync      │
   │ • Webhooks  │
   └────┬────────┘
        │
   ┌────▼──────────────────────┐
   │  PostgreSQL 14            │
   │  • Encrypted at rest      │
   │  • Workouts (encrypted)   │
   │  • User accounts          │
   │  • Sync metadata          │
   │  • Audit logs             │
   └────┬──────────────────────┘
        │
   ┌────▼──────────────┐
   │  Redis Cache      │
   │  • Sessions       │
   │  • Rate limits    │
   │  • Sync queue     │
   └───────────────────┘
```

## 2. Component Architecture

### Frontend: iOS Application
**Technology:** Swift 5.9, SwiftUI, iOS 13+

**Responsibilities:**
- Local workout capture via CoreLocation (GPS) and HealthKit integration
- Encrypt workout data before transmission to backend
- Maintain local workout database (Core Data)
- Render analytics dashboard with local-computed statistics
- Handle offline-first synchronization with conflict resolution
- Display push notifications for milestone events

**Communication:**
- HTTPS REST to backend API
- APNs for push notifications
- HealthKit framework for Apple Health integration

**Data Ownership:**
- Encryption keys stored securely in Keychain (per-device, per-user)
- All workout data encrypted locally before sync
- Cache layer for frequently accessed data

**Scaling:**
- App runs locally; scales through efficient database queries
- Lazy-load analytics (7-day/30-day on demand)
- Batch sync of workouts during low-activity periods

### Frontend: Android Application
**Technology:** Kotlin 1.9, Jetpack Compose, Android 10+

**Responsibilities:**
- Local workout capture via FusedLocationProviderClient and sensor APIs
- Encrypt workout data before transmission to backend
- Maintain local workout database (Room)
- Render analytics dashboard with local-computed statistics
- Handle offline-first synchronization with conflict resolution
- Display push notifications for milestone events

**Communication:**
- HTTPS REST to backend API
- Firebase Cloud Messaging (FCM) for push notifications
- Google Play Services for location and sensor integration

**Data Ownership:**
- Encryption keys stored securely in Android Keystore (per-device, per-user)
- All workout data encrypted locally before sync
- Cache layer for frequently accessed data

**Scaling:**
- App runs locally; scales through efficient database queries
- Lazy-load analytics (7-day/30-day on demand)
- WorkManager for background sync tasks

### Backend: REST API Service
**Technology:** Node.js 18 LTS, Express 4.18, running in Docker containers

**Responsibilities:**
- Authenticate users (JWT tokens issued via OAuth)
- Receive encrypted workout payloads from mobile apps
- Store encrypted data in PostgreSQL (backend cannot decrypt)
- Orchestrate syncs across user's multiple devices
- Webhook handling for Strava integration
- Push notification dispatch (via APNs/FCM services)
- Rate limiting and API quota enforcement
- Audit logging for compliance

**Communication:**
- HTTPS REST endpoints
- PostgreSQL over TCP (internal network)
- Redis for session/rate-limit data
- APNs REST API for iOS push
- FCM REST API for Android push
- Strava REST API (outbound webhooks)

**Data Ownership:**
- Acts as sync coordinator; does NOT decrypt workout data
- Stores user accounts, device registration, sync metadata
- Maintains audit trail for all API calls

**Scaling:**
- Stateless service; scale horizontally via load balancer
- Connection pooling to PostgreSQL
- Redis session store for distributed sessions
- Kubernetes with auto-scaling (target: handle 10,000+ concurrent users)

### Database: PostgreSQL 14
**Technology:** PostgreSQL 14, encrypted-at-rest, automated backups

**Responsibilities:**
- Persist user accounts and authentication metadata
- Store encrypted workout payloads (backend cannot decrypt)
- Maintain sync version vectors (per-device, per-user)
- Track device registrations and last-sync timestamps
- Log all API access and data modifications
- Support GDPR/CCPA data export and deletion

**Schema Highlights:**
```sql
users {
  id UUID PRIMARY KEY,
  email ENCRYPTED,
  auth_method ENUM (oauth_apple, oauth_google, email_password),
  created_at TIMESTAMP,
  last_active TIMESTAMP
}

devices {
  id UUID PRIMARY KEY,
  user_id UUID FOREIGN KEY,
  device_type ENUM (ios, android),
  device_name TEXT,
  device_id TEXT UNIQUE,
  last_sync_version BIGINT,
  registered_at TIMESTAMP
}

workouts {
  id UUID PRIMARY KEY,
  user_id UUID FOREIGN KEY,
  device_id UUID FOREIGN KEY,
  encrypted_payload BYTEA,  -- Contains entire workout (user cannot access this)
  sync_version BIGINT,
  created_at TIMESTAMP,
  modified_at TIMESTAMP,
  deleted_at TIMESTAMP (soft delete)
}

sync_metadata {
  id UUID PRIMARY KEY,
  user_id UUID FOREIGN KEY,
  device_id UUID FOREIGN KEY,
  last_sync_timestamp TIMESTAMP,
  pending_changes BOOLEAN,
  retry_count INT
}

audit_logs {
  id UUID PRIMARY KEY,
  user_id UUID,
  action TEXT,
  resource TEXT,
  ip_address INET,
  timestamp TIMESTAMP
}
```

**Consistency Model:** ACID (strong consistency for user accounts and sync metadata; eventual consistency acceptable for audit logs)

**Indexing:**
- user_id on workouts, devices, sync_metadata
- modified_at on workouts (incremental sync)
- created_at on audit_logs (compliance queries)

**Backup/Recovery:** Daily automated backups to AWS S3, 30-day retention, recovery target objective (RTO) = 4 hours, recovery point objective (RPO) = 1 hour

### Cache: Redis
**Technology:** Redis 7.0, persistent AOF, master-replica configuration

**Responsibilities:**
- Store active JWT sessions (30-minute TTL)
- Rate-limit counters per user/IP
- Temporary sync queue for pending device syncs
- Analytics query cache (invalidated on new workout)

**Data Ownership:** Ephemeral; loss is acceptable (no SLA for cache loss)

**Scaling:** Horizontal via Redis Cluster for 10,000+ concurrent users; persistent storage for crash recovery

### External Integrations

**Strava Integration:**
- API: Strava REST API v3
- Bidirectional sync: Read activities from Strava, write our workouts to Strava
- User initiates OAuth connection within app
- Token stored encrypted in PostgreSQL
- Webhook: Strava notifies backend of new activities; backend fetches and stores encrypted payload

**Apple HealthKit (iOS only):**
- Framework: HealthKit API
- One-way read: App reads workout data from HealthKit
- Respects user's HealthKit privacy permissions
- Encrypts locally, syncs to backend

---

## 3. Data Architecture

### Core Data Model

**Workout Entity (Local, Encrypted in Transit/Storage)**
```
Workout {
  id: UUID,
  user_id: UUID,
  device_id: UUID,
  activity_type: ENUM (run, bike, swim, walk, gym, other),
  start_time: ISO8601,
  end_time: ISO8601,
  distance_meters: FLOAT (or null for gym),
  duration_seconds: INT,
  calories_burned: INT (or null),
  average_heart_rate: INT (or null),
  max_heart_rate: INT (or null),
  elevation_gain_meters: FLOAT (or null),
  gps_track: [{ lat, lon, altitude, timestamp }] (or null),
  notes: TEXT,
  source: ENUM (manual, strava, apple_health, gps_sensor),
  external_id: STRING (strava_id or apple_health_id if applicable),
  sync_version: BIGINT,
  created_at: TIMESTAMP,
  modified_at: TIMESTAMP,
  is_deleted: BOOLEAN (soft delete)
}
```

**User Entity (Unencrypted, Account Data)**
```
User {
  id: UUID,
  email: STRING (hashed for privacy),
  auth_method: ENUM (oauth_apple, oauth_google, custom_password),
  oauth_provider_id: STRING (optional),
  encryption_key_salt: BYTES (for client-side key derivation),
  preferences: {
    unit_system: ENUM (metric, imperial),
    notification_enabled: BOOLEAN,
    sync_frequency: ENUM (realtime, hourly, daily),
    analytics_granularity: ENUM (activity, daily, weekly)
  },
  created_at: TIMESTAMP,
  deleted_at: TIMESTAMP (GDPR compliance)
}
```

**Device Entity (Tracks Multi-Device Sync State)**
```
Device {
  id: UUID,
  user_id: UUID,
  device_type: ENUM (ios, android),
  device_os_version: STRING,
  app_version: STRING,
  device_name: STRING,
  device_identifier: STRING (unique per device),
  last_sync_timestamp: TIMESTAMP,
  last_sync_version: BIGINT,
  is_active: BOOLEAN,
  registered_at: TIMESTAMP,
  last_seen: TIMESTAMP
}
```

### Consistency Model

**Workouts:** Eventual consistency across devices (user edits on device A, syncs to backend, device B downloads on next sync)

**User Accounts:** Strong consistency (authentication state must be consistent across all devices)

**Sync Metadata:** Strong consistency (version vectors must be accurate to prevent conflicts)

### Synchronization Strategy

**Algorithm: Timestamp-Based Incremental Sync**
1. Client tracks last_sync_version per device
2. On sync trigger, client fetches all workouts modified since last_sync_version
3. Server returns encrypted workouts + new version vector
4. Client merges into local database, updates last_sync_version
5. Conflict resolution: **Last-write-wins** (timestamp from device with later modified_at)

**Sync Conflict Example:**
- Device A modifies workout at 2:00 PM, goes offline
- Device B modifies same workout at 2:05 PM, syncs successfully
- Device A syncs later: server returns Device B's version (later timestamp)
- Device A accepts server version; local changes lost but detected

**Offline Handling:**
- Workouts created offline have temporary local IDs
- On first sync, server assigns permanent UUID
- Client maintains mapping (local_id → permanent_id)
- All offline changes queued locally with timestamps

---

## 4. API Surface

### Authentication & Authorization

**POST /auth/login**
- Body: `{ provider: "oauth_apple" | "oauth_google" | "email", credentials }`
- Response: `{ access_token, refresh_token, user_id, expires_in }`
- Rate Limit: 5 attempts per minute per IP
- Authentication: None (public endpoint, but must validate OAuth token)

**POST /auth/refresh**
- Body: `{ refresh_token }`
- Response: `{ access_token, expires_in }`
- Rate Limit: 10 per minute per user
- Authentication: Bearer token

**POST /auth/logout**
- Body: `{}`
- Response: `{ success: true }`
- Authentication: Bearer token required

### Workout API

**POST /workouts**
- Body: `{ encrypted_payload: BYTES, metadata: { ... } }`
- Response: `{ workout_id: UUID, sync_version: BIGINT }`
- Rate Limit: 100 per hour per user
- Authentication: Bearer token (required)
- Note: Backend does NOT decrypt; stores as blob

**GET /workouts/sync?since_version=<BIGINT>&device_id=<UUID>**
- Query: since_version (optional, default 0), device_id (required)
- Response: `{ workouts: [{ workout_id, encrypted_payload, sync_version, modified_at }], next_version: BIGINT }`
- Rate Limit: 50 per hour per user
- Authentication: Bearer token (required)
- Note: Returns only encrypted payloads; backend never decrypts

**PATCH /workouts/:workout_id**
- Body: `{ encrypted_payload: BYTES }`
- Response: `{ workout_id, sync_version: BIGINT }`
- Rate Limit: 100 per hour per user
- Authentication: Bearer token (required)

**DELETE /workouts/:workout_id**
- Body: `{}`
- Response: `{ success: true }`
- Rate Limit: 50 per hour per user
- Authentication: Bearer token (required)
- Note: Soft delete; retained for 90 days (GDPR compliance)

### Device Registration

**POST /devices/register**
- Body: `{ device_type: "ios" | "android", device_name: STRING, device_id: STRING }`
- Response: `{ device_uuid: UUID, encryption_key_salt: BYTES }`
- Rate Limit: 10 per hour per user
- Authentication: Bearer token (required)

**GET /devices**
- Query: None
- Response: `{ devices: [{ device_uuid, device_type, device_name, last_seen, is_active }] }`
- Rate Limit: 20 per hour per user
- Authentication: Bearer token (required)

**DELETE /devices/:device_id**
- Body: `{}`
- Response: `{ success: true }`
- Rate Limit: 10 per hour per user
- Authentication: Bearer token (required)

### Analytics (Client-Side Computed)

**GET /analytics/summary?start_date=ISO8601&end_date=ISO8601**
- Query: start_date, end_date (optional, default last 7 days)
- Response: `{ total_distance: FLOAT, total_duration: INT, total_calories: INT, workout_count: INT, average_pace: FLOAT }`
- Rate Limit: 50 per hour per user
- Authentication: Bearer token (required)
- Note: Client decrypts locally; backend only validates query permissions

### Push Notification Webhooks (Inbound from Strava)

**POST /webhooks/strava**
- Header: X-Strava-Signature (HMAC validation)
- Body: `{ object_type: "activity", object_id: INT, event: "create" | "update" | "delete", ... }`
- Response: `{ success: true }`
- Rate Limit: Unlimited (webhook)
- Authentication: Signature validation

### Error Responses

**400 Bad Request**
```json
{
  "error": "invalid_request",
  "message": "Missing required field: device_id",
  "timestamp": "ISO8601"
}
```

**401 Unauthorized**
```json
{
  "error": "invalid_token",
  "message": "Token expired or invalid",
  "timestamp": "ISO8601"
}
```

**429 Too Many Requests**
```json
{
  "error": "rate_limit_exceeded",
  "retry_after_seconds": 60,
  "timestamp": "ISO8601"
}
```

---

## 5. Security Architecture

### Authentication

**Primary Method: OAuth 2.0**
- Apple Sign-In (iOS users)
- Google Sign-In (Android users, also iOS if preferred)
- Fallback: Custom email/password (requires additional verification)

**Token Management:**
- JWT (JSON Web Token) for access tokens, 30-minute expiry
- Refresh token (opaque, stored in secure HTTP-only cookie or secure storage)
- Token revocation on logout: ID added to Redis blacklist (TTL = original expiry time)

**Credential Storage:**
- Passwords hashed with bcrypt (cost factor 12)
- OAuth tokens stored encrypted in PostgreSQL, never in logs

### Authorization

**Role-Based Access Control (RBAC):**
- User: Can access own workouts, devices, analytics
- Admin: Can view anonymized usage metrics, manage compliance requests

**Multi-Device Constraints:**
- User can register up to 5 devices
- Each device receives sync metadata specific to that device
- Deleting a device revokes its access immediately

### Multi-Tenancy Enforcement

**Single-Tenant (Per User):**
- user_id required in all database queries
- Row-level security (RLS) not needed; enforced in application logic
- SQL queries always filter by authenticated user_id

**Data Isolation:**
- Workouts of User A never accessible to User B
- Sessions isolated by user_id in Redis

### Encryption Strategy

**At-Rest (Database):**
- PostgreSQL encryption (TDE - Transparent Data Encryption) via host OS
- Sensitive fields (emails, OAuth tokens) encrypted with application-level encryption
- Encrypted workouts stored as BYTEA; backend never holds decryption keys

**In-Transit:**
- All API communication via HTTPS (TLS 1.3 minimum)
- Certificate pinning on mobile apps (prevents MITM attacks)

**End-to-End (Workouts):**
- Client-side encryption: User's workout data encrypted on device before sync
- Key derivation: PBKDF2 (password-based) or stored in device keychain
- Cipher: AES-256-GCM
- Backend stores only ciphertext; cannot decrypt even if database is compromised

**Key Management:**
- Per-user encryption key (derived from device keystore, not transmitted)
- Device-specific salt stored in user preferences
- Key rotation: Future enhancement (out of V1 scope)

### PII Protection

**Data Classification:**
- User email: Encrypted at rest, never logged
- Workout data: Encrypted end-to-end; backend never sees plaintext
- GPS coordinates: Part of workout payload; encrypted
- Heart rate/calories: Encrypted as part of workout payload

**GDPR/CCPA Compliance:**
- Data export: User can request download of all data (returned encrypted)
- Data deletion: Soft delete with 30-day retention, permanent purge on request
- Audit logs: All data access logged with timestamp, user_id, action

### Rate Limiting & DDoS Mitigation

**Per-User Rate Limits (Redis):**
- Workouts: 100 create/update per hour
- Sync queries: 50 per hour
- Auth: 5 login attempts per minute per IP

**Global Rate Limits (API Gateway):**
- Max 1000 requests per minute per IP
- Sliding window with exponential backoff

**DDoS Mitigation:**
- API gateway (AWS WAF, Cloudflare, or reverse proxy) blocks malicious traffic
- Connection rate limiting per IP
- GeoIP filtering (optional: block non-target regions)

### Audit & Compliance

**Audit Logging:**
- All API calls logged: timestamp, user_id, endpoint, IP, response code
- Data modifications logged: who changed what, when
- Auth events logged: login, logout, token refresh, failed attempts
- Retention: 1 year (GDPR requirement)

**SOC 2 Type II Compliance:**
- Annual audit of access controls, encryption, data retention policies
- Disaster recovery plan (documented, tested annually)
- Incident response plan (documented)
- Employee security training (annually)

---

## 6. Deployment & Operations

### Infrastructure

**Compute:**
- Docker containers for backend service (Node.js + Express)
- Orchestration: Kubernetes (EKS on AWS, or equivalent on Azure/GCP)
- Auto-scaling: Target 2-4 pods per deployment; scale to 10+ under peak load
- Container registry: ECR (AWS) or Docker Hub

**Database:**
- PostgreSQL 14 managed service (AWS RDS Multi-AZ, or equivalent)
- Instance size: db.r5.large initially; scale to db.r5.xlarge if needed
- Storage: 100 GB SSD (gp3), auto-scaling enabled
- Backups: Automated daily, 30-day retention

**Cache:**
- Redis 7.0 managed service (AWS ElastiCache)
- Instance type: cache.r6g.large (memory-optimized)
- Persistence: AOF (append-only file) for durability
- Replication: Primary + 2 replicas for high availability

**Load Balancer:**
- Application Load Balancer (AWS ALB) or Nginx reverse proxy
- HTTPS termination, certificate via AWS ACM
- Health checks: API /health endpoint (returns 200 if DB connection OK)

### Configuration Management

**Environment Variables:**
- Database connection string (encrypted)
- Redis connection string
- Strava API keys
- Apple HealthKit team ID
- JWT secret key (rotated quarterly)
- Feature flags (for gradual rollout)

**Deployment Strategy:**
- Blue-green deployments (zero downtime)
- Canary deployments (roll out to 5% of traffic first, monitor for errors)
- Automatic rollback on deployment failure

### Monitoring & Observability

**Metrics (Prometheus):**
- API request latency (p50, p95, p99)
- Sync success rate (% of requests that complete within 2s)
- Database query latency (p95)
- Redis cache hit rate
- Concurrent active users
- Error rate (4xx, 5xx responses)

**Logging (ELK Stack or CloudWatch):**
- All API requests: method, path, status, latency, user_id
- Application errors: stack trace, context
- Database slow queries (> 500ms)
- Authentication events
- Retention: 30 days (searchable), 1 year (archived to S3)

**Tracing (Distributed Tracing):**
- Trace sync requests end-to-end (mobile → API → database → Strava)
- Identify bottlenecks in sync pipeline
- Tool: Jaeger or AWS X-Ray

**Dashboards (Grafana):**
- Real-time API health (requests/sec, error rate, latency)
- Sync pipeline status (queue depth, success rate, avg latency)
- Database health (connections, slow queries, disk usage)
- User adoption (DAU, MAU, retention)

### Alerting Strategy

**Critical Alerts (Immediate Notification):**
- API error rate > 5% (2-minute window)
- Sync success rate < 95% (5-minute window)
- Database unavailable or > 100ms latency
- Redis disconnection
- Disk usage > 80%

**Warning Alerts (Review Within 1 Hour):**
- Deployment failure
- Rate-limit rejections > 1% of traffic
- Strava API integration errors
- Slow queries taking > 1 second

### Backup & Disaster Recovery

**Database Backups:**
- Automated daily snapshots to AWS S3 (cross-region replication)
- Retention: 30 days
- Recovery testing: Monthly restore to dev environment
- RTO: 4 hours (restore from latest snapshot)
- RPO: 1 hour (acceptable data loss)

**Application Failover:**
- Kubernetes StatefulSet for backend (auto-restarts failed pods)
- Multi-AZ deployment (3 availability zones)
- Load balancer automatically routes around failed instances
- Manual failover to standby region (not automated in V1)

**Data Loss Prevention:**
- Workouts stored on device (local); backend is backup
- If backend lost, users retain local data; can re-sync to new backend
- Redis is ephemeral; loss acceptable (sessions rebuilt on next login)

### Database Migrations

**Strategy: Zero-Downtime Migrations**
- Schema changes deployed in advance (add new column as nullable)
- Application code updated to write to both old and new columns
- Background job migrates existing data
- Old column deprecated and removed in next release
- Rollback: If migration fails, new column is unused (backward compatible)

**Example Migration (Add new_field):**
1. Release 1: Add new_field (nullable) to schema
2. Release 2: App writes to both old_field and new_field
3. Release 3: Background job copies data from old_field to new_field
4. Release 4: App reads from new_field only; old_field removed

### Deployment Pipeline

**CI/CD (GitHub Actions or GitLab CI):**
1. On PR: Run tests (unit, integration), linting, SAST security scan
2. On merge to main: Build Docker image, push to registry
3. Automated deployment to staging environment
4. Run smoke tests and performance tests
5. Manual approval for production deployment
6. Blue-green deploy to production (old version still running)
7. Smoke tests against production
8. Gradual traffic shift (5% → 25% → 50% → 100%)
9. Monitor error rate for 5 minutes; auto-rollback if > 2%

---

## 7. Open Technical Decisions

### 1. Backend Framework & Language
**What:** Node.js + Express vs. Python + FastAPI vs. Go + Gin?

**Why It Matters:** Affects development velocity, operational complexity, performance characteristics, and team hiring.

**Options:**
- **Node.js + Express**: Fast to develop, large ecosystem, event-driven architecture fits async operations. Scaling risk at high concurrency.
- **Python + FastAPI**: Excellent async support, great documentation, data science integration (future analytics). Slower than compiled languages.
- **Go + Gin**: Compiled, fast, excellent concurrency, smaller memory footprint. Steeper learning curve; fewer libraries.

**Recommended:** Node.js + Express for V1 (development speed, abundant libraries for REST APIs, large talent pool). Migrate to Go if sync performance becomes bottleneck in V2.

**Fallback:** Python + FastAPI (good middle ground; slower than Node but more performant than Python + Flask).

---

### 2. Database: PostgreSQL vs. MongoDB vs. Firestore
**What:** Choice of primary data store (relational vs. document vs. fully managed).

**Why It Matters:** Data consistency, query flexibility, scaling model, operational overhead, cost structure.

**Options:**
- **PostgreSQL**: ACID transactions, strong consistency, powerful query language. Requires ops expertise; fixed scaling model.
- **MongoDB**: Flexible schema, horizontal scaling, document model. Weaker consistency guarantees; licensing complexity.
- **Google Firestore**: Fully managed, serverless, real-time sync. Proprietary vendor lock-in; less flexibility for complex queries.

**Recommended:** PostgreSQL 14 (on AWS RDS) for V1. ACID transactions essential for sync metadata consistency; relational model fits user/device/workout hierarchy. Encryption-at-rest via AWS KMS.

**Fallback:** If team prefers serverless, Cloud SQL (managed PostgreSQL on GCP) or Aurora Serverless (AWS). Avoid MongoDB for this workload (eventual consistency doesn't fit sync requirements).

---

### 3. Encryption Key Management
**What:** Where are encryption keys stored? On device, on backend, or hybrid (keys on device; backend manages metadata)?

**Why It Matters:** Affects user data privacy (if backend has keys, it can decrypt); recovery flow (lost device = lost access if keys device-only); compliance posture.

**Options:**
- **Device-only (Recommended for V1)**: User's encryption key never leaves device; derived from device keychain or password. If device lost, user cannot recover old workouts (but backend still has encrypted data). High privacy; poor UX for lost device.
- **Backend-managed**: Backend holds encryption keys encrypted with master key. Backend can decrypt and export data for user. Better UX; reduces privacy (backend could access data). Easier compliance (data export).
- **Hybrid**: User's key on device; backend only stores encrypted data + key metadata. User can request backend to re-encrypt data with new key on lost device scenario.

**Recommended:** Device-only for V1 (privacy-first approach aligns with product positioning). Backend cannot decrypt even under subpoena. Accept UX limitation: lost device = data loss (but users have backup via Strava export).

**Fallback:** Hybrid approach if user feedback demands better lost-device recovery.

---

### 4. Push Notification Service
**What:** Firebase Cloud Messaging (FCM) + Apple Push Notification service (APNs) vs. self-hosted vs. third-party service (Twilio/SendGrid).

**Why It Matters:** Reliability, latency, cost, operational complexity.

**Options:**
- **FCM + APNs (Recommended)**: Native services maintained by Google/Apple. Reliable, low latency. Requires certificate management for APNs. Minimal cost.
- **Third-party (Twilio, SendGrid)**: Managed service; handles both platforms. Simpler ops; higher cost (~$0.50/1M notifications). Potential latency overhead (third-party orchestration).
- **Self-hosted (Pusher, Amazon SNS)**: More control; still managed. Moderate complexity.

**Recommended:** FCM + APNs (native, zero additional cost, proven reliability for 10,000+ users).

**Fallback:** Amazon SNS (AWS-native, manages both FCM and APNs integration).

---

### 5. Offline Sync Conflict Resolution Strategy
**What:** When user edits same workout on two devices offline, which version wins?

**Why It Matters:** Data consistency, user experience, potential data loss.

**Options:**
- **Last-Write-Wins (Recommended for V1)**: Device with later modified_at timestamp; other changes discarded. Simple; users may lose edits if unaware.
- **Manual Merge**: Notify user; let them choose which version. Better UX; requires UI for conflict resolution. Complex to implement.
- **Versioning/Changelog**: Keep all versions; user selects which to restore. Highest data safety; UI complexity.
- **Operational Transform (OT)**: Merge both changes algorithmically (like Google Docs). Complex; overkill for fitness tracking.

**Recommended:** Last-Write-Wins for V1 (simple, predictable, user can re-enter changes if needed). Log conflict events for monitoring.

**Fallback:** Manual merge UI if user feedback demands it (V1.1 or V2).

---

### 6. Analytics Computation: Client-Side vs. Server-Side
**What:** Where are analytics computed? (e.g., "total distance in last 7 days")

**Why It Matters:** End-to-end encryption constraint: backend cannot decrypt to compute analytics server-side.

**Options:**
- **Client-Side (Recommended)**: Client decrypts all workouts, computes sums/averages locally. Respects E2E encryption; no privacy loss. Slower for large datasets (users with 5 years of data); requires more client CPU.
- **Server-Side**: Backend decrypts (if hybrid model) or client pre-computes stats and sends encrypted stats. Violates E2E encryption if backend decrypts. Fast; privacy risk.
- **Hybrid**: Client sends unencrypted stats metadata (e.g., total_distance for this week) to backend for analytics; workout details remain encrypted. Slight privacy loss (trends visible); good performance tradeoff.

**Recommended:** Client-side (respect E2E encryption). For performance: client caches computed stats (invalidated on new workout). Lazy-load stats on 7-day and 30-day tabs (don't compute all at once).

**Fallback:** Hybrid (if client-side too slow for power users with 5+ years of data).

---

### 7. Mobile App UI Framework: Native vs. Cross-Platform
**What:** Fully native (Swift + Kotlin) vs. React Native vs. Flutter?

**Why It Matters:** Performance, app store quality, time-to-market, team skill set.

**Options:**
- **Native (Recommended)**: Swift (iOS), Kotlin (Android). Highest performance, access to latest OS APIs (HealthKit, sensor fusion). Requires two teams or dual-skilled developers. Slower development.
- **React Native**: JavaScript, shared codebase. Faster development; lower performance. Potential library gaps for HealthKit integration.
- **Flutter**: Dart; excellent performance; less mature library ecosystem for health APIs.

**Recommended:** Native for V1 (HealthKit integration tight coupling to iOS; sensor fusion requirements demand native performance). Accept longer time-to-market for higher quality.

**Fallback:** React Native if team constraints force it; accept HealthKit limitations (may need native module).

---

### 8. Strava Integration: Pull vs. Push vs. Bidirectional
**What:** How does Strava data flow into our app?

**Why It Matters:** Affects data freshness, sync latency, API quota usage.

**Options:**
- **User-Initiated Pull**: User taps "Sync from Strava" button; app fetches recent activities. Simplest; delayed data (not real-time). Fits V1 MVP.
- **Server-Side Pull (Polling)**: Backend periodically fetches user's Strava activities (every hour). More complex; better data freshness; API rate limits.
- **Bidirectional Sync**: User's workouts pushed to Strava automatically. Requires Strava API token management, webhook validation. Complex; best UX.
- **Push (Webhook)**: Strava sends events to our backend; backend fetches and stores. Most complex; real-time data. Requires public webhook endpoint.

**Recommended:** User-Initiated Pull for V1 (MVP scope; users expect manual sync). Implement webhook-based bidirectional sync in V1.1 if user feedback demands it.

**Fallback:** Server-side polling (every 6 hours) if manual sync not sufficient.

---

## 8. Tradeoffs & Rationale

### Why This Architecture

**End-to-End Encryption Constraint:**
The PRD mandates E2E encryption (backend cannot decrypt). This fundamentally shapes the design: analytics must be client-computed, data export is encrypted-blob export, backend is a "dumb" sync coordinator. We accept performance cost (client-side computation) for privacy gain (zero-knowledge backend).

**Local-First + Sync Architecture:**
Mobile-first product with offline requirements. Local storage (Core Data, Room) ensures zero data loss if network unavailable. Sync engine handles conflict resolution and version management. Alternative: cloud-first (all data on backend immediately) loses offline capability and requires constant connectivity.

**Stateless Backend:**
Backend is horizontally scalable because it doesn't maintain app state (JWT tokens, Redis sessions are stateless). Alternative: sticky sessions per user would lock users to single backend instance, reducing scalability. Tradeoff: more complex session management, but required for 10,000+ concurrent users.

**PostgreSQL over NoSQL:**
Relational model (users, devices, workouts) fits well in rows/columns. ACID transactions essential for sync metadata consistency (if two devices sync simultaneously, version vector must not diverge). NoSQL (MongoDB) could work but weakens consistency guarantees. Cost: operational complexity (schema migrations), but payoff in data integrity.

### Known Limitations

1. **Lost Device = Data Loss**: Device-only encryption keys means lost phone = no access to old encrypted workouts (unless restored from device backup). Mitigated by: users can export from Strava, data permanently on backend (encrypted).

2. **Analytics Performance at Scale**: Client-side computation of 5 years of workouts (~500 entries) requires decryption and aggregation on device. May cause UI lag on older devices. Mitigated by: lazy-load stats, caching, background computation.

3. **Strava API Rate Limits**: Strava free tier is 600 requests per 15 minutes per app. With 10,000 users, naive pull approach hits quota quickly. Mitigated by: user-initiated pull (V1), server-side polling with backoff (V1.1).

4. **Multi-Device Sync Latency**: Ensuring < 2s sync across 3 devices requires efficient database queries and network reliability. Highly congested networks (satellite, poor cellular) may exceed budget. Mitigated by: local changes saved immediately (no sync blocking), background sync, explicit retry UI.

### Future Pivot Points

**If Social Features Enter Scope:**
- Add `friendships` table, `workout_visibility` field
- Aggregate public stats server-side (non-encrypted subset)
- Add `activity_feed` table for social timeline
- Implications: Architecture remains unchanged; new component added

**If AI Coaching Enters Scope:**
- Backend can access unencrypted aggregated stats (weekly totals, workout frequency)
- ML model ingests coarse-grained training data
- Implications: E2E encryption constraint relaxed for metadata; model runs in separate secured service

**If Wearable Support Needed:**
- Add Apple Watch complication (iOS), Wear OS app (Android)
- Workouts synced from watch to phone, then to backend
- Implications: New client component; architecture unchanged

**If Multi-Tenancy (Teams/Groups) Needed:**
- Add `team` table, `team_member` role-based access
- Shift from per-user to per-team sync coordination
- Implications: Database schema evolution; authorization model changes

### Performance & Cost Tradeoffs

| Dimension | Choice | Tradeoff |
|-----------|--------|----------|
| **Frontend** | Native (Swift + Kotlin) | Slower dev; best UX & performance |
| **Backend Language** | Node.js | Fast dev; potential concurrency limits at 10k+ users (addressable via Go in V2) |
| **Database** | PostgreSQL | Operational complexity; strong consistency |
| **Encryption** | Client-side E2E | Privacy gain; analytics perf cost; lost device data loss |
| **Sync Algorithm** | Timestamp-based LWW | Simplicity; potential silent data loss in edge cases |
| **Offline Support** | Local-first | Complex sync logic; zero-network usability |
| **Push Notifications** | Native (FCM + APNs) | Zero additional cost; ops complexity (cert management) |

### Security vs. Usability Tradeoff

- **E2E Encryption**: Maximizes privacy; backend cannot help with lost device recovery
- **30-min Token Expiry**: Good security; users re-authenticate frequently (acceptable for fitness app)
- **Rate Limiting**: Prevents abuse; users hitting limits during intense sync (rare, but possible)
- **No Biometric Auth in V1**: Simpler launch; users tolerate password entry for account access

This architecture prioritizes **privacy by design** (E2E encryption, zero-knowledge backend) at the cost of some operational complexity and lost-device recovery UX. This aligns with the product's positioning: "unified tracking, reliable sync, data ownership."
