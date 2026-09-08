# Mobile Fitness Tracker — Architecture Document

## 1. System Overview Diagram

The system consists of native iOS and Android clients operating in local-first mode, synchronizing with a backend API server that coordinates data, manages external integrations, and provides cloud backup capabilities.

```
┌─────────────────────────────────────────────────────────────────┐
│                        EXTERNAL SYSTEMS                         │
│  ┌──────────────┐        ┌──────────────┐    ┌──────────────┐  │
│  │  Strava API  │        │ Apple Health │    │ Google Fit   │  │
│  │              │        │ / HealthKit  │    │ (future)     │  │
│  └──────┬───────┘        └──────┬───────┘    └──────┬───────┘  │
└─────────┼──────────────────────┼─────────────────────┼──────────┘
          │                      │                     │
    ┌─────▼────────────────────────────────────────────▼──────┐
    │              BACKEND API SERVER (Node.js)               │
    │  ┌──────────────────────────────────────────────────┐   │
    │  │ • User & Auth Service                            │   │
    │  │ • Workout Sync Engine                            │   │
    │  │ • External Integration Manager                   │   │
    │  │ • Push Notification Service                      │   │
    │  │ • Analytics & Aggregation Service                │   │
    │  └──────────────────────────────────────────────────┘   │
    └─┬──────────────────────┬──────────────────┬──────────────┘
      │                      │                  │
  ┌───▼─────┐        ┌──────▼──────┐    ┌─────▼──────┐
  │PostgreSQL│        │  Redis      │    │AWS S3/Vault│
  │Database  │        │  (Cache)    │    │(E2E Backup)│
  └──────────┘        └─────────────┘    └────────────┘
      ▲                                           ▲
      │                                           │
  ┌───┴─────────────────────────────────────────┴───┐
  │   SYNC COORDINATION & MESSAGE QUEUE (RabbitMQ)  │
  │   • Job scheduling                              │
  │   • Async notification delivery                 │
  │   • Sync event streaming                        │
  └─────────────────────────────────────────────────┘
                      ▲                ▲
          ┌───────────┘                └────────────┐
          │                                         │
      ┌───▼─────────────────┐      ┌────────────────▼──┐
      │   iOS App (Swift)   │      │ Android App       │
      │  ┌──────────────┐   │      │ (Kotlin)          │
      │  │ Core Data /  │   │      │ ┌──────────────┐  │
      │  │ Realm (Local)│   │      │ │ Room / Realm │  │
      │  │ Database     │   │      │ │ (Local DB)   │  │
      │  └──────────────┘   │      │ └──────────────┘  │
      │  ┌──────────────┐   │      │ ┌──────────────┐  │
      │  │ Background   │   │      │ │ Foreground   │  │
      │  │ Sync Service │   │      │ │ Sync Service │  │
      │  └──────────────┘   │      │ └──────────────┘  │
      └─────────────────────┘      └───────────────────┘
```

**Component Relationships:**
- iOS/Android apps: Capture workouts locally, sync bi-directionally with backend
- Backend API: Coordinates syncs, manages external integrations, stores canonical data
- External APIs: Strava and HealthKit provide read/write access to user fitness data
- Database: PostgreSQL stores canonical state (user profiles, workouts, sync metadata)
- Cache: Redis manages session tokens, sync queues, rate limiting
- Message Queue: RabbitMQ handles async job scheduling and push notification delivery
- Cloud Storage: S3 + Vault store encrypted backup copies of user data

---

## 2. Component Architecture

### iOS App (Swift)
- **Technology**: Swift 5.9+, iOS 14+ deployment target, minimum 200MB free disk space assumption
- **Local Database**: Core Data (built-in, zero dependencies) or Realm 10.x for faster queries if performance testing reveals bottlenecks
- **Background Sync**: OperationQueue for background sync tasks; URLSession background configuration for large uploads
- **Location Tracking**: Core Location framework with CLLocationManager; battery optimization via region monitoring and significant change notifications
- **HealthKit Integration**: HealthKit framework for bi-directional sync with Apple Health
- **Push Notifications**: UserNotifications framework; APNs for silent notifications to trigger sync
- **Key Dependencies**: Alamofire (networking), TweetNaCl/libsodium (E2E encryption), CryptoKit (key management)
- **Data Ownership**: Owns all local workout data; syncs with backend represent intent to persist, not state changes
- **Communication Protocol**: REST over HTTPS with custom encryption layer
- **Scaling Strategy**: App scales naturally with device storage; backend limits determine sync volume

### Android App (Kotlin)
- **Technology**: Kotlin 1.9+, Android 10+ (API 29+), Jetpack libraries for lifecycle management
- **Local Database**: Room ORM with SQLite backend; provides compile-time schema verification
- **Background Sync**: WorkManager for reliable background jobs; Foreground Service for user-visible sync operations
- **Location Tracking**: Fused Location Provider API (Google Play Services) for battery-efficient positioning
- **Fitness Data**: Google Fit API (when expanded); currently Apple Health equivalent is HealthKit (iOS only)
- **Push Notifications**: Firebase Cloud Messaging (FCM) for both data and notification messages
- **Key Dependencies**: Retrofit (networking), Kotlinx Serialization (JSON), Tink (E2E encryption), Jetpack Security
- **Data Ownership**: Owns all local workout data; syncs represent user intent
- **Communication Protocol**: REST over HTTPS with encrypted payload layer
- **Scaling Strategy**: Scales with device storage; Room's query optimization handles large datasets

### Backend API Server (Node.js + Express)
- **Technology**: Node.js 18 LTS, Express 4.18, TypeScript for type safety
- **Runtime Environment**: Docker containers on Kubernetes or AWS ECS; horizontal auto-scaling based on CPU/memory
- **Core Services**:
  - **User & Authentication**: JWT + OAuth2 (Google, Apple); 15-minute token TTL, refresh tokens stored in Redis with 30-day expiry
  - **Workout Sync Engine**: Processes sync requests from clients, detects conflicts, coordinates external integrations
  - **Strava Integration**: Bi-directional sync via Strava API v3; webhook subscriptions for near-instant updates
  - **HealthKit Proxy**: Mediates iOS app requests to HealthKit; stores sync metadata and conflict resolution rules
  - **Push Notification Manager**: Integrates APNs (iOS) and FCM (Android)
  - **Analytics Pipeline**: Aggregates workout statistics (weekly distance, pace averages, milestone tracking)
- **Communication Protocol**: REST API with JSON; POST /api/v1/sync for workout sync, GET /api/v1/workouts for retrieval
- **Rate Limiting**: Token bucket per user (100 sync requests/minute); adaptive backoff on rate limit hits
- **Scaling Strategy**: Stateless design enables horizontal scaling; sync engine uses distributed locks (Redis) for consistency

### PostgreSQL Database
- **Technology**: PostgreSQL 14+, hosted on RDS or self-managed
- **Core Tables**:
  - `users` (id, email, password_hash, auth_provider, created_at, updated_at)
  - `workouts` (id, user_id, activity_type, start_time, duration_seconds, distance_km, pace_avg, calories_burned, local_created_at, synced_at, strava_id, status)
  - `workout_segments` (id, workout_id, lat, lon, altitude_m, heart_rate, timestamp) — for route/elevation tracking
  - `sync_metadata` (id, user_id, last_sync_timestamp, device_id, pending_changes_count)
  - `external_accounts` (id, user_id, provider, provider_user_id, access_token_encrypted, refresh_token_encrypted, expires_at)
  - `milestones` (id, user_id, type, threshold, achieved_at, notification_sent)
- **Indexing Strategy**:
  - PRIMARY KEY on id (all tables)
  - UNIQUE INDEX on (user_id, created_at) for user workouts
  - INDEX on (user_id, synced_at) for incremental sync queries
  - INDEX on (synced_at DESC) for recent workouts query
  - PARTIAL INDEX on (status = 'pending') for conflict resolution
- **Consistency Model**: ACID with immediate consistency; conflicts resolved via server-side last-write-wins with timestamp comparison
- **Partitioning Strategy**: Partition `workout_segments` by user_id + month for query performance at scale
- **Backup Strategy**: Point-in-time recovery (PITR) enabled; daily snapshots to S3; 30-day retention

### Redis Cache Layer
- **Technology**: Redis 7.x (cluster mode for HA), hosted on ElastiCache or self-managed with Sentinel
- **Data Model**:
  - User session tokens: `session:{user_id}:{token_hash}` → token metadata (expires in 15 min)
  - Refresh tokens: `refresh:{user_id}:{token_id}` → refresh token (expires in 30 days)
  - Rate limit buckets: `ratelimit:{user_id}:{endpoint}` → request count (1-minute window)
  - Sync queue: `syncqueue:{user_id}` → list of pending sync operations
  - Lock mechanism: `lock:{resource_id}` → exclusive sync lock (auto-expire in 30 seconds)
- **TTL Strategy**: All keys have explicit TTL; no unbounded memory growth
- **Consistency**: Redis replicas for read throughput; single master for writes
- **Scaling Strategy**: Cluster mode with 6 shards for horizontal scaling

### RabbitMQ Message Queue
- **Technology**: RabbitMQ 3.11+ with durable queues and message persistence
- **Queues & Exchanges**:
  - **Direct Exchange (`sync.events`)**: Routes workout sync events to relevant consumers
    - Queue: `sync.strava` — subscribed by Strava sync worker
    - Queue: `sync.notifications` — subscribed by notification service
  - **Fanout Exchange (`notifications.milestone`)**: Broadcasts milestone events to APNs/FCM workers
  - **Delayed Exchange (via plugin)**: Schedules push notifications with configurable delay
- **Message Format**: JSON with timestamp, user_id, action, payload
- **Durability**: Messages persisted to disk; queues survive broker restarts
- **Scaling Strategy**: Multiple consumer instances scale horizontally; round-robin message distribution

### External Integrations
- **Strava API**:
  - Endpoint: `https://www.strava.com/api/v3`
  - Authentication: OAuth2 token (user-specific); backend stores encrypted tokens
  - Operations: GET /athlete/activities (import), POST /activities (export), webhook subscriptions
  - Sync Strategy: Bi-directional; server reconciles local + Strava state on each sync
  - Rate Limit: 600 req/15min per user; backend respects with exponential backoff

- **Apple HealthKit** (iOS only):
  - Accessed via iOS app directly; no server-side proxy
  - Permissions: Read/write workouts, active energy burned, heart rate (if available)
  - Sync: iOS app reads HealthKit → uploads to backend → backend stores in PostgreSQL
  - One-way write: Backend does not write back to HealthKit (user controls via iPhone Health app)

---

## 3. Data Architecture

### Core Data Model

**Users** — Authentication and profile
```
user {
  id: UUID
  email: string (unique)
  password_hash: string (bcrypt)
  auth_provider: 'email' | 'google' | 'apple'
  created_at: timestamp
  updated_at: timestamp
  encryption_public_key: string (PEM format, for E2E backup)
}
```

**Workouts** — Canonical fitness activity record
```
workout {
  id: UUID
  user_id: UUID (foreign key)
  activity_type: 'run' | 'cycling' | 'walk' | 'gym'
  start_time: timestamp (UTC)
  end_time: timestamp (UTC)
  duration_seconds: integer
  distance_km: decimal
  pace_avg: decimal (min/km)
  elevation_gain_m: integer
  calories_burned: integer
  heart_rate_avg: integer (optional)
  notes: text
  
  -- Sync metadata
  local_created_at: timestamp (when user created on device)
  synced_at: timestamp (when last synced to backend)
  device_id: string (which device originated this)
  sync_status: 'local_only' | 'synced' | 'conflict'
  
  -- External platform IDs
  strava_id: string (null until exported)
  healthkit_uuid: string (null, iOS only)
  
  created_at: timestamp (server)
  updated_at: timestamp (server)
}
```

**Workout Segments** — High-resolution geospatial/telemetry data
```
workout_segment {
  id: UUID
  workout_id: UUID (foreign key, partitioned)
  timestamp: timestamp (millisecond precision)
  latitude: decimal(9,6)
  longitude: decimal(9,6)
  altitude_m: decimal
  speed_m_s: decimal
  heart_rate_bpm: integer (optional)
  cadence_rpm: integer (optional, cycling/running)
}
```

**Sync Metadata** — Tracks per-device sync state
```
sync_metadata {
  id: UUID
  user_id: UUID (unique, one per user)
  last_sync_timestamp: timestamp
  last_device_id: string
  pending_changes_count: integer
  conflict_count: integer
}
```

**External Accounts** — Linked platform credentials (encrypted)
```
external_account {
  id: UUID
  user_id: UUID (foreign key)
  provider: 'strava' | 'google_fit'
  provider_user_id: string
  access_token_encrypted: string (AES-256)
  refresh_token_encrypted: string (AES-256)
  token_expires_at: timestamp
  scopes_granted: string[]
  synced_at: timestamp
}
```

**Milestones** — User achievement tracking for notifications
```
milestone {
  id: UUID
  user_id: UUID (foreign key)
  milestone_type: 'weekly_distance' | 'monthly_distance' | 'weekly_activity_count'
  threshold_value: decimal
  achieved_at: timestamp
  notification_sent: boolean
  notification_sent_at: timestamp (nullable)
}
```

### Consistency Model

**Conflict Resolution Strategy:**
- **Last-Write-Wins**: When same workout is edited on multiple devices, server timestamp determines winner
- **Metadata-Driven Merging**: `local_created_at` + `synced_at` + device_id allow apps to detect concurrent edits
- **Strava Reconciliation**: If workout exported to Strava and then edited on Strava, server fetches Strava version on next sync; user notified of changes
- **Eventual Consistency**: External integrations may lag 2-5 seconds; clients show local state immediately, converge to backend state

**Sync Semantics:**
- iOS/Android sends: `POST /api/v1/sync` with list of local workouts (since last sync timestamp)
- Server responds with: Canonical workouts (including any Strava updates), conflict list, new data
- Client merges response: Updates local database, resolves conflicts per user preference, queues external exports

### Backup & Encryption

**End-to-End Encryption (At Rest):**
- User's public key generated during onboarding; stored in `users.encryption_public_key`
- User's private key stored locally on device (never transmitted)
- Before backup to S3: backend receives encrypted payload from client, stores as-is (never decrypted by backend)
- Recovery: Client decrypts with private key on device; backend cannot access decrypted data
- Implementation: libsodium / TweetNaCl box_seal (asymmetric encryption)

**Backup Strategy:**
- Nightly full backup of user's workout data to S3 (encrypted)
- S3 versioning enabled; 30-day retention
- Cross-region replication for disaster recovery
- User can export encrypted backup as JSON file for offline archival

**Database Backup:**
- PostgreSQL continuous archival (WAL) to S3
- Point-in-time recovery (PITR) enabled; 30-day lookback
- Daily snapshots with 7-day retention
- Monthly snapshots with 1-year retention

---

## 4. API Surface

### Authentication Endpoints

**POST /api/v1/auth/signup**
- Request: `{ email, password }`
- Response: `{ user_id, session_token, refresh_token, encryption_public_key }`
- Rate limit: 5 req/hour per IP
- Auth: None

**POST /api/v1/auth/login**
- Request: `{ email, password }`
- Response: `{ session_token, refresh_token, user_id }`
- Rate limit: 10 req/minute per IP
- Auth: None

**POST /api/v1/auth/refresh**
- Request: `{ refresh_token }`
- Response: `{ session_token, refresh_token (new) }`
- Rate limit: 100 req/minute per user
- Auth: Refresh token

**POST /api/v1/auth/oauth/google**
- Request: `{ oauth_code }`
- Response: `{ session_token, refresh_token, user_id }`
- Rate limit: 10 req/minute per IP
- Auth: None

### Workout Sync Endpoints

**POST /api/v1/sync**
- Request:
  ```json
  {
    "device_id": "ios_uuid",
    "last_sync_timestamp": 1694000000,
    "workouts": [
      {
        "id": "local_uuid",
        "activity_type": "run",
        "start_time": 1694000000,
        "duration_seconds": 1800,
        "distance_km": 5.2,
        ...
      }
    ]
  }
  ```
- Response:
  ```json
  {
    "workouts": [...],
    "conflicts": [
      {
        "local_id": "...",
        "server_version": {...},
        "recommended_action": "use_server"
      }
    ],
    "next_sync_timestamp": 1694001000
  }
  ```
- Rate limit: 100 req/minute per user
- Auth: Bearer token (JWT)

**GET /api/v1/workouts?since={timestamp}&limit=50**
- Request: Query parameters for incremental sync
- Response: `{ workouts: [...], cursor: "...", has_more: boolean }`
- Rate limit: 200 req/minute per user
- Auth: Bearer token

**PATCH /api/v1/workouts/{workout_id}**
- Request: `{ distance_km, pace_avg, notes, ... }`
- Response: Updated workout object
- Rate limit: 100 req/minute per user
- Auth: Bearer token

**DELETE /api/v1/workouts/{workout_id}**
- Request: None
- Response: `{ deleted: true }`
- Rate limit: 50 req/minute per user
- Auth: Bearer token

### Analytics Endpoints

**GET /api/v1/analytics/summary?period=week**
- Request: Query parameter (week, month, year)
- Response:
  ```json
  {
    "total_distance_km": 25.5,
    "total_duration_hours": 3.2,
    "activity_count": 5,
    "avg_pace_min_per_km": 7.3,
    "total_calories": 2400,
    "period_start": 1694000000,
    "period_end": 1694600000
  }
  ```
- Rate limit: 200 req/minute per user
- Auth: Bearer token

### External Integration Endpoints

**POST /api/v1/integrations/strava/connect**
- Request: `{ oauth_code }`
- Response: `{ provider_user_id, connected_at }`
- Rate limit: 10 req/minute per user
- Auth: Bearer token

**POST /api/v1/integrations/strava/disconnect**
- Request: None
- Response: `{ disconnected: true }`
- Rate limit: 10 req/minute per user
- Auth: Bearer token

**POST /api/v1/integrations/strava/sync**
- Request: None (triggers manual sync)
- Response: `{ synced_workouts_count: 5, status: 'in_progress' }`
- Rate limit: 20 req/hour per user
- Auth: Bearer token

### Notification Endpoints

**POST /api/v1/notifications/preferences**
- Request: `{ milestone_notifications_enabled, push_enabled, quiet_hours: { start: "22:00", end: "08:00" } }`
- Response: Updated preferences object
- Rate limit: 50 req/minute per user
- Auth: Bearer token

**GET /api/v1/notifications/history?limit=20**
- Request: Query parameters
- Response: `{ notifications: [...], cursor: "..." }`
- Rate limit: 100 req/minute per user
- Auth: Bearer token

### Error Handling

All endpoints return standardized error responses:
```json
{
  "error": "invalid_request",
  "message": "Detailed error message",
  "status": 400,
  "timestamp": 1694000000,
  "request_id": "req_abc123"
}
```

Common error codes: `invalid_request` (400), `unauthorized` (401), `forbidden` (403), `not_found` (404), `conflict` (409), `rate_limited` (429), `internal_error` (500)

---

## 5. Security Architecture

### Authentication & Authorization

**Authentication Mechanism:**
- Primary: Email + password (bcrypt with 12 salt rounds)
- Alternative: OAuth2 (Google, Apple)
- Session: JWT tokens (RS256 algorithm)
  - Access token: 15-minute TTL, contains user_id + scopes
  - Refresh token: 30-day TTL, stored in Redis + database
  - Revocation: Can revoke all tokens by invalidating refresh tokens

**Authorization Model:**
- Users can only access their own workouts and integrations
- Service-to-service: API keys for backend workers (Strava sync, notifications)
- Role-based access control (future): Admin, support, analyst roles for internal tools

**Multi-Tenancy:**
- Single-tenant per user; no shared workspaces
- Row-level security: All queries filtered by user_id
- Logical separation; no physical data isolation in V1

### Token & Credential Handling

**Sensitive Data Encryption:**
- External API tokens (Strava, Google Fit) encrypted at rest using AES-256-GCM
- Encryption key stored separately in secure key management service (AWS KMS / HashiCorp Vault)
- Key rotation: Annual rotation with zero-downtime re-encryption

**Session Token Storage:**
- Server: Redis (in-memory, protected via network isolation + authentication)
- Client: Secure storage per platform
  - iOS: Keychain (encrypted by iOS)
  - Android: Android Keystore (encrypted by Android)

**Cookie Policy:**
- `SameSite=Strict` to prevent CSRF
- `HttpOnly` to prevent JavaScript access
- `Secure` flag for HTTPS-only transmission

### PII & Data Protection

**User Data Classification:**
- PII: Email, user name (optional)
- Health data: Workout details, geolocation, heart rate, calories (sensitive; encryption mandatory)
- Usage data: Sync timestamps, app version (non-sensitive)

**PII Protection:**
- Email hashed for cross-service lookups; plain stored only for authentication
- Location data (latitude/longitude from workout segments) encrypted at rest
- Export APIs: Workouts with segments never include lat/lon in unencrypted exports
- Retention: User can request deletion (GDPR); system purges after 30 days

**Database Encryption:**
- PostgreSQL: TDE (Transparent Data Encryption) for entire database volume
- External API tokens: Column-level encryption (libsodium/pgcrypto)

### DDoS & Rate Limiting

**Rate Limiting Strategy:**
- Token bucket per user (100 sync req/min, 200 read req/min)
- Global rate limit: 10,000 requests/second across all users
- Adaptive backoff: Clients reduce request frequency if 429 responses received
- IP-based rate limit (auth endpoints): 10 login attempts per minute per IP

**DDoS Mitigation:**
- CloudFront/WAF to filter malicious traffic
- Connection rate limiting: Max 100 new connections per second per IP
- Payload validation: Reject requests >10MB
- Timeout: 30-second request timeout

### Audit Logging

**Logged Events:**
- User authentication (login, logout, token refresh)
- Data modifications (create, update, delete workouts)
- Integration connects/disconnects
- External API calls (Strava sync, HealthKit sync)

**Log Storage:**
- Centralized logging (ELK Stack / CloudWatch)
- Retained for 90 days
- Access restricted to operations/security team
- Immutable audit trail (no deletion, only append)

**Log Privacy:**
- Sensitive fields (passwords, tokens, lat/lon) redacted before storage
- Logs encrypted at rest
- Only operations team + security can query logs

---

## 6. Deployment & Operations

### Infrastructure & Orchestration

**Deployment Topology:**
- Container orchestration: Kubernetes (self-managed or AWS EKS)
- Container registry: Docker Hub or AWS ECR
- Load balancer: nginx ingress controller with auto-scaling
- DNS: Route53 (AWS) with health checks

**Kubernetes Configuration:**
- Node pools: General-purpose (t3.large) for API servers, memory-optimized (r5.xlarge) for cache/queue
- Horizontal Pod Autoscaler: Scale API pods 2-20 based on CPU (70% target)
- Pod disruption budgets: Ensure 2+ API pods always available during updates
- Resource limits: CPU 500m/1000m, memory 512Mi/1Gi per pod

**Database Deployment:**
- PostgreSQL on RDS (AWS) or self-managed with high-availability setup
- Multi-AZ replication for automatic failover
- Read replicas for analytics queries (separate from write-heavy sync queries)
- Auto-backup: Daily snapshots, 30-day retention

**Cache & Queue:**
- Redis cluster on ElastiCache (AWS) or self-managed with Sentinel
- RabbitMQ on Kubernetes (StatefulSet) with 3 replicas for HA
- Persistent volumes for message durability

### Configuration Management

**Environment Variables:**
- API_PORT (default 3000)
- DATABASE_URL (PostgreSQL connection string)
- REDIS_URL (Redis cluster endpoints)
- RABBITMQ_URL (RabbitMQ connection)
- JWT_SECRET (signing key, rotated quarterly)
- ENCRYPTION_KEY_ID (KMS key identifier)
- STRAVA_API_KEY, STRAVA_WEBHOOK_SECRET

**Configuration as Code:**
- Terraform for infrastructure provisioning
- Helm charts for Kubernetes deployments
- Environment-specific overrides (dev, staging, production)

### Monitoring & Observability

**Metrics (Prometheus):**
- API latency: p50, p95, p99 (target: <200ms p95)
- Sync success rate: % of successful syncs (target: >99.9%)
- External API latency: Strava, HealthKit response times
- Database query performance: Slow query log (>500ms)
- Cache hit rate: Redis/memcached (target: >90%)
- Message queue depth: Pending jobs in RabbitMQ

**Logging (ELK / CloudWatch):**
- Structured JSON logs with correlation IDs
- Log levels: INFO (user actions), WARN (degraded operations), ERROR (failures)
- Centralized ingestion via Fluent Bit + forwarding to Elasticsearch/S3
- Retention: Hot storage (7 days), warm (30 days), cold (90 days)

**Tracing (Jaeger / Datadog):**
- Distributed tracing for all requests
- 5% sampling rate (configurable per endpoint)
- Trace parent/child relationships for background jobs
- Alert on p99 latency >500ms

**Alerting (PagerDuty / OpsGenie):**
- API error rate >1% → page on-call engineer
- Database CPU >80% → page DBA
- Sync success rate <99% → page platform team
- RabbitMQ queue depth >100k → page backend engineer

### Database Migrations

**Strategy:**
- Zero-downtime migrations using expand-contract pattern
- Backward-compatible schema changes (new columns nullable by default)
- Version control in Git; migrations applied before deployment
- Rollback capability: Maintain two concurrent schema versions during migration window

**Migration Tool:** Flyway or Liquibase (SQL-based, with version tracking)

**Process:**
1. Create migration script (new table/column)
2. Deploy to staging; validate with production-like data volume
3. Schedule during low-traffic window (2-4 AM UTC)
4. Run migration; verify data integrity
5. Deploy application code (reads/writes new schema)
6. Monitor for errors; rollback if needed (revert to old schema, redeploy old app code)

### Backup & Disaster Recovery

**Backup Schedule:**
- Database: Hourly snapshots (24 hours), daily snapshots (30 days), monthly snapshots (1 year)
- User backups (S3): Daily encrypted exports, 30-day retention
- Configuration: Git version control for IaC, encrypted secrets in vault

**Recovery Procedures:**
- Database failure: RDS failover (automatic, <60 second impact) or manual restore from snapshot (<15 min)
- Data loss: User can recover from encrypted backup via mobile app
- Regional failure: Multi-region setup with failover to secondary region (requires 2x infrastructure cost; defer to V2)

**RTO/RPO Targets:**
- API service: RTO <5 min (k8s pod restart), RPO = 0 (stateless)
- Database: RTO <2 min (failover), RPO <1 hour (snapshot frequency)
- User backups: RTO <30 min (restore from S3), RPO <24 hours

### Deployment Pipeline

**CI/CD (GitHub Actions or GitLab CI):**
1. Push to `main` branch triggers automated tests
   - Unit tests: Jest (Node.js), XCTest (iOS), Espresso (Android)
   - Integration tests: Against staging database
   - Linting: ESLint, SwiftLint, ktlint
2. Build artifacts
   - Backend: Docker image tagged with commit SHA
   - iOS: Build for staging, upload to TestFlight
   - Android: Build for staging, upload to Firebase App Distribution
3. Deploy to staging
   - Kubernetes manifests applied to staging cluster
   - Smoke tests: Basic API health checks, sync flow
4. Manual approval for production
5. Deploy to production
   - Rolling update (1 pod at a time) to maintain availability
   - Blue-green deployment option for database schema changes
6. Post-deployment validation
   - Synthetic tests (fake user creates workout, syncs)
   - Monitor error rates for 30 minutes

**Rollback Process:**
- Automated rollback if error rate >1% for 5 minutes
- Manual rollback via `kubectl rollout undo` (reverts to previous image)
- Database rollback: Revert to prior snapshot (data-losing operation; only for critical failures)

---

## 7. Open Technical Decisions

### 1. Local Database Technology (iOS)
- **Decision**: Core Data vs. Realm
- **Why**: Impacts app size, query performance, offline-first experience
- **Options**:
  - Core Data: Built-in, zero dependencies, <50KB footprint, adequate for ~10k workouts
  - Realm: Third-party (5MB), faster queries, reactive notifications, better for large datasets
- **Recommended**: Start with Core Data for V1 (matches iOS platform conventions, zero overhead); migrate to Realm if query performance becomes bottleneck in V2
- **Fallback**: If Core Data causes issues, Realm provides drop-in replacement

### 2. Backend Language & Framework
- **Decision**: Node.js/Express vs. Go vs. Python
- **Why**: Impacts development velocity, performance, operational complexity
- **Options**:
  - Node.js: Fast to develop, ecosystem of npm packages, moderate performance (~1000 req/s per instance)
  - Go: Compiled, high performance (~10,000 req/s per instance), steeper learning curve, good for large teams
  - Python: Fast to develop, Django ORM excellent for rapid iteration, moderate performance (~300 req/s per instance)
- **Recommended**: Node.js/Express for V1 (fast time-to-market, good-enough performance for projected scale); evaluate Go if P99 latency concerns emerge post-launch
- **Fallback**: If performance becomes critical and Go adoption isn't feasible, scale horizontally with more Node.js instances + better caching

### 3. Message Queue Technology
- **Decision**: RabbitMQ vs. Apache Kafka vs. AWS SQS
- **Why**: Impacts complexity, operational burden, throughput limits
- **Options**:
  - RabbitMQ: Reliable delivery, per-message deadletter, easy to operate, ~1M msg/s throughput
  - Kafka: High throughput (~10M msg/s), stream processing capabilities, operational complexity, overkill for V1 workload
  - AWS SQS: Managed service, no operational overhead, <1% cost vs. self-managed, but less sophisticated routing
- **Recommended**: RabbitMQ for V1 (Kubernetes StatefulSet deployment, good balance of features/simplicity); migrate to Kafka if event volume >100k/day or if need stream replay
- **Fallback**: If RabbitMQ becomes operational burden, AWS SQS provides simpler (though less flexible) alternative

### 4. Session Storage & Invalidation
- **Decision**: Redis vs. PostgreSQL for session tokens
- **Why**: Impacts token revocation speed, complexity of logout
- **Options**:
  - Redis: Fast token lookup/revocation (sub-millisecond), explicit TTL, requires separate infrastructure
  - PostgreSQL: Single database, simpler operations, slower token validation (~10ms query), need cleanup job for expired sessions
- **Recommended**: Redis for V1 (fast logout experience, TTL naturally expires old sessions); provides clear separation of concerns
- **Fallback**: If Redis unavailable/down, gracefully degrade to longer token expiry (15 min instead of immediate revocation)

### 5. Encryption Key Management
- **Decision**: AWS KMS vs. HashiCorp Vault vs. Local key derivation
- **Why**: Impacts security posture, operational complexity, disaster recovery
- **Options**:
  - AWS KMS: Managed, automatic key rotation, audit logging, AWS-only
  - Vault: Self-hosted, multi-cloud, more operational overhead, superior flexibility
  - Local derivation: User password derives encryption key (no backend key storage), but recovery harder if user forgets password
- **Recommended**: AWS KMS for V1 (managed, auditable, good enough security); transition to Vault if multi-cloud expansion required
- **Fallback**: If KMS issues arise, implement local key derivation (reduces backend attack surface)

### 6. Analytics Database (Future)
- **Decision**: Snowflake vs. BigQuery vs. DuckDB
- **Why**: Impacts reporting latency, cost at scale, operational complexity
- **Options**:
  - BigQuery: Serverless, excellent for ad-hoc queries, managed, expensive at large scale
  - Snowflake: Separate warehouse, good performance, operational overhead, better cost scaling
  - DuckDB: Lightweight, embedded, good for <1TB workloads, limited concurrency
- **Recommended**: Defer to V2 (basic SQL queries on PostgreSQL read replica sufficient for V1); recommend BigQuery when analytics workload emerges
- **Fallback**: If analytics needed earlier, run daily batch exports to Google Sheets + pivot tables

### 7. Wearable Integration (Future)
- **Decision**: Apple Watch native app vs. indirect via HealthKit
- **Why**: Impacts watchOS development complexity, user experience for real-time tracking
- **Options**:
  - Native Watch app: Better UX (standalone tracking), requires Swift/watchOS expertise, ~4-week effort
  - Indirect (HealthKit): Simpler, but relies on iPhone proximity, less real-time experience
- **Recommended**: Defer to V2 (HealthKit sufficient for V1); add native watchOS app if user feedback indicates demand
- **Fallback**: User can use native Apple Workout app on Watch; data syncs via HealthKit

---

## 8. Tradeoffs & Rationale

### Why This Architecture?

**Local-First + Cloud Sync:**
- Rationale: Offline fitness tracking is critical (users track in parks, underground running, poor network areas)
- Tradeoff: More complex sync logic and conflict resolution vs. simpler cloud-only app
- Value: Solves core problem (unreliable connectivity) enabling offline-first experience

**Native iOS + Android vs. Cross-Platform (React Native/Flutter):**
- Rationale: Fitness tracking requires tight integration with HealthKit (iOS) and sensors; cross-platform frameworks lag native performance
- Tradeoff: 2x development effort (separate iOS/Android teams) vs. faster time-to-market with single codebase
- Value: Superior performance, access to device capabilities (location, heart rate), app store confidence

**End-to-End Encryption for Backups:**
- Rationale: Health data is sensitive (HIPAA/GDPR implications); user privacy is competitive advantage
- Tradeoff: User's private key recovery is complex (password-based key derivation needed)
- Value: Builds trust; users own their health data; zero-knowledge platform

**PostgreSQL + Redis (vs. NoSQL-only):**
- Rationale: Fitness data is relational (users → workouts → segments); ACID consistency simplifies conflict resolution
- Tradeoff: More complex schema, join queries, vs. flexibility of NoSQL
- Value: Data integrity guarantees; simpler sync semantics

**Kubernetes Orchestration:**
- Rationale: Horizontal scaling capability for 100k+ users; proven platform for stateless services
- Tradeoff: Operational complexity (requires DevOps expertise) vs. simpler Heroku/Platform-as-a-Service
- Value: Cost efficiency at scale; infrastructure as code (Terraform); multi-cloud portability (future)

### Known Limitations

1. **Strava Sync Latency**: Strava API calls are rate-limited and may lag 5-10 seconds behind app operations
   - Mitigation: Show local state immediately; background sync eventually converges

2. **HealthKit Availability (iOS)**: Apple HealthKit requires explicit user permission; some health data not accessible via HealthKit API
   - Mitigation: Document which fields are synced; accept data loss for unsupported fields (user can re-enter)

3. **Mobile App Size**: Target <200MB; adding features (wearables, advanced analytics) will approach this limit
   - Mitigation: Use app thinning; defer optional features to V2

4. **Battery Impact**: Location tracking drains battery; users may disable background sync to preserve battery
   - Mitigation: Provide low-power mode (sync only when plugged in); educate users about battery tradeoffs

5. **Scalability Ceiling**: Current PostgreSQL + Redis setup supports ~100k concurrent users; beyond that requires sharding
   - Mitigation: Monitor capacity; plan sharding strategy for V2 if growth warrants

### Future Pivot Points

**If Requirements Change:**

1. **Social Features Needed**: Add `follows`, `activity_feed`, `comments` tables; denormalize for read performance; rebuild frontend components
   - Impact: 3-4 weeks additional work; requires new security model (privacy controls)

2. **Web Dashboard Required**: Build React SPA frontend; reuse existing REST API; add admin queries to backend
   - Impact: 4-6 weeks; no backend changes needed

3. **AI Coaching Requested**: Add separate ML microservice (Python/FastAPI); store coach recommendations in PostgreSQL; surface in apps
   - Impact: 6-8 weeks; requires data science expertise

4. **Wearable Support Needed**: Build watchOS app; establish direct connection to watch (requires WatchConnectivity framework)
   - Impact: 2-3 weeks iOS; 2-3 weeks backend sync updates

5. **High Volume (>10M users)**: Implement database sharding (by user_id hash); geographic replication; CDN for static assets
   - Impact: 2-3 months infrastructure work; requires strong DevOps team

### Operational Maturity Roadmap

**V1 (Launch, Week 0-12):**
- Manual operations (SSH into prod, check logs manually)
- Basic monitoring (CPU, memory, disk)
- Slack notifications for critical errors

**V2 (Post-Launch, Week 12-26):**
- Automated runbooks (clear status, restart pods automatically)
- Comprehensive dashboards (SLOs visible, trends tracked)
- On-call rotation with pagerduty

**V3 (Scale Phase, Week 26+):**
- Predictive scaling (forecast load, pre-scale)
- Automated incident response (auto-remediate common issues)
- Multi-region failover

---

**Document Version**: 1.0  
**Architecture Review Date**: 2026-09-08  
**Next Review**: 2026-12-08 (post-launch assessment)
