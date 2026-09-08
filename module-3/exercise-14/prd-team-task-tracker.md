# Team Task Tracker — Product Requirements Document

## Problem Statement

Engineering teams lose context and productivity through communication fragmentation. Task status lives in Slack threads (lost in scroll), email (too slow), spreadsheets (stale), or tribal knowledge. Without a single source of truth, engineers interrupt each other to ask "what are you working on?" and blockers go unnoticed until they cascade into delays.

## Solution

Team Task Tracker is a lightweight task board integrated directly into Slack that surfaces task status, assignments, and blockers in real time without leaving the platform teams already use. Engineers create tasks from Slack commands, update status asynchronously, and receive notifications only when their action is needed. The board stays in sync across the workspace in real time.

## Key Requirements

1. Task creation via Slack `/task` command with required fields: title, assignee (single user), due date, initial status. Task creation must complete within 2 seconds of command invocation.

2. Task status transitions: backlog → in-progress → (blocked or done) with timestamp and actor logged for each transition. Status updates from Slack reactions or modal form must reflect across all views within 1 second.

3. Blocker notifications: when a task is marked blocked, all team members assigned tasks that depend on it (dependency edge must be set at task creation) receive a direct Slack message within 5 seconds.

4. Real-time task list view in Slack: `/tasks` command returns current board state showing all active (backlog, in-progress, blocked) tasks, assignee, due date, and status in a formatted message. Message must be current as of the time of request.

5. Task assignment: only the workspace owner or task creator can reassign a task. Reassignment must be acknowledged by the new assignee (opt-in). If a reassignment is not acknowledged within 1 hour, it reverts.

6. Storage: all task data (creation, updates, transitions, blockers) must persist in a database (SQL or managed key-value store). No Slack message history dependency; tasks survive Slack conversation archival.

7. Data retention: V1 stores active tasks indefinitely; completed tasks archive to cold storage after 90 days. Archived tasks remain queryable but do not appear in board views.

8. Single workspace limitation: V1 supports one Slack workspace per deployment. Multi-workspace support is out of scope.

## Technical Context

- Platform: Slack (Slack Bot, OAuth, Events API for real-time subscriptions)
- Database: PostgreSQL or DynamoDB (recommend PostgreSQL for relational task-dependency queries)
- API: REST for task mutations, WebSocket or Slack Events API for real-time state sync
- Language: JavaScript/Node.js, Python, or Go (team choice; no prescription)
- Scale limits (V1): max 500 tasks per workspace, max 100 users per workspace, max 10 concurrent active sessions
- Security: Slack OAuth token rotation on 90-day cycle; no storage of Slack token locally; no task data returned to users without workspace membership verification

## V1 Scope & Boundaries

**Included in V1:**
- Task CRUD (create, read, update status, delete only by creator/admin)
- Slack slash command interface for task creation, status view, status update
- Real-time status sync via Slack reactions
- Blocker detection and notification (direct message to affected team members)
- Task assignment with opt-in acknowledgment
- Persistent storage (PostgreSQL/DynamoDB backend)
- Single workspace support

**Explicitly Out of Scope (V2+):**
- Multi-workspace deployments (V2)
- Task comments or threading (V2 — manage via Slack thread reply instead)
- Recurring or recurring tasks (V2 — manual recreation in V1)
- Custom fields or metadata beyond title, assignee, due date, status (V2)
- Calendar view or Gantt chart visualization (V2 — Slack list view only in V1)
- Mobile app (V2 — Slack mobile web view in V1)
- Integrations with Jira, Linear, or other tools (V2)
- Permission model beyond workspace member / owner (V2)
- Subtasks or task hierarchies (V2)
- Time tracking or effort estimates (V2)

**Rationale for exclusions:** V1 prioritizes a single-workspace, lightweight, Slack-first experience. Dependencies and blockers are the highest-value feature. Comments, custom fields, and integrations add surface area that would delay launch; they are deferred to V2 when the core workflow is validated.

## Non-Functional Requirements

- **Availability:** 99% uptime SLA (target; failure tolerance: 1 hour downtime per month acceptable in V1)
- **Latency:** task creation 2s max, status updates 1s max, list queries 500ms max (p95)
- **Concurrency:** support 100 concurrent workspace members without degradation
- **Scalability:** backend must support growth from 10 to 500 tasks without re-architecting database schema
- **Data integrity:** no task data loss under normal operation; transaction isolation at serializable level for concurrent updates
- **Security:** all Slack API calls use OAuth tokens; no PII stored locally; encrypted at rest for tokens; HTTPS-only for API
- **Monitoring:** log all task transitions and blocker events for audit trail; surface errors to admin channel

## Success Metrics

- **Adoption (by week 2):** 50% of pilot team (min 5 users) create at least one task
- **Engagement (weekly):** average 10 status updates per day across the workspace (15 or more = high adoption signal)
- **Efficiency (self-reported):** 80% of pilot team reports ≥5 hours/week time saved from reduced context-switching and interruptions
- **Blocker response time:** mean time from blocker notification to acknowledgment ≤ 30 minutes (signals that blockers are surface-level visible)
- **Task completion rate (weekly):** average 40% of in-progress tasks move to done within 7 days (indicates tasks are not getting stale)
- **Error rate:** ≤1% of task mutations fail (target: zero unexpected data loss)

## Assumptions

- Pilot team (5-10 people) is available for 2-week closed-beta testing before wider rollout
- Slack workspace has standard member permissions; no unusual OAuth restrictions
- Team members check Slack at least once daily (real-time notification only reaches users actively connected)
- Tasks are scoped to engineering work; non-engineering use cases may not fit workflow
- Dependencies are known at task creation time; retroactive dependency linking is out of scope
- Team is willing to move away from spreadsheet or email-based task tracking (adoption risk if not)

## Open Questions & Decisions

1. **Task reassignment flow:** Should opt-in be a Slack reaction, a modal button, or a /command? (Recommend: reaction for simplicity)
2. **Blocker cascades:** If Task A blocks B and B blocks C, does notifying C require transitive dependency resolution? (Decide: notify only direct blockers in V1)
3. **Workspace owner permissions:** Can owner delete other users' tasks, or only own? (Recommend: only own in V1; admin deletion deferred to V2)
4. **Due date timezone:** Should due dates be workspace timezone or per-user timezone? (Decide: workspace timezone in V1 to avoid complexity)
5. **Database choice:** PostgreSQL (relational, better for dependencies) vs. DynamoDB (simpler deployment, serverless)? (Team decision in architecture phase)
6. **Monitoring and alerts:** Should admin be notified of high error rates automatically, or only on-demand query? (Recommend: on-demand in V1, automation in V2)

---

## Next Steps

1. **Architecture review:** Align on database choice, deployment model (serverless vs. managed)
2. **Slack app registration:** Create Slack app, configure OAuth scopes, register slash commands
3. **Prototype:** build hello-world task creation and list view in 1 week
4. **Pilot launch:** invite 5-10 person team, gather adoption and time-save metrics over 2 weeks
5. **Promptfoo evaluation:** validate PRD against real MVP output (scope adherence, success metric clarity, assumptions realism)
