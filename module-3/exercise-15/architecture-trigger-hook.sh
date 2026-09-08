#!/bin/bash
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
