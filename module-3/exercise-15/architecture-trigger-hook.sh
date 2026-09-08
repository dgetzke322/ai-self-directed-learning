#!/bin/bash
#
# architecture-trigger-hook.sh — Detects validation trigger and queues next step
#
# TRIGGER EVENT: PostToolUse Write event on any file write in the working directory
#   (configured in ~/.claude/settings.json hooks.PostToolUse)
#   Runs AFTER prd-sentinel-hook.sh completes
#
# PURPOSE: Coordinate the handoff between create-prd and create-architecture steps
#   in the governed two-step flow
#
# DECISION LOGIC:
#   1. Poll for proceed-to-architecture.flag (written by prd-sentinel-hook on validation pass)
#      - Wait up to 2 seconds with 0.1s polling intervals (handles race condition)
#      - Reason: Both hooks fire in parallel on Write event; this hook may check before
#        prd-sentinel-hook has written the flag
#
#   2. When flag is detected:
#      - Log READ and DELETE operations
#      - Find the most recently modified prd-*.md file
#      - Log FOUND operation with PRD filename
#
# SUCCESS ACTION:
#   - Write /create-architecture to next-command.txt (signals next step)
#   - Log WRITE operation with filename
#   - Create-prd skill detects next-command.txt and auto-invokes create-architecture
#   - Exit with code 0 (success)
#
# FAILURE ACTION (flag never appears):
#   - Exit with code 0 (graceful no-op)
#   - No flag = prd-sentinel-hook is still validating or validation failed
#   - create-architecture will not be queued
#
# RACE CONDITION HANDLING:
#   - Without polling: architecture-trigger-hook checks for flag before prd-sentinel-hook
#     writes it, causing silent failure
#   - With polling: Waits up to 2 seconds for flag to appear, catching the sequential
#     nature of the validation despite parallel hook execution
#
# SCHEMA REFERENCE: See create-prd-sentinel-schema.md for sentinel structure
#

TRIGGER_FILE="proceed-to-architecture.flag"
LOG_FILE="hook-log.txt"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
WAIT_COUNT=0
MAX_WAIT=20
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
  if [ -f "$TRIGGER_FILE" ]; then
    echo "[$TIMESTAMP] READ: $TRIGGER_FILE (trigger detected)" | tee -a "$LOG_FILE"
    rm "$TRIGGER_FILE"
    echo "[$TIMESTAMP] DELETE: $TRIGGER_FILE" | tee -a "$LOG_FILE"
    PRD_FILE=$(ls -t prd-*.md 2>/dev/null | head -1)
    if [ -n "$PRD_FILE" ]; then
      echo "[$TIMESTAMP] FOUND: $PRD_FILE (latest PRD)" | tee -a "$LOG_FILE"
      NEXT_CMD_FILE="next-command.txt"
      echo "/create-architecture" > "$NEXT_CMD_FILE"
      echo "[$TIMESTAMP] WRITE: $NEXT_CMD_FILE" | tee -a "$LOG_FILE"
      exit 0
    fi
  fi
  WAIT_COUNT=$((WAIT_COUNT + 1))
  sleep 0.1
done
exit 0
