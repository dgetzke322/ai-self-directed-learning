#!/bin/bash
TRIGGER_FILE="proceed-to-architecture.flag"
LOG_FILE="hook-log.txt"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
WAIT_COUNT=0
MAX_WAIT=20
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
  if [ -f "$TRIGGER_FILE" ]; then
    echo "[$TIMESTAMP] ARCH TRIGGER: Detected." | tee -a "$LOG_FILE"
    rm "$TRIGGER_FILE"
    PRD_FILE=$(ls -t prd-*.md 2>/dev/null | head -1)
    if [ -n "$PRD_FILE" ]; then
      echo "/create-architecture" > next-command.txt
      echo "[$TIMESTAMP] ARCH TRIGGER: Ready for architecture step." | tee -a "$LOG_FILE"
      exit 0
    fi
  fi
  WAIT_COUNT=$((WAIT_COUNT + 1))
  sleep 0.1
done
exit 0
